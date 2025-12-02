/*
 * DatabaseConfig.java - Konfigurasi koneksi database
 */
package com.pos.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConfig {
    // Ganti dengan konfigurasi database Anda
    private static final String URL = "jdbc:mysql://localhost:3306/pos_web";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "";
    
    static {
        try {
            // Load MySQL driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("DatabaseConfig: MySQL Driver loaded successfully");
        } catch (ClassNotFoundException e) {
            System.err.println("DatabaseConfig ERROR: MySQL Driver not found");
            e.printStackTrace();
        }
    }
    
    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
            System.out.println("DatabaseConfig: Connection established successfully");
            return conn;
        } catch (SQLException e) {
            System.err.println("DatabaseConfig ERROR: Failed to connect to database");
            System.err.println("URL: " + URL);
            System.err.println("Username: " + USERNAME);
            throw e;
        }
    }
    
    // Test connection
    public static void testConnection() {
        try (Connection conn = getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("DatabaseConfig: Test connection SUCCESS");
            }
        } catch (SQLException e) {
            System.err.println("DatabaseConfig: Test connection FAILED");
            e.printStackTrace();
        }
    }
}