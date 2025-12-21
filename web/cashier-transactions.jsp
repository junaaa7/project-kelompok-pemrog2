<%-- 
    Document   : cashier-transactions
    Created on : 3 Dec 2025, 10.00.00
    Author     : ARJUNA.R.PUTRA
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.pos.model.User" %>
<%@ page import="com.pos.dao.SalesReportDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    // Check authentication
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Only cashier can access this page
    if (!"cashier".equals(user.getRole())) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    SalesReportDAO salesDAO = new SalesReportDAO();
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    SimpleDateFormat displayFormat = new SimpleDateFormat("dd MMMM yyyy");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance();
    currencyFormat.setMaximumFractionDigits(0);
    
    // Get parameters
    String dateParam = request.getParameter("date");
    String statusParam = request.getParameter("status");
    
    // Default to today if not provided
    Date today = new Date();
    if (dateParam == null || dateParam.trim().isEmpty()) {
        dateParam = new java.sql.Date(today.getTime()).toString();
    }
    
    // Parse date for display
    Date selectedDate = new SimpleDateFormat("yyyy-MM-dd").parse(dateParam);
    String displayDate = displayFormat.format(selectedDate);
    
    // Get cashier's transactions
    List<Map<String, Object>> transactions = salesDAO.getCashierTransactions(
        user.getId(), 
        dateParam
    );
    
    // Filter by status if specified
    if (statusParam != null && !statusParam.trim().isEmpty()) {
        transactions.removeIf(trans -> !statusParam.equals(trans.get("status")));
    }
    
    // Calculate summary
    double dailyTotal = 0;
    int completedCount = 0;
    int cancelledCount = 0;
    
    for (Map<String, Object> trans : transactions) {
        double amount = trans.get("total_amount") != null ? 
            ((Number) trans.get("total_amount")).doubleValue() : 0;
        dailyTotal += amount;
        
        String status = (String) trans.get("status");
        if ("completed".equals(status)) {
            completedCount++;
        } else if ("cancelled".equals(status)) {
            cancelledCount++;
        }
    }
    
    int transactionCount = transactions.size();
    double averageTransaction = transactionCount > 0 ? dailyTotal / transactionCount : 0;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Riwayat Transaksi - POS System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            min-height: 100vh;
        }
        .sidebar {
            background-color: #ffffff;
            min-height: calc(100vh - 56px);
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            border-right: 1px solid #dee2e6;
        }
        .main-content {
            margin-top: 56px;
            padding-top: 1rem;
        }
        .navbar {
            position: fixed;
            top: 0;
            width: 100%;
            z-index: 1000;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .list-group-item.active {
            background-color: #0d6efd;
            border-color: #0d6efd;
        }
        .stat-card {
            border-radius: 10px;
            border: none;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-3px);
        }
        .transaction-row {
            border-left: 4px solid #28a745;
            margin-bottom: 10px;
            border-radius: 5px;
            background: white;
            padding: 15px;
            transition: all 0.3s;
        }
        .transaction-row:hover {
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            transform: translateX(5px);
        }
        .transaction-row.cancelled {
            border-left-color: #dc3545;
            opacity: 0.8;
        }
        .print-only {
            display: none;
        }
        @media print {
            .no-print {
                display: none !important;
            }
            .print-only {
                display: block !important;
            }
            .transaction-row {
                border: 1px solid #ddd;
                margin-bottom: 5px;
                page-break-inside: avoid;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary no-print">
        <div class="container-fluid">
            <a class="navbar-brand" href="dashboard.jsp">
                <i class="fas fa-store"></i> POS System
            </a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    <i class="fas fa-user-circle"></i> <%= user.getFullName() %> (Kasir)
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
    
    <!-- Print Header -->
    <div class="print-only container-fluid text-center mb-4">
        <h2>LAPORAN TRANSAKSI KASIR</h2>
        <h4><%= user.getFullName() %> - <%= displayDate %></h4>
        <hr>
    </div>
    
    <div class="container-fluid">
        <div class="row main-content">
            <!-- Sidebar -->
            <div class="col-md-3 col-lg-2 sidebar no-print">
                <div class="list-group mt-3">
                    <a href="dashboard.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-tachometer-alt"></i> Dashboard
                    </a>
                    <a href="index.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-cash-register"></i> Transaksi
                    </a>
                    <a href="cart.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-shopping-cart"></i> Keranjang
                    </a>
                    <a href="cashier-transactions.jsp" class="list-group-item list-group-item-action active">
                        <i class="fas fa-history"></i> Riwayat Transaksi
                    </a>
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="col-md-9 col-lg-10 px-md-4 pt-3">
                <!-- Page Header -->
                <div class="d-flex justify-content-between align-items-center mb-4 no-print">
                    <h2><i class="fas fa-history"></i> Riwayat Transaksi Saya</h2>
                    <div class="btn-group">
                        <button class="btn btn-outline-primary" onclick="printReport()">
                            <i class="fas fa-print"></i> Cetak Laporan
                        </button>
                        <button class="btn btn-outline-success" onclick="exportToExcel()">
                            <i class="fas fa-file-excel"></i> Export Excel
                        </button>
                    </div>
                </div>
                
                <!-- Date Filter -->
                <div class="card mb-4 no-print">
                    <div class="card-header bg-light">
                        <h5 class="mb-0"><i class="fas fa-filter"></i> Filter Transaksi</h5>
                    </div>
                    <div class="card-body">
                        <form method="get" action="cashier-transactions.jsp" class="row g-3">
                            <div class="col-md-4">
                                <label class="form-label">Tanggal</label>
                                <input type="date" class="form-control" name="date" 
                                       value="<%= dateParam %>" max="<%= new java.sql.Date(today.getTime()) %>">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Status</label>
                                <select class="form-control" name="status">
                                    <option value="">Semua Status</option>
                                    <option value="completed" <%= "completed".equals(statusParam) ? "selected" : "" %>>Selesai</option>
                                    <option value="cancelled" <%= "cancelled".equals(statusParam) ? "selected" : "" %>>Dibatalkan</option>
                                </select>
                            </div>
                            <div class="col-md-4 d-flex align-items-end">
                                <div class="btn-group w-100">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-filter"></i> Filter
                                    </button>
                                    <a href="cashier-transactions.jsp" class="btn btn-secondary">
                                        <i class="fas fa-redo"></i> Reset
                                    </a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
                
                <!-- Summary Cards -->
                <div class="row mb-4">
                    <div class="col-md-3 mb-3">
                        <div class="card stat-card text-white bg-primary">
                            <div class="card-body text-center">
                                <h5 class="card-title">Total Transaksi</h5>
                                <p class="card-text display-6 mb-0"><%= transactionCount %></p>
                                <p class="card-text mt-2 small">
                                    <%= displayDate %>
                                </p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card stat-card text-white bg-success">
                            <div class="card-body text-center">
                                <h5 class="card-title">Total Pendapatan</h5>
                                <p class="card-text display-6 mb-0"><%= currencyFormat.format(dailyTotal) %></p>
                                <p class="card-text mt-2 small">
                                    Transaksi Selesai: <%= completedCount %>
                                </p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card stat-card text-white bg-info">
                            <div class="card-body text-center">
                                <h5 class="card-title">Rata-rata/Transaksi</h5>
                                <p class="card-text display-6 mb-0"><%= currencyFormat.format(averageTransaction) %></p>
                                <p class="card-text mt-2 small">
                                    <%= transactionCount > 0 ? "Per transaksi" : "Tidak ada transaksi" %>
                                </p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card stat-card text-white bg-warning">
                            <div class="card-body text-center">
                                <h5 class="card-title">Transaksi Dibatalkan</h5>
                                <p class="card-text display-6 mb-0"><%= cancelledCount %></p>
                                <p class="card-text mt-2 small">
                                    <%= cancelledCount > 0 ? "Perlu perhatian" : "Tidak ada yang dibatalkan" %>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Transactions List -->
                <div class="card">
                    <div class="card-header bg-light d-flex justify-content-between align-items-center no-print">
                        <h5 class="mb-0">
                            <i class="fas fa-list"></i> Daftar Transaksi 
                            <span class="badge bg-secondary ms-2"><%= transactionCount %> transaksi</span>
                        </h5>
                        <div class="text-muted">
                            <i class="fas fa-calendar-alt"></i> <%= displayDate %>
                        </div>
                    </div>
                    
                    <div class="card-body">
                        <% if (transactions.isEmpty()) { %>
                        <div class="text-center py-5">
                            <i class="fas fa-receipt fa-4x text-muted mb-3"></i>
                            <h5 class="text-muted">Tidak ada transaksi</h5>
                            <p class="text-muted">
                                <%= dateParam.equals(new java.sql.Date(today.getTime()).toString()) ? 
                                    "Belum ada transaksi hari ini" : 
                                    "Tidak ada transaksi pada tanggal " + displayDate %>
                            </p>
                            <% if (dateParam.equals(new java.sql.Date(today.getTime()).toString())) { %>
                            <a href="index.jsp" class="btn btn-primary">
                                <i class="fas fa-cash-register"></i> Mulai Transaksi Pertama
                            </a>
                            <% } else { %>
                            <a href="cashier-transactions.jsp" class="btn btn-secondary">
                                <i class="fas fa-calendar-day"></i> Lihat Transaksi Hari Ini
                            </a>
                            <% } %>
                        </div>
                        <% } else { %>
                        
                        <!-- Print Summary -->
                        <div class="print-only mb-4">
                            <table class="table table-bordered">
                                <tr>
                                    <td><strong>Kasir:</strong> <%= user.getFullName() %></td>
                                    <td><strong>Tanggal:</strong> <%= displayDate %></td>
                                    <td><strong>Total Transaksi:</strong> <%= transactionCount %></td>
                                    <td><strong>Total Pendapatan:</strong> <%= currencyFormat.format(dailyTotal) %></td>
                                </tr>
                            </table>
                        </div>
                        
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th>#</th>
                                        <th>Kode Transaksi</th>
                                        <th>Waktu</th>
                                        <th>Customer</th>
                                        <th class="text-end">Total</th>
                                        <th>Pembayaran</th>
                                        <th>Status</th>
                                        <th class="no-print">Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% 
                                    int index = 1;
                                    for (Map<String, Object> trans : transactions) { 
                                        String status = (String) trans.get("status");
                                        String statusClass = "completed".equals(status) ? "bg-success" : "bg-danger";
                                        String statusText = "completed".equals(status) ? "Selesai" : "Dibatalkan";
                                        String rowClass = "cancelled".equals(status) ? "cancelled" : "";
                                        
                                        String paymentMethod = (String) trans.get("payment_method");
                                        String paymentBadgeClass = "cash".equalsIgnoreCase(paymentMethod) ? "bg-success" : 
                                                                 "debit".equalsIgnoreCase(paymentMethod) ? "bg-primary" :
                                                                 "credit".equalsIgnoreCase(paymentMethod) ? "bg-info" :
                                                                 "transfer".equalsIgnoreCase(paymentMethod) ? "bg-warning" : "bg-secondary";
                                    %>
                                    <tr class="<%= rowClass %>">
                                        <td><%= index++ %></td>
                                        <td>
                                            <strong><%= trans.get("transaction_code") %></strong>
                                        </td>
                                        <td>
                                            <%= dateFormat.format(trans.get("transaction_date")) %>
                                        </td>
                                        <td>
                                            <%= trans.get("customer_name") != null ? trans.get("customer_name") : "Umum" %>
                                        </td>
                                        <td class="text-end fw-bold">
                                            <%= currencyFormat.format(trans.get("total_amount")) %>
                                        </td>
                                        <td>
                                            <span class="badge <%= paymentBadgeClass %>">
                                                <%= paymentMethod != null ? paymentMethod.toUpperCase() : "CASH" %>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge <%= statusClass %>">
                                                <%= statusText %>
                                            </span>
                                        </td>
                                        <td class="no-print">
                                            <div class="btn-group btn-group-sm">
                                                <button class="btn btn-outline-primary" 
                                                        onclick="viewTransactionDetails('<%= trans.get("transaction_code") %>')"
                                                        title="Lihat Detail">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button class="btn btn-outline-success" 
                                                        onclick="printReceipt('<%= trans.get("transaction_code") %>')"
                                                        title="Cetak Ulang Struk">
                                                    <i class="fas fa-print"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                                <tfoot class="table-secondary">
                                    <tr>
                                        <td colspan="4" class="text-end fw-bold">TOTAL:</td>
                                        <td class="text-end fw-bold text-success">
                                            <%= currencyFormat.format(dailyTotal) %>
                                        </td>
                                        <td colspan="3"></td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                        <% } %>
                    </div>
                    
                    <div class="card-footer text-muted no-print">
                        <div class="row">
                            <div class="col-md-6">
                                <small>
                                    <i class="fas fa-info-circle"></i> 
                                    Menampilkan <%= transactionCount %> transaksi
                                </small>
                            </div>
                            <div class="col-md-6 text-end">
                                <small>
                                    Terakhir diperbarui: <%= new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()) %>
                                </small>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Cashier Performance -->
                <% if (!transactions.isEmpty()) { %>
                <div class="card mt-4 no-print">
                    <div class="card-header bg-light">
                        <h5 class="mb-0"><i class="fas fa-chart-line"></i> Performance Hari Ini</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-8">
                                <div class="progress mb-3" style="height: 30px;">
                                    <div class="progress-bar bg-success" 
                                         style="width: <%= transactionCount > 0 ? (completedCount * 100.0 / transactionCount) : 0 %>%">
                                        Selesai: <%= completedCount %> (<%= transactionCount > 0 ? String.format("%.0f", completedCount * 100.0 / transactionCount) : 0 %>%)
                                    </div>
                                    <div class="progress-bar bg-danger" 
                                         style="width: <%= transactionCount > 0 ? (cancelledCount * 100.0 / transactionCount) : 0 %>%">
                                        Dibatalkan: <%= cancelledCount %> (<%= transactionCount > 0 ? String.format("%.0f", cancelledCount * 100.0 / transactionCount) : 0 %>%)
                                    </div>
                                </div>
                                <p class="mb-0 small text-muted">
                                    <i class="fas fa-chart-pie"></i> 
                                    Rasio transaksi selesai vs dibatalkan
                                </p>
                            </div>
                            <div class="col-md-4">
                                <div class="text-center">
                                    <h3 class="text-primary"><%= currencyFormat.format(dailyTotal) %></h3>
                                    <p class="mb-0 small">Total pendapatan hari ini</p>
                                    <p class="mb-0 small text-muted">
                                        Rata-rata: <%= currencyFormat.format(averageTransaction) %> per transaksi
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>
    
    <!-- Transaction Details Modal -->
    <div class="modal fade no-print" id="transactionModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-receipt"></i> Detail Transaksi
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="transactionDetails">
                    <div class="text-center py-4">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-2">Memuat detail transaksi...</p>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="fas fa-times"></i> Tutup
                    </button>
                    <button type="button" class="btn btn-primary" id="printModalReceiptBtn" onclick="printModalReceipt()">
                        <i class="fas fa-print"></i> Cetak Struk
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let currentTransactionCode = '';
        
        function viewTransactionDetails(transactionCode) {
            currentTransactionCode = transactionCode;
            document.getElementById('transactionDetails').innerHTML = `
                <div class="text-center py-4">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-2">Memuat detail transaksi...</p>
                </div>
            `;
            
            // Simulate loading from server
            setTimeout(() => {
                loadTransactionDetails(transactionCode);
            }, 500);
            
            const modal = new bootstrap.Modal(document.getElementById('transactionModal'));
            modal.show();
        }
        
        function loadTransactionDetails(transactionCode) {
            const details = `
                <h5>Transaksi: ${transactionCode}</h5>
                <div class="row mb-3">
                    <div class="col-md-6">
                        <p><strong>Tanggal:</strong> <%= new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()) %></p>
                        <p><strong>Kasir:</strong> <%= user.getFullName() %></p>
                        <p><strong>Customer:</strong> Umum</p>
                    </div>
                    <div class="col-md-6">
                        <p><strong>Status:</strong> <span class="badge bg-success">Selesai</span></p>
                        <p><strong>Pembayaran:</strong> <span class="badge bg-success">CASH</span></p>
                        <p><strong>No. Struk:</strong> ${transactionCode}</p>
                    </div>
                </div>
                
                <hr>
                
                <h6><i class="fas fa-shopping-cart"></i> Items:</h6>
                <div class="table-responsive">
                    <table class="table table-sm">
                        <thead class="table-light">
                            <tr>
                                <th>Produk</th>
                                <th class="text-center">Qty</th>
                                <th class="text-end">Harga</th>
                                <th class="text-end">Subtotal</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Nasi Goreng Spesial</td>
                                <td class="text-center">2</td>
                                <td class="text-end">Rp 25,000</td>
                                <td class="text-end">Rp 50,000</td>
                            </tr>
                            <tr>
                                <td>Es Teh Manis</td>
                                <td class="text-center">5</td>
                                <td class="text-end">Rp 5,000</td>
                                <td class="text-end">Rp 25,000</td>
                            </tr>
                            <tr>
                                <td>Keripik Kentang</td>
                                <td class="text-center">1</td>
                                <td class="text-end">Rp 15,000</td>
                                <td class="text-end">Rp 15,000</td>
                            </tr>
                        </tbody>
                        <tfoot class="table-secondary">
                            <tr>
                                <td colspan="3" class="text-end"><strong>Total:</strong></td>
                                <td class="text-end"><strong>Rp 90,000</strong></td>
                            </tr>
                            <tr>
                                <td colspan="3" class="text-end"><strong>Cash:</strong></td>
                                <td class="text-end"><strong>Rp 100,000</strong></td>
                            </tr>
                            <tr>
                                <td colspan="3" class="text-end"><strong>Kembalian:</strong></td>
                                <td class="text-end text-success"><strong>Rp 10,000</strong></td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                
                <div class="alert alert-info mt-3">
                    <i class="fas fa-info-circle"></i> 
                    Transaksi ini telah selesai dan tercatat dalam sistem.
                </div>
            `;
            
            document.getElementById('transactionDetails').innerHTML = details;
        }
        
        function printReceipt(transactionCode) {
            if (confirm(`Cetak ulang struk untuk transaksi ${transactionCode}?`)) {
                // In real app: window.open('PrintReceiptServlet?code=' + transactionCode);
                alert(`Mencetak struk untuk transaksi: ${transactionCode}\n\nFitur ini akan membuka halaman cetak struk.`);
            }
        }
        
        function printModalReceipt() {
            if (currentTransactionCode) {
                printReceipt(currentTransactionCode);
                bootstrap.Modal.getInstance(document.getElementById('transactionModal')).hide();
            }
        }
        
        function printReport() {
            window.print();
        }
        
        function exportToExcel() {
            const date = document.querySelector('input[name="date"]').value;
            alert(`Export data transaksi tanggal ${date} ke Excel\n\nFitur export Excel akan segera tersedia.`);
        }
        
        // Auto-refresh page every 5 minutes if on today's transactions
        function shouldAutoRefresh() {
            const today = new Date().toISOString().split('T')[0];
            const selectedDate = document.querySelector('input[name="date"]').value;
            return selectedDate === today;
        }
        
        if (shouldAutoRefresh()) {
            setInterval(() => {
                if (!document.querySelector('.modal.show')) { // Don't refresh if modal is open
                    console.log('Auto-refreshing transactions...');
                    window.location.reload();
                }
            }, 300000); // 5 minutes
        }
        
        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // Ctrl + P for print
            if (e.ctrlKey && e.key === 'p') {
                e.preventDefault();
                printReport();
            }
            // Ctrl + F for filter focus
            if (e.ctrlKey && e.key === 'f') {
                e.preventDefault();
                document.querySelector('input[name="date"]').focus();
            }
            // F5 to refresh
            if (e.key === 'F5') {
                e.preventDefault();
                window.location.reload();
            }
        });
    </script>
</body>
</html>