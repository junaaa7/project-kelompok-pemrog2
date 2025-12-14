<%-- 
    Document   : sales-report
    Created on : 2 Dec 2025, 13.06.21
    Author     : ARJUNA.R.PUTRA
--%>

<%@page import="java.util.ArrayList"%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.pos.model.User" %>
<%@ page import="com.pos.dao.SalesReportDAO" %>
<%@ page import="com.pos.dao.UserManagementDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    System.out.println("=== SALES REPORT JSP STARTED ===");
    
    String errorMessage = null;
    try {
        // Check session and authorization
        User user = (User) session.getAttribute("user");
        System.out.println("Session user: " + (user != null ? user.getUsername() : "NULL"));
        
        if (user == null) {
            System.out.println("User not logged in, redirecting to login");
            response.sendRedirect("login.jsp");
            return;
        }
        
        if (!"admin".equals(user.getRole())) {
            System.out.println("User is not admin, role: " + user.getRole());
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }
        
        System.out.println("User authorized, initializing DAOs...");
        
        // Initialize DAOs
        SalesReportDAO salesDAO = new SalesReportDAO();
        UserManagementDAO userDAO = new UserManagementDAO();
        
        // Get parameters with validation
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cashier = request.getParameter("cashier");
        String reportType = request.getParameter("reportType");
        
        System.out.println("Parameters received:");
        System.out.println("  startDate: " + startDate);
        System.out.println("  endDate: " + endDate);
        System.out.println("  cashier: " + cashier);
        System.out.println("  reportType: " + reportType);
        
        // Default to today if not provided
        if (startDate == null || startDate.trim().isEmpty()) {
            startDate = new java.sql.Date(System.currentTimeMillis()).toString();
            System.out.println("startDate set to default: " + startDate);
        }
        
        if (endDate == null || endDate.trim().isEmpty()) {
            endDate = new java.sql.Date(System.currentTimeMillis()).toString();
            System.out.println("endDate set to default: " + endDate);
        }
        
        if (reportType == null || reportType.trim().isEmpty()) {
            reportType = "daily";
            System.out.println("reportType set to default: " + reportType);
        }
        
        if (cashier == null) {
            cashier = "";
        }
        
        // Formatting
        NumberFormat currencyFormat = NumberFormat.getCurrencyInstance();
        currencyFormat.setMaximumFractionDigits(0);
        
        // Get cashiers list
        List<User> cashiers = new ArrayList<>();
        try {
            System.out.println("Getting cashiers list...");
            cashiers = userDAO.getUsersByRole("cashier");
            System.out.println("Cashiers count: " + cashiers.size());
        } catch (Exception e) {
            System.err.println("Error getting cashiers: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Get data based on report type
        Map<String, Object> summary = new HashMap<>();
        List<Map<String, Object>> reportData = new ArrayList<>();
        
        try {
            System.out.println("Getting report data for type: " + reportType);
            
            if ("daily".equals(reportType)) {
                summary = salesDAO.getDailySalesSummary(startDate);
                reportData = salesDAO.getDailySalesData(startDate);
            } else if ("range".equals(reportType)) {
                reportData = salesDAO.getSalesByDateRange(startDate, endDate);
                // Calculate totals
                double totalSales = 0;
                int totalTransactions = 0;
                for (Map<String, Object> sale : reportData) {
                    totalSales += sale.get("sales") != null ? ((Number) sale.get("sales")).doubleValue() : 0;
                    totalTransactions += sale.get("transactions") != null ? ((Number) sale.get("transactions")).intValue() : 0;
                }
                summary.put("totalSales", totalSales);
                summary.put("totalTransactions", totalTransactions);
                summary.put("avgSale", totalTransactions > 0 ? totalSales / totalTransactions : 0);
            } else if ("topProducts".equals(reportType)) {
                reportData = salesDAO.getTopSellingProducts(startDate, endDate, 10);
            } else if ("cashierPerformance".equals(reportType)) {
                reportData = salesDAO.getCashierPerformance(startDate, endDate);
            } else if ("transactions".equals(reportType)) {
                reportData = salesDAO.getDetailedTransactions(startDate, endDate, cashier);
            } else if ("categories".equals(reportType)) {
                reportData = salesDAO.getSalesByCategory(startDate, endDate);
            }
            
            System.out.println("Report data count: " + reportData.size());
            
        } catch (Exception e) {
            errorMessage = "Error loading report data: " + e.getMessage();
            System.err.println("ERROR in report generation: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("=== SALES REPORT JSP COMPLETED ===");
        
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Laporan Penjualan - POS System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .card-title { font-size: 0.9rem; }
        .display-6 { font-size: 1.5rem; font-weight: bold; }
        .progress { height: 20px; }
        .sidebar { background-color: #f8f9fa; min-height: 100vh; }
        .list-group-item.active { background-color: #0d6efd; border-color: #0d6efd; }
        .debug-info { font-size: 0.8rem; background-color: #f8f9fa; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <!-- Debug Info -->
    <div class="debug-info d-none">
        <strong>Debug Info:</strong><br>
        User: <%= user != null ? user.getUsername() : "null" %><br>
        Role: <%= user != null ? user.getRole() : "null" %><br>
        Start Date: <%= startDate %><br>
        End Date: <%= endDate %><br>
        Report Type: <%= reportType %><br>
        Cashiers Count: <%= cashiers.size() %><br>
        Data Count: <%= reportData != null ? reportData.size() : 0 %>
    </div>
    
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">
                <i class="fas fa-store"></i> POS System
            </a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    Welcome, <%= user.getFullName() != null ? user.getFullName() : user.getUsername() %> (Admin)
                </span>
                <a class="btn btn-light btn-sm me-2" href="dashboard.jsp">
                    <i class="fas fa-tachometer-alt"></i> Dashboard
                </a>
                <a class="btn btn-light btn-sm" href="logout">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>
    </nav>
    
    <div class="container-fluid mt-4">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-3 col-lg-2 sidebar">
                <div class="list-group mt-3">
                    <a href="dashboard.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-tachometer-alt"></i> Dashboard
                    </a>
                    <a href="user-management.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-users"></i> Kelola User
                    </a>
                    <a href="product-management.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-box"></i> Kelola Produk
                    </a>
                    <a href="category-management.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-tags"></i> Kelola Kategori
                    </a>
                    <a href="sales-report.jsp" class="list-group-item list-group-item-action active">
                        <i class="fas fa-chart-bar"></i> Laporan Penjualan
                    </a>
                    <a href="system-settings.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-cog"></i> Pengaturan Sistem
                    </a>
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="col-md-9 col-lg-10">
                <h2 class="mb-4"><i class="fas fa-chart-bar"></i> Laporan Penjualan</h2>
                
                <!-- Error Message -->
                <% if (errorMessage != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-triangle"></i> <%= errorMessage %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>
                
                <!-- Filter Form -->
                <div class="card mb-4">
                    <div class="card-header bg-light">
                        <h5 class="mb-0"><i class="fas fa-filter"></i> Filter Laporan</h5>
                    </div>
                    <div class="card-body">
                        <form method="get" action="sales-report.jsp" class="row g-3" id="filterForm">
                            <div class="col-md-3">
                                <label class="form-label">Dari Tanggal</label>
                                <input type="date" class="form-control" name="startDate" 
                                       value="<%= startDate %>" required>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Sampai Tanggal</label>
                                <input type="date" class="form-control" name="endDate" 
                                       value="<%= endDate %>" required>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Kasir</label>
                                <select class="form-control" name="cashier">
                                    <option value="">Semua Kasir</option>
                                    <% 
                                    if (cashiers != null && !cashiers.isEmpty()) {
                                        for (User cashierUser : cashiers) { 
                                            String fullName = cashierUser.getFullName();
                                            if (fullName != null) {
                                    %>
                                    <option value="<%= cashierUser.getId() %>" 
                                            <%= String.valueOf(cashierUser.getId()).equals(cashier) ? "selected" : "" %>>
                                        <%= fullName %>
                                    </option>
                                    <% 
                                            }
                                        }
                                    } else {
                                    %>
                                    <option value="">Tidak ada kasir</option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Jenis Laporan</label>
                                <select class="form-control" name="reportType" id="reportType">
                                    <option value="daily" <%= "daily".equals(reportType) ? "selected" : "" %>>Laporan Harian</option>
                                    <option value="range" <%= "range".equals(reportType) ? "selected" : "" %>>Laporan Periode</option>
                                    <option value="topProducts" <%= "topProducts".equals(reportType) ? "selected" : "" %>>Produk Terlaris</option>
                                    <option value="cashierPerformance" <%= "cashierPerformance".equals(reportType) ? "selected" : "" %>>Performance Kasir</option>
                                    <option value="transactions" <%= "transactions".equals(reportType) ? "selected" : "" %>>Detail Transaksi</option>
                                    <option value="categories" <%= "categories".equals(reportType) ? "selected" : "" %>>Penjualan Per Kategori</option>
                                </select>
                            </div>
                            <div class="col-12">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-search"></i> Tampilkan Laporan
                                </button>
                                <button type="button" class="btn btn-secondary" onclick="resetFilter()">
                                    <i class="fas fa-redo"></i> Reset Filter
                                </button>
                                <button type="button" class="btn btn-info" onclick="toggleDebug()">
                                    <i class="fas fa-bug"></i> Debug
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
                
                <!-- Loading Spinner -->
                <div id="loadingSpinner" class="text-center d-none">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-2">Loading report data...</p>
                </div>
                
                <!-- Summary Cards -->
                <% if (summary != null && !summary.isEmpty()) { %>
                <div class="row mb-4" id="summaryCards">
                    <% if (summary.containsKey("totalSales")) { %>
                    <div class="col-md-3 mb-3">
                        <div class="card bg-primary text-white shadow">
                            <div class="card-body text-center">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h5 class="card-title">Total Penjualan</h5>
                                        <p class="card-text display-6 mb-0">
                                            <%= currencyFormat.format(summary.get("totalSales")) %>
                                        </p>
                                    </div>
                                    <i class="fas fa-shopping-cart fa-2x opacity-50"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                    
                    <% if (summary.containsKey("totalTransactions")) { %>
                    <div class="col-md-3 mb-3">
                        <div class="card bg-success text-white shadow">
                            <div class="card-body text-center">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h5 class="card-title">Total Transaksi</h5>
                                        <p class="card-text display-6 mb-0">
                                            <%= summary.get("totalTransactions") %>
                                        </p>
                                    </div>
                                    <i class="fas fa-receipt fa-2x opacity-50"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                    
                    <% if (summary.containsKey("avgSale")) { %>
                    <div class="col-md-3 mb-3">
                        <div class="card bg-warning text-white shadow">
                            <div class="card-body text-center">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h5 class="card-title">Rata-rata/Transaksi</h5>
                                        <p class="card-text display-6 mb-0">
                                            <%= currencyFormat.format(summary.get("avgSale")) %>
                                        </p>
                                    </div>
                                    <i class="fas fa-chart-line fa-2x opacity-50"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                    
                    <% if (summary.containsKey("totalCash") && summary.get("totalCash") != null) { %>
                    <div class="col-md-3 mb-3">
                        <div class="card bg-info text-white shadow">
                            <div class="card-body text-center">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h5 class="card-title">Total Tunai</h5>
                                        <p class="card-text display-6 mb-0">
                                            <%= currencyFormat.format(summary.get("totalCash")) %>
                                        </p>
                                    </div>
                                    <i class="fas fa-money-bill-wave fa-2x opacity-50"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
                
                <!-- Report Data -->
                <div class="card shadow" id="reportData">
                    <div class="card-header bg-light d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">
                            <% if ("daily".equals(reportType)) { %>
                                <i class="fas fa-calendar-day text-primary"></i> Laporan Harian - <%= startDate %>
                            <% } else if ("range".equals(reportType)) { %>
                                <i class="fas fa-calendar-alt text-primary"></i> Laporan Periode <%= startDate %> - <%= endDate %>
                            <% } else if ("topProducts".equals(reportType)) { %>
                                <i class="fas fa-star text-warning"></i> 10 Produk Terlaris
                            <% } else if ("cashierPerformance".equals(reportType)) { %>
                                <i class="fas fa-trophy text-success"></i> Performance Kasir
                            <% } else if ("transactions".equals(reportType)) { %>
                                <i class="fas fa-receipt text-info"></i> Detail Transaksi
                            <% } else if ("categories".equals(reportType)) { %>
                                <i class="fas fa-tags text-danger"></i> Penjualan Per Kategori
                            <% } %>
                        </h5>
                        <span class="badge bg-primary">
                            <%= reportData != null ? reportData.size() : 0 %> Data
                        </span>
                    </div>
                    <div class="card-body">
                        <% if (reportData == null || reportData.isEmpty()) { %>
                        <div class="text-center py-5">
                            <i class="fas fa-chart-bar fa-4x text-muted mb-3"></i>
                            <h5 class="text-muted">Tidak ada data untuk ditampilkan</h5>
                            <p class="text-muted">Pilih filter lain atau coba tanggal yang berbeda</p>
                            <p class="text-muted small">Tanggal: <%= startDate %> sampai <%= endDate %></p>
                        </div>
                        <% } else { %>
                        <div class="table-responsive">
                            <table class="table table-hover table-striped" id="reportTable">
                                <thead class="table-dark">
                                    <% if ("daily".equals(reportType) || "range".equals(reportType)) { %>
                                    <tr>
                                        <th>Tanggal</th>
                                        <th class="text-center">Transaksi</th>
                                        <th class="text-end">Penjualan</th>
                                        <th class="text-end">Rata-rata</th>
                                    </tr>
                                    <% } else if ("topProducts".equals(reportType)) { %>
                                    <tr>
                                        <th>#</th>
                                        <th>Kode</th>
                                        <th>Nama Produk</th>
                                        <th>Kategori</th>
                                        <th class="text-center">Terjual</th>
                                        <th class="text-end">Pendapatan</th>
                                    </tr>
                                    <% } else if ("cashierPerformance".equals(reportType)) { %>
                                    <tr>
                                        <th>#</th>
                                        <th>Username</th>
                                        <th>Nama Kasir</th>
                                        <th class="text-center">Transaksi</th>
                                        <th class="text-end">Penjualan</th>
                                        <th class="text-end">Rata-rata</th>
                                    </tr>
                                    <% } else if ("transactions".equals(reportType)) { %>
                                    <tr>
                                        <th>Kode Transaksi</th>
                                        <th>Tanggal</th>
                                        <th>Customer</th>
                                        <th>Kasir</th>
                                        <th class="text-end">Total</th>
                                        <th class="text-center">Pembayaran</th>
                                        <th class="text-center">Items</th>
                                    </tr>
                                    <% } else if ("categories".equals(reportType)) { %>
                                    <tr>
                                        <th>Kategori</th>
                                        <th class="text-center">Items Terjual</th>
                                        <th class="text-end">Pendapatan</th>
                                        <th>Persentase</th>
                                    </tr>
                                    <% } %>
                                </thead>
                                <tbody>
                                    <% 
                                    int index = 1;
                                    double totalRevenueAll = 0;
                                    
                                    if ("categories".equals(reportType)) {
                                        for (Map<String, Object> data : reportData) {
                                            Double revenue = data.get("revenue") != null ? 
                                                ((Number) data.get("revenue")).doubleValue() : 0;
                                            totalRevenueAll += revenue;
                                        }
                                    }
                                    
                                    for (Map<String, Object> data : reportData) { 
                                    %>
                                        <% if ("daily".equals(reportType) || "range".equals(reportType)) { %>
                                        <tr>
                                            <td><%= data.get("date") != null ? data.get("date") : "-" %></td>
                                            <td class="text-center"><%= data.get("transactions") != null ? data.get("transactions") : 0 %></td>
                                            <td class="text-end"><%= currencyFormat.format(data.get("sales") != null ? data.get("sales") : 0) %></td>
                                            <td class="text-end"><%= currencyFormat.format(data.get("avg_sale") != null ? data.get("avg_sale") : 0) %></td>
                                        </tr>
                                        <% } else if ("topProducts".equals(reportType)) { %>
                                        <tr>
                                            <td class="text-center"><%= index %></td>
                                            <td><%= data.get("code") != null ? data.get("code") : "-" %></td>
                                            <td><%= data.get("name") != null ? data.get("name") : "-" %></td>
                                            <td><%= data.get("category") != null ? data.get("category") : "-" %></td>
                                            <td class="text-center"><%= data.get("total_sold") != null ? data.get("total_sold") : 0 %></td>
                                            <td class="text-end"><%= currencyFormat.format(data.get("total_revenue") != null ? data.get("total_revenue") : 0) %></td>
                                        </tr>
                                        <% } else if ("cashierPerformance".equals(reportType)) { %>
                                        <tr>
                                            <td class="text-center"><%= index %></td>
                                            <td><%= data.get("username") != null ? data.get("username") : "-" %></td>
                                            <td><%= data.get("full_name") != null ? data.get("full_name") : "-" %></td>
                                            <td class="text-center"><%= data.get("total_transactions") != null ? data.get("total_transactions") : 0 %></td>
                                            <td class="text-end"><%= currencyFormat.format(data.get("total_sales") != null ? data.get("total_sales") : 0) %></td>
                                            <td class="text-end"><%= currencyFormat.format(data.get("avg_sale") != null ? data.get("avg_sale") : 0) %></td>
                                        </tr>
                                        <% } else if ("transactions".equals(reportType)) { %>
                                        <tr>
                                            <td>
                                                <a href="#" class="text-decoration-none">
                                                    <%= data.get("transaction_code") != null ? data.get("transaction_code") : "-" %>
                                                </a>
                                            </td>
                                            <td><%= data.get("transaction_date") != null ? data.get("transaction_date") : "-" %></td>
                                            <td><%= data.get("customer_name") != null ? data.get("customer_name") : "Umum" %></td>
                                            <td><%= data.get("cashier_name") != null ? data.get("cashier_name") : "-" %></td>
                                            <td class="text-end"><%= currencyFormat.format(data.get("total_amount") != null ? data.get("total_amount") : 0) %></td>
                                            <td class="text-center">
                                                <span class="badge bg-<%= "cash".equals(data.get("payment_method")) ? "success" : "primary" %>">
                                                    <%= data.get("payment_method") != null ? data.get("payment_method") : "-" %>
                                                </span>
                                            </td>
                                            <td class="text-center"><%= data.get("items") != null ? data.get("items") : 0 %></td>
                                        </tr>
                                        <% } else if ("categories".equals(reportType)) { %>
                                        <tr>
                                            <td><%= data.get("category") != null ? data.get("category") : "-" %></td>
                                            <td class="text-center"><%= data.get("items_sold") != null ? data.get("items_sold") : 0 %></td>
                                            <td class="text-end"><%= currencyFormat.format(data.get("revenue") != null ? data.get("revenue") : 0) %></td>
                                            <td>
                                                <% 
                                                Double revenue = data.get("revenue") != null ? 
                                                    ((Number) data.get("revenue")).doubleValue() : 0;
                                                double percentage = totalRevenueAll > 0 ? (revenue / totalRevenueAll) * 100 : 0;
                                                %>
                                                <div class="d-flex align-items-center">
                                                    <div class="progress flex-grow-1 me-2" style="height: 20px;">
                                                        <div class="progress-bar" role="progressbar" 
                                                             style="width: <%= percentage %>%"
                                                             aria-valuenow="<%= percentage %>" 
                                                             aria-valuemin="0" 
                                                             aria-valuemax="100">
                                                        </div>
                                                    </div>
                                                    <span class="text-nowrap"><%= String.format("%.1f", percentage) %>%</span>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } %>
                                    <% 
                                        index++;
                                    } 
                                    %>
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- Export Button -->
                        <div class="mt-4 d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted">
                                    <i class="fas fa-info-circle"></i> 
                                    Menampilkan <%= reportData.size() %> data
                                </span>
                            </div>
                            <div>
                                <button class="btn btn-success" onclick="exportReport()">
                                    <i class="fas fa-file-excel"></i> Export Excel
                                </button>
                                <button class="btn btn-primary" onclick="printReport()">
                                    <i class="fas fa-print"></i> Cetak
                                </button>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Footer -->
    <footer class="footer mt-5 py-3 bg-light">
        <div class="container-fluid text-center">
            <span class="text-muted">
                &copy; 2025 POS System - Laporan Penjualan v1.0 | 
                Generated on: <%= new java.util.Date() %>
            </span>
        </div>
    </footer>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Set today as default date
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Page loaded, setting default dates...');
            const today = new Date().toISOString().split('T')[0];
            const startDateInput = document.querySelector('input[name="startDate"]');
            const endDateInput = document.querySelector('input[name="endDate"]');
            
            if (startDateInput && (!startDateInput.value || startDateInput.value === '')) {
                startDateInput.value = today;
                console.log('Set startDate to: ' + today);
            }
            if (endDateInput && (!endDateInput.value || endDateInput.value === '')) {
                endDateInput.value = today;
                console.log('Set endDate to: ' + today);
            }
            
            // Show loading spinner on form submit
            document.getElementById('filterForm').addEventListener('submit', function() {
                document.getElementById('loadingSpinner').classList.remove('d-none');
                document.getElementById('summaryCards').classList.add('d-none');
                document.getElementById('reportData').classList.add('d-none');
            });
        });
        
        function resetFilter() {
            console.log('Resetting filter...');
            const today = new Date().toISOString().split('T')[0];
            document.querySelector('input[name="startDate"]').value = today;
            document.querySelector('input[name="endDate"]').value = today;
            document.querySelector('select[name="cashier"]').value = '';
            document.querySelector('select[name="reportType"]').value = 'daily';
        }
        
        function toggleDebug() {
            const debugInfo = document.querySelector('.debug-info');
            if (debugInfo.classList.contains('d-none')) {
                debugInfo.classList.remove('d-none');
            } else {
                debugInfo.classList.add('d-none');
            }
        }
        
        function exportReport() {
            const startDate = document.querySelector('input[name="startDate"]').value;
            const endDate = document.querySelector('input[name="endDate"]').value;
            const reportType = document.querySelector('select[name="reportType"]').value;
            
            alert('Fitur export Excel akan segera tersedia.\n' + 
                  'Start Date: ' + startDate + '\n' +
                  'End Date: ' + endDate + '\n' +
                  'Report Type: ' + reportType);
        }
        
        function printReport() {
            window.print();
        }
    </script>
</body>
</html>
<%
    } catch (Exception e) {
        System.err.println("=== FATAL ERROR in sales-report.jsp ===");
        e.printStackTrace();
        System.err.println("Error message: " + e.getMessage());
        out.println("<div class='alert alert-danger'><h3>Fatal Error</h3><p>" + e.getMessage() + "</p><pre>" + e.toString() + "</pre></div>");
    }
%>