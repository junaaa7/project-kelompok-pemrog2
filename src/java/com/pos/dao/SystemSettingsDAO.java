// SystemSettingsDAO.java
package com.pos.dao;

import com.pos.config.DatabaseConfig;
import com.pos.model.SystemSettings;
import java.sql.*;

public class SystemSettingsDAO {
    
    public SystemSettings getSettings() {
        SystemSettings settings = null;
        String sql = "SELECT * FROM system_settings WHERE id = 1";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                settings = new SystemSettings();
                settings.setId(rs.getInt("id"));
                settings.setStoreName(rs.getString("store_name"));
                settings.setStoreAddress(rs.getString("store_address"));
                settings.setPhone(rs.getString("phone"));
                settings.setEmail(rs.getString("email"));
                settings.setCurrency(rs.getString("currency"));
                settings.setDateFormat(rs.getString("date_format"));
                settings.setAutoPrint(rs.getBoolean("auto_print"));
                settings.setShowStockAlert(rs.getBoolean("show_stock_alert"));
                
                // Receipt settings
                settings.setReceiptHeader(rs.getString("receipt_header"));
                settings.setReceiptFooter(rs.getString("receipt_footer"));
                settings.setReceiptWidth(rs.getInt("receipt_width"));
                settings.setReceiptFontSize(rs.getString("receipt_font_size"));
                settings.setReceiptCopies(rs.getInt("receipt_copies"));
                
                // Tax settings
                settings.setTaxEnabled(rs.getBoolean("tax_enabled"));
                settings.setTaxPercentage(rs.getDouble("tax_percentage"));
                settings.setTaxName(rs.getString("tax_name"));
                
                // Discount settings
                settings.setMemberDiscount(rs.getDouble("member_discount"));
                settings.setMinDiscountTransaction(rs.getDouble("min_discount_transaction"));
                
                // Backup settings
                settings.setBackupFrequency(rs.getString("backup_frequency"));
                
                Time backupTime = rs.getTime("backup_time");
                if (backupTime != null) {
                    settings.setBackupTime(backupTime.toString().substring(0, 5));
                }
                
                settings.setBackupKeepDays(rs.getInt("backup_keep_days"));
                settings.setCloudBackup(rs.getBoolean("cloud_backup"));
            }
            
        } catch (SQLException e) {
            System.err.println("SystemSettingsDAO Error: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Return default settings if not found
        if (settings == null) {
            settings = new SystemSettings();
        }
        
        return settings;
    }
    
    public boolean updateGeneralSettings(SystemSettings settings) {
        String sql = "UPDATE system_settings SET "
                   + "store_name = ?, store_address = ?, phone = ?, email = ?, "
                   + "currency = ?, date_format = ?, auto_print = ?, show_stock_alert = ?, "
                   + "updated_at = CURRENT_TIMESTAMP "
                   + "WHERE id = 1";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, settings.getStoreName());
            stmt.setString(2, settings.getStoreAddress());
            stmt.setString(3, settings.getPhone());
            stmt.setString(4, settings.getEmail());
            stmt.setString(5, settings.getCurrency());
            stmt.setString(6, settings.getDateFormat());
            stmt.setBoolean(7, settings.isAutoPrint());
            stmt.setBoolean(8, settings.isShowStockAlert());
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("SystemSettingsDAO Error (updateGeneralSettings): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateReceiptSettings(SystemSettings settings) {
        String sql = "UPDATE system_settings SET "
                   + "receipt_header = ?, receipt_footer = ?, receipt_width = ?, "
                   + "receipt_font_size = ?, receipt_copies = ?, "
                   + "updated_at = CURRENT_TIMESTAMP "
                   + "WHERE id = 1";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, settings.getReceiptHeader());
            stmt.setString(2, settings.getReceiptFooter());
            stmt.setInt(3, settings.getReceiptWidth());
            stmt.setString(4, settings.getReceiptFontSize());
            stmt.setInt(5, settings.getReceiptCopies());
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("SystemSettingsDAO Error (updateReceiptSettings): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateTaxSettings(SystemSettings settings) {
        String sql = "UPDATE system_settings SET "
                   + "tax_enabled = ?, tax_percentage = ?, tax_name = ?, "
                   + "member_discount = ?, min_discount_transaction = ?, "
                   + "updated_at = CURRENT_TIMESTAMP "
                   + "WHERE id = 1";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setBoolean(1, settings.isTaxEnabled());
            stmt.setDouble(2, settings.getTaxPercentage());
            stmt.setString(3, settings.getTaxName());
            stmt.setDouble(4, settings.getMemberDiscount());
            stmt.setDouble(5, settings.getMinDiscountTransaction());
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("SystemSettingsDAO Error (updateTaxSettings): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateBackupSettings(SystemSettings settings) {
        String sql = "UPDATE system_settings SET "
                   + "backup_frequency = ?, backup_time = ?, backup_keep_days = ?, cloud_backup = ?, "
                   + "updated_at = CURRENT_TIMESTAMP "
                   + "WHERE id = 1";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, settings.getBackupFrequency());
            
            // Convert time string to SQL Time
            if (settings.getBackupTime() != null && !settings.getBackupTime().isEmpty()) {
                stmt.setTime(2, Time.valueOf(settings.getBackupTime() + ":00"));
            } else {
                stmt.setTime(2, Time.valueOf("02:00:00"));
            }
            
            stmt.setInt(3, settings.getBackupKeepDays());
            stmt.setBoolean(4, settings.isCloudBackup());
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("SystemSettingsDAO Error (updateBackupSettings): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Initialize settings if not exists
    public boolean initializeSettings() {
        String checkSql = "SELECT COUNT(*) FROM system_settings WHERE id = 1";
        String insertSql = "INSERT INTO system_settings (id) VALUES (1)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             Statement stmt = conn.createStatement()) {
            
            ResultSet rs = stmt.executeQuery(checkSql);
            if (rs.next() && rs.getInt(1) == 0) {
                // No settings found, insert default
                int rowsAffected = stmt.executeUpdate(insertSql);
                return rowsAffected > 0;
            }
            return true; // Settings already exist
            
        } catch (SQLException e) {
            System.err.println("SystemSettingsDAO Error (initializeSettings): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}