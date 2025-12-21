/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.servlet;

import com.pos.model.User;
import com.pos.model.Category;
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
import java.util.ArrayList;
import java.util.List;
import com.pos.config.DatabaseConfig;

/**
 *
 * @author ARJUNA.R.PUTRA
 */

@WebServlet("/CategoryManagementServlet")
public class CategoryManagementServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("=== CategoryManagementServlet.doPost() ===");
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equals(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        System.out.println("Action: " + action);
        
        try {
            if ("add".equals(action)) {
                addCategory(request, session);
            } else if ("update".equals(action)) {
                updateCategory(request, session);
            } else if ("delete".equals(action)) {
                deleteCategory(request, session);
            }

            reloadCategories(session);

            session.setAttribute("lastUpdateTime", System.currentTimeMillis());
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error: " + e.getMessage());
        }

        response.sendRedirect("category-management.jsp?t=" + System.currentTimeMillis());
    }
    
    private void addCategory(HttpServletRequest request, HttpSession session) throws Exception {
        String code = request.getParameter("code");
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        
        System.out.println("Adding category: " + name + ", code: " + code);
        
        // Validasi
        if (name == null || name.trim().isEmpty()) {
            session.setAttribute("error", "Nama kategori wajib diisi");
            return;
        }
        
        // Generate kode otomatis jika kosong
        if (code == null || code.trim().isEmpty()) {
            code = generateCategoryCode();
        }
        
        String sql = "INSERT INTO categories (code, name, description) VALUES (?, ?, ?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, code);
            stmt.setString(2, name.trim());
            stmt.setString(3, description != null ? description.trim() : null);
            
            int rows = stmt.executeUpdate();
            if (rows > 0) {
                session.setAttribute("message", "Kategori '" + name + "' berhasil ditambahkan!");
                System.out.println("Category added successfully: " + name);
            } else {
                session.setAttribute("error", "Gagal menambahkan kategori");
            }
        } catch (Exception e) {
            session.setAttribute("error", "Database error: " + e.getMessage());
            throw e;
        }
    }
    
    private void updateCategory(HttpServletRequest request, HttpSession session) throws Exception {
        String idParam = request.getParameter("id");
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        
        System.out.println("Updating category ID: " + idParam + ", name: " + name);
        
        // Validasi
        if (idParam == null || idParam.trim().isEmpty()) {
            session.setAttribute("error", "ID kategori tidak valid");
            return;
        }
        if (name == null || name.trim().isEmpty()) {
            session.setAttribute("error", "Nama kategori wajib diisi");
            return;
        }
        
        int id = Integer.parseInt(idParam);
        String sql = "UPDATE categories SET name = ?, description = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, name.trim());
            stmt.setString(2, description != null ? description.trim() : null);
            stmt.setInt(3, id);
            
            int rows = stmt.executeUpdate();
            if (rows > 0) {
                session.setAttribute("message", "Kategori berhasil diperbarui!");
                System.out.println("Category updated successfully: ID=" + id);
            } else {
                session.setAttribute("error", "Kategori tidak ditemukan");
            }
        } catch (Exception e) {
            session.setAttribute("error", "Database error: " + e.getMessage());
            throw e;
        }
    }
    
    private void deleteCategory(HttpServletRequest request, HttpSession session) throws Exception {
        String idParam = request.getParameter("id");
        System.out.println("Deleting category ID: " + idParam);
        
        if (idParam == null || idParam.trim().isEmpty()) {
            session.setAttribute("error", "ID kategori tidak valid");
            return;
        }
        
        int id = Integer.parseInt(idParam);
        String categoryName = "";
        
        // Ambil nama kategori untuk pesan
        String nameSql = "SELECT name FROM categories WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement nameStmt = conn.prepareStatement(nameSql)) {
            
            nameStmt.setInt(1, id);
            ResultSet rs = nameStmt.executeQuery();
            if (rs.next()) {
                categoryName = rs.getString("name");
            }
        }
        
        // Cek apakah kategori memiliki produk
        String checkSql = "SELECT COUNT(*) as product_count FROM products WHERE category_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            
            checkStmt.setInt(1, id);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next()) {
                int productCount = rs.getInt("product_count");
                if (productCount > 0) {
                    System.out.println("Category has " + productCount + " products, setting to NULL");
                    // Update produk untuk set category_id menjadi NULL
                    String updateProductsSql = "UPDATE products SET category_id = NULL WHERE category_id = ?";
                    try (PreparedStatement updateStmt = conn.prepareStatement(updateProductsSql)) {
                        updateStmt.setInt(1, id);
                        updateStmt.executeUpdate();
                    }
                }
            }
        }
        
        // DELETE kategori
        String sql = "DELETE FROM categories WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            int rows = stmt.executeUpdate();
            
            if (rows > 0) {
                session.setAttribute("message", "Kategori '" + categoryName + "' berhasil dihapus!");
                System.out.println("Category deleted successfully: " + categoryName);
            } else {
                session.setAttribute("error", "Kategori tidak ditemukan");
            }
        } catch (Exception e) {
            session.setAttribute("error", "Database error: " + e.getMessage());
            throw e;
        }
    }
    
    private void reloadCategories(HttpSession session) throws Exception {
        List<Category> categories = getCategoriesFromDatabase();
        session.setAttribute("categories", categories);
        System.out.println("Categories reloaded: " + categories.size() + " items");
    }
    
    private List<Category> getCategoriesFromDatabase() throws Exception {
        List<Category> categories = new ArrayList<>();
        
        String sql = "SELECT c.*, COUNT(p.id) as product_count " +
                     "FROM categories c " +
                     "LEFT JOIN products p ON c.id = p.category_id " +
                     "GROUP BY c.id ORDER BY c.name";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Category category = new Category();
                category.setId(rs.getInt("id"));
                category.setCode(rs.getString("code"));
                category.setName(rs.getString("name"));
                category.setDescription(rs.getString("description"));
                category.setProductCount(rs.getInt("product_count"));
                categories.add(category);
            }
        }
        
        return categories;
    }
    
    private String generateCategoryCode() throws Exception {
        String sql = "SELECT MAX(code) as max_code FROM categories WHERE code LIKE 'CAT%'";
        String newCode = "CAT001";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            if (rs.next()) {
                String maxCode = rs.getString("max_code");
                if (maxCode != null && maxCode.matches("CAT\\d+")) {
                    try {
                        int num = Integer.parseInt(maxCode.substring(3)) + 1;
                        newCode = String.format("CAT%03d", num);
                    } catch (NumberFormatException e) {
                        newCode = "CAT001";
                    }
                }
            }
        }
        
        return newCode;
    }
}