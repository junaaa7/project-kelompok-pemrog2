package com.pos.servlet;

import com.pos.dao.ProductDAO;
import com.pos.model.Product;
import com.pos.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "ProductManagementServlet", urlPatterns = {"/ProductManagementServlet"})
public class ProductManagementServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to product management page
        response.sendRedirect("product-management.jsp");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== PRODUCT MANAGEMENT SERVLET STARTED ===");
        
        HttpSession session = request.getSession(false); // Don't create new session
        
        // Check session
        if (session == null) {
            System.out.println("No session found, redirecting to login");
            response.sendRedirect("login.jsp?error=Session expired. Please login again.");
            return;
        }
        
        // Check if user is logged in
        User user = (User) session.getAttribute("user");
        if (user == null) {
            System.out.println("No user in session, redirecting to login");
            response.sendRedirect("login.jsp?error=Please login first.");
            return;
        }
        
        // Check if user is admin
        if (!"admin".equals(user.getRole())) {
            System.out.println("User is not admin: " + user.getRole());
            response.sendRedirect("dashboard.jsp?error=Access denied. Admin only.");
            return;
        }
        
        System.out.println("User authorized: " + user.getUsername() + " (" + user.getRole() + ")");
        
        ProductDAO productDAO = new ProductDAO();
        String action = request.getParameter("action");
        String message = "";
        String error = "";
        
        try {
            System.out.println("Action: " + action);
            
            if ("add".equals(action)) {
                // Add new product
                String code = request.getParameter("code");
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String priceStr = request.getParameter("price");
                String stockStr = request.getParameter("stock");
                String categoryIdStr = request.getParameter("categoryId");
                String imageUrl = request.getParameter("imageUrl");
                
                System.out.println("Adding product - Code: " + code + ", Name: " + name);
                
                // Validate required fields
                if (code == null || code.trim().isEmpty() ||
                    name == null || name.trim().isEmpty() ||
                    priceStr == null || priceStr.trim().isEmpty() ||
                    stockStr == null || stockStr.trim().isEmpty()) {
                    
                    error = "All required fields must be filled";
                    throw new IllegalArgumentException(error);
                }
                
                double price = Double.parseDouble(priceStr);
                int stock = Integer.parseInt(stockStr);
                Integer categoryId = null;
                
                if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
                    categoryId = Integer.parseInt(categoryIdStr);
                }
                
                Product product = new Product();
                product.setCode(code);
                product.setName(name);
                product.setDescription(description);
                product.setPrice(price);
                product.setStock(stock);
                product.setCategoryId(categoryId);
                product.setImageUrl(imageUrl);
                product.setActive(true);
                
                boolean success = productDAO.addProduct(product);
                if (success) {
                    message = "Product '" + name + "' added successfully!";
                    System.out.println("Product added successfully: " + code);
                } else {
                    error = "Failed to add product. Product code might already exist.";
                    System.out.println("Failed to add product: " + code);
                }
                
            } else if ("update".equals(action)) {
                // Update existing product
                String productIdStr = request.getParameter("productId");
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String priceStr = request.getParameter("price");
                String stockStr = request.getParameter("stock");
                String categoryIdStr = request.getParameter("categoryId");
                String imageUrl = request.getParameter("imageUrl");
                String isActiveStr = request.getParameter("isActive");
                
                System.out.println("Updating product - ID: " + productIdStr + ", Name: " + name);
                
                if (productIdStr == null || productIdStr.trim().isEmpty()) {
                    error = "Product ID is required";
                    throw new IllegalArgumentException(error);
                }
                
                int productId = Integer.parseInt(productIdStr);
                double price = Double.parseDouble(priceStr);
                int stock = Integer.parseInt(stockStr);
                Integer categoryId = null;
                boolean isActive = "on".equals(isActiveStr);
                
                if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
                    categoryId = Integer.parseInt(categoryIdStr);
                }
                
                Product product = new Product();
                product.setId(productId);
                product.setName(name);
                product.setDescription(description);
                product.setPrice(price);
                product.setStock(stock);
                product.setCategoryId(categoryId);
                product.setImageUrl(imageUrl);
                product.setActive(isActive);
                
                boolean success = productDAO.updateProduct(product);
                if (success) {
                    message = "Product updated successfully!";
                    System.out.println("Product updated successfully: " + productId);
                } else {
                    error = "Failed to update product.";
                    System.out.println("Failed to update product: " + productId);
                }
                
            } else if ("toggleStatus".equals(action)) {
                // Toggle product status
                String productIdStr = request.getParameter("productId");
                
                System.out.println("Toggling product status - ID: " + productIdStr);
                
                if (productIdStr == null || productIdStr.trim().isEmpty()) {
                    error = "Product ID is required";
                    throw new IllegalArgumentException(error);
                }
                
                int productId = Integer.parseInt(productIdStr);
                boolean success = productDAO.toggleProductStatus(productId);
                
                if (success) {
                    message = "Product status changed successfully!";
                    System.out.println("Product status toggled: " + productId);
                } else {
                    error = "Failed to change product status.";
                    System.out.println("Failed to toggle product status: " + productId);
                }
            }
            
        } catch (NumberFormatException e) {
            error = "Invalid number format: " + e.getMessage();
            System.err.println("Number format error: " + e.getMessage());
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            error = e.getMessage();
            System.err.println("Validation error: " + e.getMessage());
        } catch (Exception e) {
            error = "System error: " + e.getMessage();
            System.err.println("System error: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("=== PRODUCT MANAGEMENT SERVLET COMPLETED ===");
        System.out.println("Message: " + message);
        System.out.println("Error: " + error);
        
        // Store message in session to survive redirect
        if (!message.isEmpty()) {
            session.setAttribute("successMessage", message);
        }
        if (!error.isEmpty()) {
            session.setAttribute("errorMessage", error);
        }
        
        // Redirect back to product management page
        response.sendRedirect("product-management.jsp");
    }
}