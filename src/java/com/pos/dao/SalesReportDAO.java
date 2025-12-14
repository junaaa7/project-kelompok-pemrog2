package com.pos.dao;

import com.pos.config.DatabaseConfig;
import java.sql.*;
import java.util.*;

public class SalesReportDAO {
    
    /**
     * Get daily sales summary
     */
    public Map<String, Object> getDailySalesSummary(String date) {
        Map<String, Object> summary = new HashMap<>();
        String sql = "SELECT " +
                     "COUNT(*) as total_transactions, " +
                     "SUM(total_amount) as total_sales, " +
                     "AVG(total_amount) as avg_sale, " +
                     "MIN(total_amount) as min_sale, " +
                     "MAX(total_amount) as max_sale, " +
                     "SUM(cash) as total_cash " +
                     "FROM transactions " +
                     "WHERE DATE(transaction_date) = ? AND status = 'completed'";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, date);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    summary.put("totalTransactions", rs.getInt("total_transactions"));
                    summary.put("totalSales", rs.getDouble("total_sales"));
                    summary.put("avgSale", rs.getDouble("avg_sale"));
                    summary.put("minSale", rs.getDouble("min_sale"));
                    summary.put("maxSale", rs.getDouble("max_sale"));
                    summary.put("totalCash", rs.getDouble("total_cash"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return summary;
    }
    
    /**
     * Get daily sales data (hourly breakdown)
     */
    public List<Map<String, Object>> getDailySalesData(String date) {
        List<Map<String, Object>> salesData = new ArrayList<>();
        String sql = "SELECT " +
                     "HOUR(transaction_date) as hour, " +
                     "COUNT(*) as transactions, " +
                     "SUM(total_amount) as sales, " +
                     "AVG(total_amount) as avg_sale " +
                     "FROM transactions " +
                     "WHERE DATE(transaction_date) = ? AND status = 'completed' " +
                     "GROUP BY HOUR(transaction_date) " +
                     "ORDER BY hour";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, date);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("hour", rs.getInt("hour"));
                    data.put("transactions", rs.getInt("transactions"));
                    data.put("sales", rs.getDouble("sales"));
                    data.put("avg_sale", rs.getDouble("avg_sale"));
                    salesData.add(data);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return salesData;
    }
    
