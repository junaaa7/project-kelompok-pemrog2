<%-- 
    Document   : dashboard
    Created on : 2 Dec 2025, 13.06.21
    Author     : ARJUNA.R.PUTRA
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.pos.model.User" %>
<%@ page import="com.pos.dao.SalesReportDAO" %>
<%@ page import="java.text.NumberFormat" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get statistics based on role
    SalesReportDAO salesDAO = new SalesReportDAO();
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance();
    currencyFormat.setMaximumFractionDigits(0);
    
    int totalProducts = 0;
    int todayTransactions = 0;
    double todayRevenue = 0;
    int totalUsers = 0;
    
    // Sample data - in real app, fetch from database
    if ("admin".equals(user.getRole())) {
        totalProducts = 25;
        todayTransactions = 8;
        todayRevenue = 750000;
        totalUsers = 5;
    } else if ("cashier".equals(user.getRole())) {
        totalProducts = 25; // Kasir bisa lihat total produk tapi tidak edit
        // Get cashier's own transactions for today
        java.util.Map<String, Object> cashierSummary = salesDAO.getCashierDailySummary(
            user.getId(), 
            new java.sql.Date(System.currentTimeMillis()).toString()
        );
        todayTransactions = cashierSummary.get("total_transactions") != null ? 
            ((Number) cashierSummary.get("total_transactions")).intValue() : 0;
        todayRevenue = cashierSummary.get("total_sales") != null ? 
            ((Number) cashierSummary.get("total_sales")).doubleValue() : 0;
        totalUsers = 1; // Hanya diri sendiri
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - POS System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            background-color: #f8f9fa;
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
        .container-fluid {
            padding-left: 0;
            padding-right: 0;
        }
        .row {
            margin-left: 0;
            margin-right: 0;
        }
        .list-group-item.active {
            background-color: #0d6efd;
            border-color: #0d6efd;
        }
        .access-restriction {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .stat-card {
            border-radius: 10px;
            border: none;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
        }
        .card-icon {
            font-size: 2.5rem;
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="dashboard.jsp">
                <i class="fas fa-store"></i> POS System
            </a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    <i class="fas fa-user-circle"></i> <%= user.getFullName() %> (<%= user.getRole() %>)
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
    
    <div class="container-fluid">
        <div class="row main-content">
            <!-- Sidebar -->
            <div class="col-md-3 col-lg-2 sidebar">
                <div class="list-group mt-3">
                    <a href="dashboard.jsp" class="list-group-item list-group-item-action active">
                        <i class="fas fa-tachometer-alt"></i> Dashboard
                    </a>
                    
                    <% if ("admin".equals(user.getRole())) { %>
                    <!-- Menu untuk ADMIN -->
                    <a href="user-management.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-users"></i> Kelola User
                    </a>
                    <a href="product-management.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-box"></i> Kelola Produk
                    </a>
                    <a href="category-management.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-tags"></i> Kelola Kategori
                    </a>
                    <a href="sales-report.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-chart-bar"></i> Laporan Penjualan
                    </a>
                    <a href="system-settings.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-cog"></i> Pengaturan Sistem
                    </a>
                    <% } else if ("cashier".equals(user.getRole())) { %>
                    <!-- Menu untuk CASHIER (TERBATAS) -->
                    <a href="index.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-cash-register"></i> Transaksi
                    </a>
                    <a href="cart.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-shopping-cart"></i> Keranjang
                    </a>
                    <a href="cashier-transactions.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-history"></i> Riwayat Transaksi
                    </a>
                    <% } %>
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="col-md-9 col-lg-10 px-md-4 pt-3">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2"><i class="fas fa-tachometer-alt"></i> Dashboard</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <span class="badge bg-primary">
                            <i class="fas fa-clock"></i> <%= new java.util.Date() %>
                        </span>
                    </div>
                </div>
                
                <!-- Access Restriction Message for Cashier -->
                <% if ("cashier".equals(user.getRole())) { %>
                <div class="access-restriction">
                    <div class="row align-items-center">
                        <div class="col-md-10">
                            <h4><i class="fas fa-info-circle"></i> Informasi Hak Akses Kasir</h4>
                            <p class="mb-1">Anda login sebagai <strong>Kasir</strong> dengan akses terbatas:</p>
                            <div class="row">
                                <div class="col-md-6">
                                    <p class="mb-1"><i class="fas fa-check-circle text-success"></i> Melakukan transaksi penjualan</p>
                                    <p class="mb-1"><i class="fas fa-check-circle text-success"></i> Input barang ke keranjang</p>
                                    <p class="mb-1"><i class="fas fa-check-circle text-success"></i> Menerima pembayaran</p>
                                </div>
                                <div class="col-md-6">
                                    <p class="mb-1"><i class="fas fa-check-circle text-success"></i> Menghitung kembalian</p>
                                    <p class="mb-1"><i class="fas fa-check-circle text-success"></i> Mencetak struk</p>
                                    <p class="mb-1"><i class="fas fa-check-circle text-success"></i> Lihat riwayat transaksi sendiri</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-2 text-center">
                            <i class="fas fa-cash-register fa-3x"></i>
                        </div>
                    </div>
                </div>
                <% } %>
                
                <!-- Stats Cards -->
                <div class="row mb-4">
                    <div class="col-md-3 mb-3">
                        <div class="card stat-card text-white bg-primary">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h5 class="card-title">Total Produk</h5>
                                        <p class="card-text display-6 mb-0"><%= totalProducts %></p>
                                    </div>
                                    <i class="fas fa-box card-icon"></i>
                                </div>
                                <p class="card-text mt-2 small">
                                    <% if ("admin".equals(user.getRole())) { %>
                                        <a href="product-management.jsp" class="text-white text-decoration-underline">Kelola Produk</a>
                                    <% } else { %>
                                        Produk tersedia untuk dijual
                                    <% } %>
                                </p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card stat-card text-white bg-success">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h5 class="card-title">Transaksi Hari Ini</h5>
                                        <p class="card-text display-6 mb-0"><%= todayTransactions %></p>
                                    </div>
                                    <i class="fas fa-shopping-cart card-icon"></i>
                                </div>
                                <p class="card-text mt-2 small">
                                    <% if ("cashier".equals(user.getRole())) { %>
                                        Transaksi yang Anda lakukan hari ini
                                    <% } else { %>
                                        Total transaksi hari ini
                                    <% } %>
                                </p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card stat-card text-white bg-warning">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h5 class="card-title">Pendapatan Hari Ini</h5>
                                        <p class="card-text display-6 mb-0"><%= currencyFormat.format(todayRevenue) %></p>
                                    </div>
                                    <i class="fas fa-money-bill-wave card-icon"></i>
                                </div>
                                <p class="card-text mt-2 small">
                                    <% if ("cashier".equals(user.getRole())) { %>
                                        Pendapatan dari transaksi Anda
                                    <% } else { %>
                                        Total pendapatan hari ini
                                    <% } %>
                                </p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card stat-card text-white bg-info">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h5 class="card-title">Total Users</h5>
                                        <p class="card-text display-6 mb-0"><%= totalUsers %></p>
                                    </div>
                                    <i class="fas fa-users card-icon"></i>
                                </div>
                                <p class="card-text mt-2 small">
                                    <% if ("admin".equals(user.getRole())) { %>
                                        <a href="user-management.jsp" class="text-white text-decoration-underline">Kelola User</a>
                                    <% } else { %>
                                        User aktif di sistem
                                    <% } %>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Welcome Message -->
                <div class="alert alert-info">
                    <div class="row">
                        <div class="col-md-10">
                            <h4><i class="fas fa-hand-wave"></i> Selamat datang, <%= user.getFullName() %>!</h4>
                            <p class="mb-0">Anda login sebagai <strong class="text-uppercase"><%= user.getRole() %></strong>. 
                           </p>
                        </div>
                        <div class="col-md-2 text-end">
                            <span class="badge bg-primary fs-6">
                                <%= new java.text.SimpleDateFormat("EEEE, dd MMMM yyyy").format(new java.util.Date()) %>
                            </span>
                        </div>
                    </div>
                </div>
                
                <!-- Quick Actions -->
                <div class="row mt-4">
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header bg-light">
                                <h5 class="mb-0"><i class="fas fa-bolt"></i> Aksi Cepat</h5>
                            </div>
                            <div class="card-body">
                                <% if ("admin".equals(user.getRole())) { %>
                                <!-- Admin Actions -->
                                <div class="btn-group" role="group">
                                    <a href="product-form.jsp" class="btn btn-success me-2">
                                        <i class="fas fa-plus"></i> Tambah Produk
                                    </a>
                                    <a href="register.jsp" class="btn btn-warning me-2">
                                        <i class="fas fa-user-plus"></i> Tambah User
                                    </a>
                                    <a href="sales-report.jsp" class="btn btn-info">
                                        <i class="fas fa-chart-bar"></i> Lihat Laporan
                                    </a>
                                </div>
                                <% } else if ("cashier".equals(user.getRole())) { %>
                                <!-- Cashier Actions -->
                                <div class="btn-group" role="group">
                                    <a href="index.jsp" class="btn btn-primary me-2">
                                        <i class="fas fa-cash-register"></i> Mulai Transaksi Baru
                                    </a>
                                    <a href="cart.jsp" class="btn btn-success me-2">
                                        <i class="fas fa-shopping-cart"></i> Lihat Keranjang
                                    </a>
                                    <a href="cashier-transactions.jsp" class="btn btn-info">
                                        <i class="fas fa-history"></i> Riwayat Transaksi
                                    </a>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header bg-light">
                                <h5 class="mb-0"><i class="fas fa-user-circle"></i> Info Akun</h5>
                            </div>
                            <div class="card-body">
                                <p class="mb-2"><strong>Username:</strong> <%= user.getUsername() %></p>
                                <p class="mb-2"><strong>Nama:</strong> <%= user.getFullName() %></p>
                                <p class="mb-2"><strong>Role:</strong> 
                                    <span class="badge <%= "admin".equals(user.getRole()) ? "bg-danger" : "bg-primary" %>">
                                        <%= "admin".equals(user.getRole()) ? "Administrator" : "Kasir" %>
                                    </span>
                                </p>
                                <p class="mb-0"><strong>Email:</strong> <%= user.getEmail() != null ? user.getEmail() : "-" %></p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Recent Activity -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header bg-light d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="fas fa-history"></i> Aktivitas Terbaru</h5>
                                <span class="badge bg-primary">Hari Ini</span>
                            </div>
                            <div class="card-body">
                                <% if ("cashier".equals(user.getRole())) { 
                                    java.util.List<java.util.Map<String, Object>> recentTransactions = 
                                        salesDAO.getCashierTransactions(
                                            user.getId(), 
                                            new java.sql.Date(System.currentTimeMillis()).toString()
                                        );
                                    
                                    if (recentTransactions.isEmpty()) { %>
                                <div class="text-center py-3">
                                    <i class="fas fa-receipt fa-2x text-muted mb-2"></i>
                                    <p class="text-muted mb-0">Belum ada transaksi hari ini</p>
                                    <a href="index.jsp" class="btn btn-primary btn-sm mt-2">Mulai Transaksi Pertama</a>
                                </div>
                                <% } else { 
                                    int count = 0;
                                    for (java.util.Map<String, Object> trans : recentTransactions) {
                                        if (count >= 5) break;
                                        String status = (String) trans.get("status");
                                %>
                                <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2">
                                    <div>
                                        <i class="fas fa-receipt text-primary me-2"></i>
                                        <strong><%= trans.get("transaction_code") %></strong>
                                        <span class="text-muted ms-2">
                                            <%= new java.text.SimpleDateFormat("HH:mm").format(trans.get("transaction_date")) %>
                                        </span>
                                    </div>
                                    <div>
                                        <span class="badge <%= "completed".equals(status) ? "bg-success" : "bg-danger" %> me-2">
                                            <%= "completed".equals(status) ? "Selesai" : "Dibatalkan" %>
                                        </span>
                                        <strong><%= currencyFormat.format(trans.get("total_amount")) %></strong>
                                    </div>
                                </div>
                                <% 
                                        count++;
                                    } 
                                } %>
                                <% } else { %>
                                <p class="text-muted">Fitur aktivitas untuk admin akan tersedia di versi selanjutnya.</p>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto refresh dashboard every 2 minutes
        setInterval(() => {
            // Refresh only if user is on dashboard
            if (window.location.pathname.includes('dashboard.jsp')) {
                console.log('Auto-refreshing dashboard...');
                window.location.reload();
            }
        }, 120000);
        
        // Update current time every minute
        function updateCurrentTime() {
            const now = new Date();
            const options = { 
                weekday: 'long', 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            };
            const timeString = now.toLocaleDateString('id-ID', options);
            const timeElement = document.querySelector('.badge.bg-primary');
            if (timeElement) {
                timeElement.innerHTML = `<i class="fas fa-clock"></i> ${timeString}`;
            }
        }
        
        // Update time every second
        setInterval(updateCurrentTime, 1000);
        updateCurrentTime(); // Initial call
    </script>
</body>
</html>