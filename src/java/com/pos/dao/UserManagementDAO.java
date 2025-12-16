/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.dao;

import com.pos.config.DatabaseConfig;
import com.pos.model.User;
import java.sql.*;
import java.util.*;

/**
 *
 * @author ARJUNA.R.PUTRA
 */

public class UserManagementDAO {
    
    public List<User> getUsersByRole(String role) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT id, username, full_name, email, role FROM users WHERE role = ? AND is_active = 1 ORDER BY full_name";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            System.out.println("Executing getUsersByRole for role: " + role);
            pstmt.setString(1, role);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                users.add(user);
            }
            System.out.println("Found " + users.size() + " users with role: " + role);
            
        } catch (SQLException e) {
            System.err.println("Error in getUsersByRole: " + e.getMessage());
            e.printStackTrace();
        }
        
        return users;
    }
    
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT id, username, password, full_name, email, role, is_active, created_at, updated_at " +
                     "FROM users ORDER BY created_at DESC";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            System.out.println("Executing getAllUsers...");
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setActive(rs.getBoolean("is_active"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setUpdatedAt(rs.getTimestamp("updated_at"));
                users.add(user);
            }
            System.out.println("Found " + users.size() + " total users");
            
        } catch (SQLException e) {
            System.err.println("Error in getAllUsers: " + e.getMessage());
            e.printStackTrace();
        }
        
        return users;
    }
    
    // HAPUS SALAH SATU VERSION DARI getUserById - KEEP ONLY ONE
    
    public User getUserById(int userId) {
        String sql = "SELECT id, username, full_name, email, role, is_active FROM users WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            System.out.println("Executing getUserById for ID: " + userId);
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setActive(rs.getBoolean("is_active"));
                System.out.println("Found user: " + user.getUsername());
                return user;
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getUserById: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("User not found for ID: " + userId);
        return null;
    }
    
    public boolean addUser(User user) {
        String sql = "INSERT INTO users (username, password, full_name, email, role) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            System.out.println("Adding new user: " + user.getUsername());
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getFullName());
            pstmt.setString(4, user.getEmail());
            pstmt.setString(5, user.getRole());
            
            int result = pstmt.executeUpdate();
            System.out.println("Add user result: " + (result > 0 ? "Success" : "Failed"));
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in addUser: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateUser(User user) {
        String sql = "UPDATE users SET full_name = ?, email = ?, role = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            System.out.println("Updating user ID: " + user.getId());
            pstmt.setString(1, user.getFullName());
            pstmt.setString(2, user.getEmail());
            pstmt.setString(3, user.getRole());
            pstmt.setBoolean(4, user.isActive());
            pstmt.setInt(5, user.getId());
            
            int result = pstmt.executeUpdate();
            System.out.println("Update user result: " + (result > 0 ? "Success" : "Failed"));
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in updateUser: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateUserWithPassword(User user) {
        String sql = "UPDATE users SET full_name = ?, email = ?, role = ?, is_active = ?, password = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            System.out.println("Updating user with password for ID: " + user.getId());
            pstmt.setString(1, user.getFullName());
            pstmt.setString(2, user.getEmail());
            pstmt.setString(3, user.getRole());
            pstmt.setBoolean(4, user.isActive());
            pstmt.setString(5, user.getPassword());
            pstmt.setInt(6, user.getId());
            
            int result = pstmt.executeUpdate();
            System.out.println("Update user with password result: " + (result > 0 ? "Success" : "Failed"));
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in updateUserWithPassword: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean deleteUser(int id) {
        String sql = "DELETE FROM users WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            System.out.println("Deleting user ID: " + id);
            pstmt.setInt(1, id);
            
            int result = pstmt.executeUpdate();
            System.out.println("Delete user result: " + (result > 0 ? "Success" : "Failed"));
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in deleteUser: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean toggleUserStatus(int id, boolean isActive) {
        String sql = "UPDATE users SET is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            System.out.println("Toggling user status ID: " + id + " to: " + isActive);
            pstmt.setBoolean(1, isActive);
            pstmt.setInt(2, id);
            
            int result = pstmt.executeUpdate();
            System.out.println("Toggle status result: " + (result > 0 ? "Success" : "Failed"));
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in toggleUserStatus: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Untuk login
    public User authenticate(String username, String password) {
        String sql = "SELECT id, username, password, full_name, email, role, is_active FROM users WHERE username = ? AND password = ? AND is_active = 1";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            System.out.println("Authenticating user: " + username);
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setActive(rs.getBoolean("is_active"));
                System.out.println("Authentication successful for: " + username);
                return user;
            }
            
        } catch (SQLException e) {
            System.err.println("Error in authenticate: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("Authentication failed for: " + username);
        return null;
    }
    
    // Check if username exists
    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) as count FROM users WHERE username = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error in usernameExists: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
}