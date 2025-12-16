/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.model;

/**
 *
 * @author ARJUNA.R.PUTRA
 */

import java.sql.Timestamp;
import java.util.Date;

public class User {
    private int id;
    private String username;
    private String password;
    private String fullName;
    private String email;
    private String role;
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Constructor
    public User() {}
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    // Untuk display di JSP, format tanggal
    public String getFormattedCreatedAt() {
        if (createdAt == null) return "-";
        return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(createdAt);
    }
    
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    
    // Helper methods
    public String getStatusText() {
        return isActive ? "Aktif" : "Nonaktif";
    }
    
    public String getRoleText() {
        return "admin".equals(role) ? "Administrator" : "Kasir";
    }
}