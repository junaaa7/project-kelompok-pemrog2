/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.dao;

import com.pos.config.DatabaseConfig;
import com.pos.model.User;
import java.sql.*;

/**
 *
 * @author ARJUNA.R.PUTRA
 */

public class UserDAO {
    
    public User authenticate(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND is_active = 1";
        
        System.out.println("LOGIN ATTEMPT - Username: " + username + ", Password: " + password);
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String dbPassword = rs.getString("password");
                System.out.println("DB Password: " + dbPassword);
                System.out.println("Password match: " + password.equals(dbPassword));
                
                // PLAIN TEXT COMPARISON (no hashing)
                if (password.equals(dbPassword)) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setFullName(rs.getString("full_name"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    
                    System.out.println("LOGIN SUCCESS - User: " + user.getFullName() + ", Role: " + user.getRole());
                    return user;
                }
            } else {
                System.out.println("USER NOT FOUND: " + username);
            }
            
        } catch (SQLException e) {
            System.err.println("DATABASE ERROR: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("LOGIN FAILED for user: " + username);
        return null;
    }
    
    public boolean isUsernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public boolean register(User user) {
        String sql = "INSERT INTO users (username, password, full_name, email, role) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // SIMPAN PASSWORD PLAIN TEXT (no hashing)
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getPassword()); // Plain text
            pstmt.setString(3, user.getFullName());
            pstmt.setString(4, user.getEmail());
            pstmt.setString(5, user.getRole());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
        }
        return false;
    }
}