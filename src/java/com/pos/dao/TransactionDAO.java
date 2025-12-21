/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.dao;

import java.sql.*;
import java.util.*;
import com.pos.config.DatabaseConfig;

/**
 *
 * @author ARJUNA.R.PUTRA
 */


public class TransactionDAO {
    
    /**
     * Get transaction by transaction code
     * @param transactionCode
     */
    public Map<String, Object> getTransactionByCode(String transactionCode) {
        Map<String, Object> transaction = new HashMap<>();
        String sql = "SELECT * FROM transactions WHERE transaction_code = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, transactionCode);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                transaction.put("id", rs.getInt("id"));
                transaction.put("transaction_code", rs.getString("transaction_code"));
                transaction.put("transaction_date", rs.getTimestamp("transaction_date"));
                transaction.put("cashier_id", rs.getInt("cashier_id"));
                transaction.put("customer_name", rs.getString("customer_name"));
                transaction.put("total_amount", rs.getDouble("total_amount"));
                transaction.put("cash_amount", rs.getDouble("cash_amount"));
                transaction.put("payment_method", rs.getString("payment_method"));
                transaction.put("status", rs.getString("status"));
                transaction.put("notes", rs.getString("notes"));
                transaction.put("created_at", rs.getTimestamp("created_at"));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("Error getting transaction by code: " + transactionCode);
        }
        
        return transaction;
    }
    
    public List<Map<String, Object>> getTransactionItems(String transactionCode) {
        List<Map<String, Object>> items = new ArrayList<>();
        String sql = "SELECT ti.*, p.name as product_name, p.barcode " +
                     "FROM transaction_items ti " +
                     "JOIN products p ON ti.product_id = p.id " +
                     "WHERE ti.transaction_code = ? " +
                     "ORDER BY ti.id";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, transactionCode);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", rs.getInt("id"));
                item.put("transaction_code", rs.getString("transaction_code"));
                item.put("product_id", rs.getInt("product_id"));
                item.put("product_name", rs.getString("product_name"));
                item.put("barcode", rs.getString("barcode"));
                item.put("quantity", rs.getInt("quantity"));
                item.put("price", rs.getDouble("price"));
                item.put("subtotal", rs.getDouble("subtotal"));
                items.add(item);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("Error getting transaction items for: " + transactionCode);
        }
        
        return items;
    }

    public Map<String, Object> getTransactionByCodeAndCashier(String transactionCode, int cashierId) {
        Map<String, Object> transaction = new HashMap<>();
        String sql = "SELECT * FROM transactions WHERE transaction_code = ? AND cashier_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, transactionCode);
            pstmt.setInt(2, cashierId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                transaction.put("id", rs.getInt("id"));
                transaction.put("transaction_code", rs.getString("transaction_code"));
                transaction.put("transaction_date", rs.getTimestamp("transaction_date"));
                transaction.put("cashier_id", rs.getInt("cashier_id"));
                transaction.put("customer_name", rs.getString("customer_name"));
                transaction.put("total_amount", rs.getDouble("total_amount"));
                transaction.put("cash_amount", rs.getDouble("cash_amount"));
                transaction.put("payment_method", rs.getString("payment_method"));
                transaction.put("status", rs.getString("status"));
                transaction.put("notes", rs.getString("notes"));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return transaction;
    }
}