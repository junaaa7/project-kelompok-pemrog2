/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.servlet;

import com.pos.dao.SalesReportDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 *
 * @author ARJUNA.R.PUTRA
 */

@WebServlet("/SalesReportServlet")
public class SalesReportServlet extends HttpServlet {
    
    private final SalesReportDAO salesDAO = new SalesReportDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Object user = session.getAttribute("user");
        
        // Check if user is admin
        if (user == null || !user.toString().contains("admin")) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cashier = request.getParameter("cashier");
        
        // Default to today if no dates provided
        if (startDate == null || startDate.isEmpty()) {
            startDate = new java.sql.Date(System.currentTimeMillis()).toString();
        }
        if (endDate == null || endDate.isEmpty()) {
            endDate = new java.sql.Date(System.currentTimeMillis()).toString();
        }
        
        try {
            if ("getDaily".equals(action)) {
                getDailyReport(request, response, startDate);
            } else if ("getRange".equals(action)) {
                getRangeReport(request, response, startDate, endDate);
            } else if ("getTopProducts".equals(action)) {
                getTopProducts(request, response, startDate, endDate);
            } else if ("getCashierPerformance".equals(action)) {
                getCashierPerformance(request, response, startDate, endDate);
            } else if ("getTransactions".equals(action)) {
                getTransactions(request, response, startDate, endDate, cashier);
            } else if ("getCategories".equals(action)) {
                getCategoriesReport(request, response, startDate, endDate);
            } else {
                // Default: get daily report
                getDailyReport(request, response, startDate);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error generating report: " + e.getMessage());
            request.getRequestDispatcher("sales-report.jsp").forward(request, response);
        }
    }
    
    private void getDailyReport(HttpServletRequest request, HttpServletResponse response, String date) 
            throws ServletException, IOException {
        
        Map<String, Object> summary = salesDAO.getDailySalesSummary(date);
        List<Map<String, Object>> hourlySales = salesDAO.getDailySalesData(date);
        
        request.setAttribute("summary", summary);
        request.setAttribute("hourlySales", hourlySales);
        request.setAttribute("reportDate", date);
        request.setAttribute("reportType", "daily");
        
        request.getRequestDispatcher("sales-report.jsp").forward(request, response);
    }
    
    private void getRangeReport(HttpServletRequest request, HttpServletResponse response, 
                              String startDate, String endDate) 
            throws ServletException, IOException {
        
        List<Map<String, Object>> salesByDate = salesDAO.getSalesByDateRange(startDate, endDate);
        
        // Calculate totals
        double totalSales = 0;
        int totalTransactions = 0;
        
        for (Map<String, Object> sale : salesByDate) {
            totalSales += (Double) sale.get("sales");
            totalTransactions += (Integer) sale.get("transactions");
        }
        
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalSales", totalSales);
        summary.put("totalTransactions", totalTransactions);
        summary.put("avgSale", totalTransactions > 0 ? totalSales / totalTransactions : 0);
        
        request.setAttribute("salesByDate", salesByDate);
        request.setAttribute("summary", summary);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("reportType", "range");
        
        request.getRequestDispatcher("sales-report.jsp").forward(request, response);
    }
    
    private void getTopProducts(HttpServletRequest request, HttpServletResponse response,
                               String startDate, String endDate) 
            throws ServletException, IOException {
        
        List<Map<String, Object>> topProducts = salesDAO.getTopSellingProducts(startDate, endDate, 10);
        
        request.setAttribute("topProducts", topProducts);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("reportType", "topProducts");
        
        request.getRequestDispatcher("sales-report.jsp").forward(request, response);
    }
    
    private void getCashierPerformance(HttpServletRequest request, HttpServletResponse response,
                                      String startDate, String endDate) 
            throws ServletException, IOException {
        
        List<Map<String, Object>> performance = salesDAO.getCashierPerformance(startDate, endDate);
        
        request.setAttribute("performance", performance);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("reportType", "cashierPerformance");
        
        request.getRequestDispatcher("sales-report.jsp").forward(request, response);
    }
    
    private void getTransactions(HttpServletRequest request, HttpServletResponse response,
                                String startDate, String endDate, String cashier) 
            throws ServletException, IOException {
        
        List<Map<String, Object>> transactions = salesDAO.getDetailedTransactions(startDate, endDate, cashier);
        
        request.setAttribute("transactions", transactions);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("cashier", cashier);
        request.setAttribute("reportType", "transactions");
        
        request.getRequestDispatcher("sales-report.jsp").forward(request, response);
    }
    
    private void getCategoriesReport(HttpServletRequest request, HttpServletResponse response,
                                    String startDate, String endDate) 
            throws ServletException, IOException {
        
        List<Map<String, Object>> categories = salesDAO.getSalesByCategory(startDate, endDate);
        
        request.setAttribute("categories", categories);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("reportType", "categories");
        
        request.getRequestDispatcher("sales-report.jsp").forward(request, response);
    }
}