package com.pos.servlet;

import com.pos.dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.pos.config.DatabaseConfig;

@WebServlet("/CategoryManagementServlet")
public class CategoryManagementServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Object user = session.getAttribute("user");
        
        // Check if user is admin
        if (user == null || !user.toString().contains("admin")) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "add":
                    addCategory(request, response);
                    break;
                case "update":
                    updateCategory(request, response);
                    break;
                case "delete":
                    deleteCategory(request, response);
                    break;
                default:
                    response.sendRedirect("category-management.jsp");
            }
        } catch (Exception e) {
            request.setAttribute("error", "Terjadi kesalahan: " + e.getMessage());
            request.getRequestDispatcher("category-management.jsp").forward(request, response);
        }
    }
    
    private void addCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String code = request.getParameter("code");
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        
        // Generate code if not provided
        if (code == null || code.trim().isEmpty()) {
            code = generateCategoryCode();
        }
        
        String sql = "INSERT INTO categories (code, name, description) VALUES (?, ?, ?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, code);
            stmt.setString(2, name);
            stmt.setString(3, description);
            
            int rows = stmt.executeUpdate();
            if (rows > 0) {
                request.setAttribute("message", "Kategori berhasil ditambahkan!");
            } else {
                request.setAttribute("error", "Gagal menambahkan kategori!");
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        
        request.getRequestDispatcher("category-management.jsp").forward(request, response);
    }
    
    private void updateCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        
        String sql = "UPDATE categories SET name = ?, description = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, name);
            stmt.setString(2, description);
            stmt.setInt(3, id);
            
            int rows = stmt.executeUpdate();
            if (rows > 0) {
                request.setAttribute("message", "Kategori berhasil diperbarui!");
            } else {
                request.setAttribute("error", "Gagal memperbarui kategori!");
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        
        request.getRequestDispatcher("category-management.jsp").forward(request, response);
    }
    
    private void deleteCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        
        // Check if category has products
        String checkSql = "SELECT COUNT(*) as product_count FROM products WHERE category_id = ?";
        String updateSql = "UPDATE products SET category_id = NULL WHERE category_id = ?";
        String deleteSql = "DELETE FROM categories WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            
            checkStmt.setInt(1, id);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                int productCount = rs.getInt("product_count");
                
                if (productCount > 0) {
                    // Update products to null category first
                    try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                        updateStmt.setInt(1, id);
                        updateStmt.executeUpdate();
                    }
                }
                
                // Now delete category
                try (PreparedStatement deleteStmt = conn.prepareStatement(deleteSql)) {
                    deleteStmt.setInt(1, id);
                    int rows = deleteStmt.executeUpdate();
                    
                    if (rows > 0) {
                        if (productCount > 0) {
                            request.setAttribute("message", "Kategori berhasil dihapus! " + productCount + " produk sekarang tanpa kategori.");
                        } else {
                            request.setAttribute("message", "Kategori berhasil dihapus!");
                        }
                    } else {
                        request.setAttribute("error", "Gagal menghapus kategori!");
                    }
                }
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        
        request.getRequestDispatcher("category-management.jsp").forward(request, response);
    }
    
    private String generateCategoryCode() {
        String sql = "SELECT MAX(code) as max_code FROM categories WHERE code LIKE 'CAT%'";
        String newCode = "CAT001";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            if (rs.next()) {
                String maxCode = rs.getString("max_code");
                if (maxCode != null) {
                    int num = Integer.parseInt(maxCode.substring(3)) + 1;
                    newCode = String.format("CAT%03d", num);
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return newCode;
    }
}