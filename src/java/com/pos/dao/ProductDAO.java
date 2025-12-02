/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.dao;

import com.pos.config.DatabaseConfig;
import com.pos.model.Product;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ARJUNA.R.PUTRA
 */

public class ProductDAO {
    
    // Get all active products
    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        // Query yang benar dengan JOIN ke categories
        String sql = "SELECT p.*, c.name as category_name " +
                    "FROM products p " +
                    "LEFT JOIN categories c ON p.category_id = c.id " +
                    "WHERE p.is_active = TRUE " +
                    "ORDER BY p.name";
        
        System.out.println("ProductDAO: Executing query: " + sql);
        
        try (Connection conn = DatabaseConfig.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Product product = mapResultSetToProduct(rs);
                products.add(product);
                System.out.println("ProductDAO: Found product - " + product.getCode() + ": " + product.getName());
            }
            
            System.out.println("ProductDAO: Total products found: " + products.size());
            
        } catch (SQLException e) {
            System.err.println("ProductDAO ERROR in getAllProducts: " + e.getMessage());
            e.printStackTrace();
        }
        return products;
    }
    
    // Get product by ID
    public Product getProductById(int id) {
        String sql = "SELECT p.*, c.name as category_name " +
                    "FROM products p " +
                    "LEFT JOIN categories c ON p.category_id = c.id " +
                    "WHERE p.id = ? AND p.is_active = TRUE";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToProduct(rs);
            }
        } catch (SQLException e) {
            System.err.println("ProductDAO ERROR in getProductById: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    // Get product by code
    public Product getProductByCode(String code) {
        String sql = "SELECT p.*, c.name as category_name " +
                    "FROM products p " +
                    "LEFT JOIN categories c ON p.category_id = c.id " +
                    "WHERE p.code = ? AND p.is_active = TRUE";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, code);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToProduct(rs);
            }
        } catch (SQLException e) {
            System.err.println("ProductDAO ERROR in getProductByCode: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    // Add new product
    public boolean addProduct(Product product) {
        String sql = "INSERT INTO products (code, name, description, price, stock, category_id, image_url) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, product.getCode());
            stmt.setString(2, product.getName());
            stmt.setString(3, product.getDescription());
            stmt.setDouble(4, product.getPrice());
            stmt.setInt(5, product.getStock());
            stmt.setInt(6, product.getCategoryId());
            stmt.setString(7, product.getImageUrl());
            
            int rowsAffected = stmt.executeUpdate();
            System.out.println("ProductDAO: addProduct rows affected: " + rowsAffected);
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("ProductDAO ERROR in addProduct: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Update product
    public boolean updateProduct(Product product) {
        String sql = "UPDATE products SET " +
                    "name = ?, description = ?, price = ?, stock = ?, " +
                    "category_id = ?, image_url = ?, is_active = ? " +
                    "WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, product.getName());
            stmt.setString(2, product.getDescription());
            stmt.setDouble(3, product.getPrice());
            stmt.setInt(4, product.getStock());
            stmt.setInt(5, product.getCategoryId());
            stmt.setString(6, product.getImageUrl());
            stmt.setBoolean(7, product.isActive());
            stmt.setInt(8, product.getId());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("ProductDAO ERROR in updateProduct: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Delete product (soft delete)
    public boolean deleteProduct(int id) {
        String sql = "UPDATE products SET is_active = FALSE WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("ProductDAO ERROR in deleteProduct: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Update stock after sale
    public boolean updateStock(int productId, int quantity) {
        String sql = "UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, quantity);
            stmt.setInt(2, productId);
            stmt.setInt(3, quantity);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("ProductDAO ERROR in updateStock: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Update product stock by code
    public boolean updateProductStock(String code, int quantity) {
        String sql = "UPDATE products SET stock = stock - ? WHERE code = ? AND stock >= ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, quantity);
            stmt.setString(2, code);
            stmt.setInt(3, quantity);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("ProductDAO ERROR in updateProductStock: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Search products
    public List<Product> searchProducts(String keyword) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.*, c.name as category_name " +
                    "FROM products p " +
                    "LEFT JOIN categories c ON p.category_id = c.id " +
                    "WHERE p.is_active = TRUE AND " +
                    "(p.code LIKE ? OR p.name LIKE ? OR p.description LIKE ?) " +
                    "ORDER BY p.name";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            String searchTerm = "%" + keyword + "%";
            stmt.setString(1, searchTerm);
            stmt.setString(2, searchTerm);
            stmt.setString(3, searchTerm);
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                products.add(mapResultSetToProduct(rs));
            }
        } catch (SQLException e) {
            System.err.println("ProductDAO ERROR in searchProducts: " + e.getMessage());
            e.printStackTrace();
        }
        return products;
    }
    
    // Map ResultSet to Product object
    private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setId(rs.getInt("id"));
        product.setCode(rs.getString("code"));
        product.setName(rs.getString("name"));
        product.setDescription(rs.getString("description"));
        product.setPrice(rs.getDouble("price"));
        product.setStock(rs.getInt("stock"));
        product.setCategoryId(rs.getInt("category_id"));
        product.setCategoryName(rs.getString("category_name"));
        product.setImageUrl(rs.getString("image_url"));
        product.setActive(rs.getBoolean("is_active"));
        product.setCreatedAt(rs.getTimestamp("created_at"));
        product.setUpdatedAt(rs.getTimestamp("updated_at"));
        return product;
    }
    
    // Get all categories
    public List<String> getAllCategories() {
        List<String> categories = new ArrayList<>();
        String sql = "SELECT name FROM categories ORDER BY name";
        
        try (Connection conn = DatabaseConfig.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                categories.add(rs.getString("name"));
            }
        } catch (SQLException e) {
            System.err.println("ProductDAO ERROR in getAllCategories: " + e.getMessage());
            e.printStackTrace();
        }
        return categories;
    }
    
    // Get category ID by name
    public int getCategoryIdByName(String categoryName) {
        String sql = "SELECT id FROM categories WHERE name = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, categoryName);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("id");
            }
        } catch (SQLException e) {
            System.err.println("ProductDAO ERROR in getCategoryIdByName: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
}