    /**
     * Get sales by date range
     */
    public List<Map<String, Object>> getSalesByDateRange(String startDate, String endDate) {
        List<Map<String, Object>> salesData = new ArrayList<>();
        String sql = "SELECT " +
                     "DATE(transaction_date) as date, " +
                     "COUNT(*) as transactions, " +
                     "SUM(total_amount) as sales, " +
                     "AVG(total_amount) as avg_sale " +
                     "FROM transactions " +
                     "WHERE DATE(transaction_date) BETWEEN ? AND ? " +
                     "AND status = 'completed' " +
                     "GROUP BY DATE(transaction_date) " +
                     "ORDER BY date DESC";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, startDate);
            stmt.setString(2, endDate);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("date", rs.getDate("date"));
                    data.put("transactions", rs.getInt("transactions"));
                    data.put("sales", rs.getDouble("sales"));
                    data.put("avg_sale", rs.getDouble("avg_sale"));
                    salesData.add(data);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return salesData;
    }
    
    /**
     * Get top selling products
     */
    public List<Map<String, Object>> getTopSellingProducts(String startDate, String endDate, int limit) {
        List<Map<String, Object>> products = new ArrayList<>();
        String sql = "SELECT " +
                     "p.code, p.name, c.name as category, " +
                     "SUM(td.quantity) as total_sold, " +
                     "SUM(td.subtotal) as total_revenue, " +
                     "AVG(td.price) as avg_price " +
                     "FROM transaction_details td " +
                     "JOIN products p ON td.product_id = p.id " +
                     "LEFT JOIN categories c ON p.category_id = c.id " +
                     "JOIN transactions t ON td.transaction_id = t.id " +
                     "WHERE DATE(t.transaction_date) BETWEEN ? AND ? " +
                     "AND t.status = 'completed' " +
                     "GROUP BY p.id " +
                     "ORDER BY total_sold DESC " +
                     "LIMIT ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, startDate);
            stmt.setString(2, endDate);
            stmt.setInt(3, limit);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> product = new HashMap<>();
                    product.put("code", rs.getString("code"));
                    product.put("name", rs.getString("name"));
                    product.put("category", rs.getString("category"));
                    product.put("total_sold", rs.getInt("total_sold"));
                    product.put("total_revenue", rs.getDouble("total_revenue"));
                    product.put("avg_price", rs.getDouble("avg_price"));
                    products.add(product);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return products;
    }
    
    /**
     * Get cashier performance
     */
    public List<Map<String, Object>> getCashierPerformance(String startDate, String endDate) {
        List<Map<String, Object>> performance = new ArrayList<>();
        String sql = "SELECT " +
                     "u.username, u.full_name, " +
                     "COUNT(t.id) as total_transactions, " +
                     "SUM(t.total_amount) as total_sales, " +
                     "AVG(t.total_amount) as avg_sale " +
                     "FROM transactions t " +
                     "JOIN users u ON t.user_id = u.id " +
                     "WHERE DATE(t.transaction_date) BETWEEN ? AND ? " +
                     "AND t.status = 'completed' " +
                     "AND u.role = 'cashier' " +
                     "GROUP BY u.id " +
                     "ORDER BY total_sales DESC";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, startDate);
            stmt.setString(2, endDate);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> cashier = new HashMap<>();
                    cashier.put("username", rs.getString("username"));
                    cashier.put("full_name", rs.getString("full_name"));
                    cashier.put("total_transactions", rs.getInt("total_transactions"));
                    cashier.put("total_sales", rs.getDouble("total_sales"));
                    cashier.put("avg_sale", rs.getDouble("avg_sale"));
                    performance.add(cashier);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return performance;
    }
    
    /**
     * Get detailed transactions
     */
    public List<Map<String, Object>> getDetailedTransactions(String startDate, String endDate, String cashierId) {
        List<Map<String, Object>> transactions = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT t.transaction_code, t.transaction_date, " +
            "COALESCE(c.name, 'Umum') as customer_name, " +
            "u.full_name as cashier_name, " +
            "t.total_amount, t.payment_method, t.status, " +
            "(SELECT COUNT(*) FROM transaction_details td WHERE td.transaction_id = t.id) as items " +
            "FROM transactions t " +
            "LEFT JOIN customers c ON t.customer_id = c.id " +
            "JOIN users u ON t.user_id = u.id " +
            "WHERE DATE(t.transaction_date) BETWEEN ? AND ? " +
            "AND t.status = 'completed' "
        );
        
        if (cashierId != null && !cashierId.trim().isEmpty()) {
            sql.append("AND t.user_id = ? ");
        }
        
        sql.append("ORDER BY t.transaction_date DESC");
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            stmt.setString(1, startDate);
            stmt.setString(2, endDate);
            
            if (cashierId != null && !cashierId.trim().isEmpty()) {
                stmt.setInt(3, Integer.parseInt(cashierId));
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> transaction = new HashMap<>();
                    transaction.put("transaction_code", rs.getString("transaction_code"));
                    transaction.put("transaction_date", rs.getTimestamp("transaction_date"));
                    transaction.put("customer_name", rs.getString("customer_name"));
                    transaction.put("cashier_name", rs.getString("cashier_name"));
                    transaction.put("total_amount", rs.getDouble("total_amount"));
                    transaction.put("payment_method", rs.getString("payment_method"));
                    transaction.put("status", rs.getString("status"));
                    transaction.put("items", rs.getInt("items"));
                    transactions.add(transaction);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (NumberFormatException e) {
            System.err.println("Invalid cashier ID: " + cashierId);
        }
        
        return transactions;
    }
    
    /**
     * Get sales by category
     */
    public List<Map<String, Object>> getSalesByCategory(String startDate, String endDate) {
        List<Map<String, Object>> categories = new ArrayList<>();
        String sql = "SELECT " +
                     "COALESCE(c.name, 'Tanpa Kategori') as category, " +
                     "SUM(td.quantity) as items_sold, " +
                     "SUM(td.subtotal) as revenue " +
                     "FROM transaction_details td " +
                     "JOIN products p ON td.product_id = p.id " +
                     "LEFT JOIN categories c ON p.category_id = c.id " +
                     "JOIN transactions t ON td.transaction_id = t.id " +
                     "WHERE DATE(t.transaction_date) BETWEEN ? AND ? " +
                     "AND t.status = 'completed' " +
                     "GROUP BY c.id " +
                     "ORDER BY revenue DESC";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, startDate);
            stmt.setString(2, endDate);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> category = new HashMap<>();
                    category.put("category", rs.getString("category"));
                    category.put("items_sold", rs.getInt("items_sold"));
                    category.put("revenue", rs.getDouble("revenue"));
                    categories.add(category);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return categories;
    }
    
    // === CASHIER-SPECIFIC METHODS ===
    
    /**
     * Get transactions for specific cashier
     */
    public List<Map<String, Object>> getCashierTransactions(int cashierId, String date) {
        List<Map<String, Object>> transactions = new ArrayList<>();
        String sql = "SELECT t.*, c.name as customer_name, u.username as cashier_username " +
                     "FROM transactions t " +
                     "LEFT JOIN customers c ON t.customer_id = c.id " +
                     "JOIN users u ON t.user_id = u.id " +
                     "WHERE DATE(t.transaction_date) = ? AND t.user_id = ? " +
                     "ORDER BY t.transaction_date DESC";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, date);
            stmt.setInt(2, cashierId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> transaction = new HashMap<>();
                    transaction.put("id", rs.getInt("id"));
                    transaction.put("transaction_code", rs.getString("transaction_code"));
                    transaction.put("transaction_date", rs.getTimestamp("transaction_date"));
                    transaction.put("customer_name", rs.getString("customer_name"));
                    transaction.put("cashier_username", rs.getString("cashier_username"));
                    transaction.put("total_amount", rs.getDouble("total_amount"));
                    transaction.put("cash", rs.getDouble("cash"));
                    transaction.put("change_amount", rs.getDouble("change_amount"));
                    transaction.put("payment_method", rs.getString("payment_method"));
                    transaction.put("status", rs.getString("status"));
                    transaction.put("notes", rs.getString("notes"));
                    
                    transactions.add(transaction);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting cashier transactions: " + e.getMessage());
            e.printStackTrace();
        }
        
        return transactions;
    }
    
    /**
     * Get daily summary for specific cashier
     */
    public Map<String, Object> getCashierDailySummary(int cashierId, String date) {
        Map<String, Object> summary = new HashMap<>();
        String sql = "SELECT " +
                     "COUNT(*) as total_transactions, " +
                     "SUM(total_amount) as total_sales, " +
                     "AVG(total_amount) as avg_sale, " +
                     "MIN(total_amount) as min_sale, " +
                     "MAX(total_amount) as max_sale, " +
                     "SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_count, " +
                     "SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_count " +
                     "FROM transactions " +
                     "WHERE DATE(transaction_date) = ? AND user_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, date);
            stmt.setInt(2, cashierId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    summary.put("total_transactions", rs.getInt("total_transactions"));
                    summary.put("total_sales", rs.getDouble("total_sales"));
                    summary.put("avg_sale", rs.getDouble("avg_sale"));
                    summary.put("min_sale", rs.getDouble("min_sale"));
                    summary.put("max_sale", rs.getDouble("max_sale"));
                    summary.put("completed_count", rs.getInt("completed_count"));
                    summary.put("cancelled_count", rs.getInt("cancelled_count"));
                } else {
                    // Return zero values if no transactions
                    summary.put("total_transactions", 0);
                    summary.put("total_sales", 0.0);
                    summary.put("avg_sale", 0.0);
                    summary.put("min_sale", 0.0);
                    summary.put("max_sale", 0.0);
                    summary.put("completed_count", 0);
                    summary.put("cancelled_count", 0);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting cashier daily summary: " + e.getMessage());
            e.printStackTrace();
            // Return zero values on error
            summary.put("total_transactions", 0);
            summary.put("total_sales", 0.0);
            summary.put("avg_sale", 0.0);
            summary.put("min_sale", 0.0);
            summary.put("max_sale", 0.0);
            summary.put("completed_count", 0);
            summary.put("cancelled_count", 0);
        }
        
        return summary;
    }
    
    /**
     * Get cashier's top selling products
     */
    public List<Map<String, Object>> getCashierTopProducts(int cashierId, String startDate, String endDate) {
        List<Map<String, Object>> products = new ArrayList<>();
        String sql = "SELECT p.code, p.name, c.name as category, " +
                     "SUM(td.quantity) as total_sold, " +
                     "SUM(td.subtotal) as total_revenue " +
                     "FROM transaction_details td " +
                     "JOIN products p ON td.product_id = p.id " +
                     "LEFT JOIN categories c ON p.category_id = c.id " +
                     "JOIN transactions t ON td.transaction_id = t.id " +
                     "WHERE DATE(t.transaction_date) BETWEEN ? AND ? " +
                     "AND t.user_id = ? AND t.status = 'completed' " +
                     "GROUP BY p.id " +
                     "ORDER BY total_sold DESC " +
                     "LIMIT 10";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, startDate);
            stmt.setString(2, endDate);
            stmt.setInt(3, cashierId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> product = new HashMap<>();
                    product.put("code", rs.getString("code"));
                    product.put("name", rs.getString("name"));
                    product.put("category", rs.getString("category"));
                    product.put("total_sold", rs.getInt("total_sold"));
                    product.put("total_revenue", rs.getDouble("total_revenue"));
                    
                    products.add(product);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting cashier top products: " + e.getMessage());
            e.printStackTrace();
        }
        
        return products;
    }
    
    /**
     * Get transaction details for a specific transaction
     */
    public List<Map<String, Object>> getTransactionDetails(String transactionCode) {
        List<Map<String, Object>> details = new ArrayList<>();
        String sql = "SELECT td.*, p.code as product_code, p.name as product_name, " +
                     "p.price as unit_price " +
                     "FROM transaction_details td " +
                     "JOIN products p ON td.product_id = p.id " +
                     "JOIN transactions t ON td.transaction_id = t.id " +
                     "WHERE t.transaction_code = ? " +
                     "ORDER BY td.id";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, transactionCode);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> detail = new HashMap<>();
                    detail.put("product_code", rs.getString("product_code"));
                    detail.put("product_name", rs.getString("product_name"));
                    detail.put("quantity", rs.getInt("quantity"));
                    detail.put("price", rs.getDouble("price"));
                    detail.put("subtotal", rs.getDouble("subtotal"));
                    detail.put("unit_price", rs.getDouble("unit_price"));
                    
                    details.add(detail);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting transaction details: " + e.getMessage());
            e.printStackTrace();
        }
        
        return details;
    }
}