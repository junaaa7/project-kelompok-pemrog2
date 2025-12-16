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

@WebServlet("/LoadCategoryServlet")
public class LoadCategoryServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("=== LoadCategoryServlet.doGet() ===");
        
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
        
        try {
            // Load categories from database
            List<Category> categories = loadCategories();
            
            // Store in session
            session.setAttribute("categories", categories);
            System.out.println("Loaded " + categories.size() + " categories into session");
            
            // Check if this is a check request
            String check = request.getParameter("check");
            if ("true".equals(check)) {
                // Just return OK for AJAX check
                response.setStatus(HttpServletResponse.SC_OK);
                return;
            }
            
            // Redirect back to JSP
            response.sendRedirect("category-management.jsp");
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Gagal memuat data kategori: " + e.getMessage());
            response.sendRedirect("category-management.jsp");
        }
    }
    
    private List<Category> loadCategories() throws Exception {
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
}