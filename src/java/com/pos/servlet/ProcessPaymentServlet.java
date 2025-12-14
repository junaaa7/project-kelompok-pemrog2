package com.pos.servlet;

import com.pos.model.User;
import com.pos.service.CartService;
import com.pos.model.CartItem;
import com.pos.model.Product;
import com.pos.config.DatabaseConfig;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet("/ProcessPaymentServlet")
public class ProcessPaymentServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        CartService cartService = (CartService) session.getAttribute("cartService");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Only cashier can process payment
        if (!"cashier".equals(user.getRole())) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        
        if (cartService == null || cartService.getCartItems().isEmpty()) {
            response.sendRedirect("cart.jsp?error=Keranjang kosong");
            return;
        }
        
        Connection conn = null;
        PreparedStatement transStmt = null;
        PreparedStatement detailStmt = null;
        ResultSet generatedKeys = null;
        
        try {
            double cash = Double.parseDouble(request.getParameter("cash"));
            double total = cartService.calculateTotal();
            List<CartItem> cartItems = cartService.getCartItems();
            
            if (cash < total) {
                response.sendRedirect("cart.jsp?error=Uang tidak cukup. Minimal: Rp " + String.format("%,.0f", total));
                return;
            }
            
            double change = cash - total;
            
            // Get database connection
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false); // Start transaction
            
            // 1. Save transaction
            String transactionCode = generateTransactionCode();
            String transSql = "INSERT INTO transactions (transaction_code, transaction_date, user_id, " +
                             "total_amount, cash, change_amount, payment_method, status) " +
                             "VALUES (?, NOW(), ?, ?, ?, ?, 'cash', 'completed')";
            
            transStmt = conn.prepareStatement(transSql, Statement.RETURN_GENERATED_KEYS);
            transStmt.setString(1, transactionCode);
            transStmt.setInt(2, user.getId());
            transStmt.setDouble(3, total);
            transStmt.setDouble(4, cash);
            transStmt.setDouble(5, change);
            
            int rowsAffected = transStmt.executeUpdate();
            
            if (rowsAffected == 0) {
                throw new SQLException("Gagal menyimpan transaksi");
            }
            
            // Get generated transaction ID
            int transactionId = -1;
            generatedKeys = transStmt.getGeneratedKeys();
            if (generatedKeys.next()) {
                transactionId = generatedKeys.getInt(1);
                System.out.println("Transaction saved with ID: " + transactionId);
            }
            
            // 2. Save transaction details
            String detailSql = "INSERT INTO transaction_details (transaction_id, product_id, " +
                              "quantity, price, subtotal) VALUES (?, ?, ?, ?, ?)";
            detailStmt = conn.prepareStatement(detailSql);
            
            for (CartItem item : cartItems) {
                Product product = item.getProduct();
                detailStmt.setInt(1, transactionId);
                detailStmt.setInt(2, product.getId());
                detailStmt.setInt(3, item.getQuantity());
                detailStmt.setDouble(4, product.getPrice());
                detailStmt.setDouble(5, item.getSubtotal());
                detailStmt.addBatch();
                
                // 3. Update product stock (optional)
                updateProductStock(conn, product.getId(), item.getQuantity());
            }
            
            int[] batchResults = detailStmt.executeBatch();
            System.out.println("Saved " + batchResults.length + " transaction details");
            
            // Commit transaction
            conn.commit();
            System.out.println("Transaction committed successfully");
            
            // Clear cart from session
            session.removeAttribute("cartService");
            
            // Forward to receipt page with all data
            request.setAttribute("total", total);
            request.setAttribute("cash", cash);
            request.setAttribute("change", change);
            request.setAttribute("transactionCode", transactionCode);
            request.setAttribute("cartItems", cartItems);
            
            // Log success
            System.out.println("Payment processed successfully:");
            System.out.println("  Transaction Code: " + transactionCode);
            System.out.println("  Cashier: " + user.getFullName() + " (ID: " + user.getId() + ")");
            System.out.println("  Total: " + total);
            System.out.println("  Cash: " + cash);
            System.out.println("  Change: " + change);
            System.out.println("  Items: " + cartItems.size());
            
            RequestDispatcher dispatcher = request.getRequestDispatcher("receipt.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            rollbackTransaction(conn);
            response.sendRedirect("cart.jsp?error=Input uang tidak valid");
        } catch (SQLException e) {
            rollbackTransaction(conn);
            e.printStackTrace();
            response.sendRedirect("cart.jsp?error=Database error: " + e.getMessage());
        } catch (Exception e) {
            rollbackTransaction(conn);
            e.printStackTrace();
            response.sendRedirect("cart.jsp?error=Gagal memproses pembayaran: " + e.getMessage());
        } finally {
            closeResources(conn, transStmt, detailStmt, generatedKeys);
        }
    }
    
    private void updateProductStock(Connection conn, int productId, int quantitySold) throws SQLException {
        String updateSql = "UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?";
        try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
            updateStmt.setInt(1, quantitySold);
            updateStmt.setInt(2, productId);
            updateStmt.setInt(3, quantitySold);
            
            int updated = updateStmt.executeUpdate();
            if (updated > 0) {
                System.out.println("Updated stock for product ID " + productId + ", sold " + quantitySold);
            }
        }
    }
    
    private void rollbackTransaction(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
                System.out.println("Transaction rolled back");
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }
    
    private void closeResources(Connection conn, PreparedStatement stmt1, 
                               PreparedStatement stmt2, ResultSet rs) {
        try {
            if (rs != null) rs.close();
            if (stmt1 != null) stmt1.close();
            if (stmt2 != null) stmt2.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    private String generateTransactionCode() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        String timestamp = sdf.format(new Date());
        int random = (int)(Math.random() * 1000);
        return "TRX-" + timestamp + "-" + String.format("%03d", random);
    }
}