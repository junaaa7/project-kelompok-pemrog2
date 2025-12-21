<%-- 
    Document   : category-management
    Created on : 2 Dec 2025, 13.06.21
    Author     : ARJUNA.R.PUTRA
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.pos.model.User" %>
<%@ page import="com.pos.model.Category" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    
    
    String timestamp = request.getParameter("t");
    if (timestamp == null) {
        timestamp = String.valueOf(System.currentTimeMillis());
    }
    
    System.out.println("=== JSP category-management.jsp LOADED (t=" + timestamp + ") ===");
    
    
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    
   
    String dataLoadedFlag = (String) session.getAttribute("categoryDataLoaded");
    
    if (dataLoadedFlag == null) {
        
        System.out.println("JSP: First load detected, redirecting to Servlet");
        session.setAttribute("categoryDataLoaded", "true");
        response.sendRedirect("LoadCategoryServlet?t=" + timestamp);
        return; // STOP execution here
    }
    
    List<Category> categories = (List<Category>) session.getAttribute("categories");
    
    if (categories == null) {
        System.out.println("JSP: No categories in session, using empty list");
        categories = new ArrayList<>();
    }
    

    int totalCategories = categories.size();
    int totalProducts = 0;
    int categoriesWithProducts = 0;
    
    for (Category cat : categories) {
        totalProducts += cat.getProductCount();
        if (cat.getProductCount() > 0) {
            categoriesWithProducts++;
        }
    }
    

    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    

    session.removeAttribute("message");
    session.removeAttribute("error");
    
    System.out.println("JSP: Displaying " + totalCategories + " categories");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Kelola Kategori - POS System</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css?t=<%=timestamp%>" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css?t=<%=timestamp%>" rel="stylesheet">
    
    <style>
        body {
            background-color: #f8f9fa;
        }
        .category-card {
            transition: all 0.3s ease;
            border: 1px solid #dee2e6;
            border-radius: 8px;
        }
        .category-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
        }
        .sidebar {
            background: #f8f9fa;
            min-height: calc(100vh - 56px);
            border-right: 1px solid #dee2e6;
        }
        .list-group-item.active {
            background-color: #0d6efd;
            border-color: #0d6efd;
        }
        .btn-action {
            width: 36px;
            height: 36px;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .stats-card {
            border-radius: 10px;
            border: none;
            transition: all 0.3s;
        }
        .stats-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .stat-icon {
            font-size: 2rem;
            opacity: 0.8;
        }
        .stat-number {
            font-size: 1.8rem;
            font-weight: bold;
            margin: 0.5rem 0;
        }
        .stat-label {
            font-size: 0.9rem;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .notification-alert {
            position: fixed;
            top: 70px;
            right: 20px;
            z-index: 9999;
            max-width: 350px;
            animation: slideIn 0.3s ease-out;
        }
        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        .fade-out {
            animation: fadeOut 0.5s ease-out forwards;
        }
        @keyframes fadeOut {
            from {
                opacity: 1;
                transform: scale(1);
            }
            to {
                opacity: 0;
                transform: scale(0.95);
            }
        }
        .refresh-indicator {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 9999;
            background: rgba(255, 255, 255, 0.9);
            padding: 20px 30px;
            border-radius: 10px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.2);
            display: none;
        }
    </style>
</head>
<body>
    <!-- Refresh Indicator -->
    <div class="refresh-indicator" id="refreshIndicator">
        <div class="text-center">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
            <p class="mt-2 mb-0">Memperbarui data...</p>
        </div>
    </div>
    
    <!-- Auto-refresh Notification -->
    <% 
        Long lastUpdate = (Long) session.getAttribute("lastUpdateTime");
        if (lastUpdate != null && (System.currentTimeMillis() - lastUpdate) < 3000) {
    %>
    <div class="notification-alert alert alert-info alert-dismissible fade show">
        <i class="fas fa-sync-alt fa-spin me-2"></i>
        Data berhasil diperbarui
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <%
            session.removeAttribute("lastUpdateTime");
        }
    %>
    
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="dashboard.jsp">
                <i class="fas fa-store"></i> POS System
            </a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    Welcome, <%= user.getFullName() %> (Admin)
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
                    <!-- LINK KE JSP DENGAN TIMESTAMP -->
                    <a href="category-management.jsp?t=<%=timestamp%>" class="list-group-item list-group-item-action active">
                        <i class="fas fa-tags"></i> Kelola Kategori
                        <!-- BADGE COUNTER DI SIDEBAR -->
                        <% if (totalCategories > 0) { %>
                        <span class="badge bg-primary float-end"><%= totalCategories %></span>
                        <% } %>
                    </a>
                    <a href="sales-report.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-chart-bar"></i> Laporan Penjualan
                    </a>
                    <a href="system-settings.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-cog"></i> Pengaturan Sistem
                    </a>
                </div>
                
                <!-- Quick Stats -->
                <div class="mt-4">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body p-3">
                            <h6 class="card-title text-muted mb-3">
                                <i class="fas fa-chart-pie me-2"></i> Quick Stats
                            </h6>
                            <div class="d-flex justify-content-between mb-2">
                                <span class="text-muted">Total Kategori:</span>
                                <span class="fw-bold" id="sidebarCategoryCount"><%= totalCategories %></span>
                            </div>
                            <div class="d-flex justify-content-between mb-2">
                                <span class="text-muted">Total Produk:</span>
                                <span class="fw-bold" id="sidebarProductCount"><%= totalProducts %></span>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span class="text-muted">Kategori Berisi:</span>
                                <span class="fw-bold" id="sidebarWithProducts"><%= categoriesWithProducts %></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="col-md-9 col-lg-10">
                <!-- Header dengan Statistik -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h2 class="mb-1">
                            <i class="fas fa-tags text-primary"></i> Kelola Kategori
                        </h2>
                        <p class="text-muted mb-0">
                            Total <span class="badge bg-primary" id="headerCategoryCount"><%= totalCategories %></span> kategori 
                            dengan <span class="badge bg-success" id="headerProductCount"><%= totalProducts %></span> produk
                        </p>
                    </div>
                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addCategoryModal">
                        <i class="fas fa-plus"></i> Tambah Kategori
                    </button>
                </div>
                
                <!-- Messages -->
                <% if (message != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert" id="successAlert">
                    <i class="fas fa-check-circle me-2"></i> <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>
                
                <% if (error != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert" id="errorAlert">
                    <i class="fas fa-exclamation-triangle me-2"></i> <%= error %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>
                
                <!-- Statistik Cards -->
                <% if (totalCategories > 0) { %>
                <div class="row mb-4">
                    <div class="col-md-3 mb-3">
                        <div class="card stats-card bg-primary text-white">
                            <div class="card-body text-center p-4">
                                <div class="stat-icon">
                                    <i class="fas fa-tags"></i>
                                </div>
                                <div class="stat-number" id="statTotalCategories">
                                    <%= totalCategories %>
                                </div>
                                <div class="stat-label">
                                    Total Kategori
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card stats-card bg-success text-white">
                            <div class="card-body text-center p-4">
                                <div class="stat-icon">
                                    <i class="fas fa-boxes"></i>
                                </div>
                                <div class="stat-number" id="statTotalProducts">
                                    <%= totalProducts %>
                                </div>
                                <div class="stat-label">
                                    Total Produk
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card stats-card bg-info text-white">
                            <div class="card-body text-center p-4">
                                <div class="stat-icon">
                                    <i class="fas fa-check-circle"></i>
                                </div>
                                <div class="stat-number" id="statWithProducts">
                                    <%= categoriesWithProducts %>
                                </div>
                                <div class="stat-label">
                                    Kategori Berisi
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card stats-card bg-warning text-dark">
                            <div class="card-body text-center p-4">
                                <div class="stat-icon">
                                    <i class="fas fa-exclamation-circle"></i>
                                </div>
                                <div class="stat-number" id="statEmptyCategories">
                                    <%= totalCategories - categoriesWithProducts %>
                                </div>
                                <div class="stat-label">
                                    Kategori Kosong
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
                
                <!-- Categories Grid -->
                <% if (totalCategories > 0) { %>
                <div class="row">
                    <!-- Filter/Search Bar -->
                    <div class="col-12 mb-3">
                        <div class="card">
                            <div class="card-body p-3">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="mb-0">Daftar Kategori</h6>
                                        <small class="text-muted" id="displayCount">
                                            Menampilkan <%= totalCategories %> kategori
                                        </small>
                                    </div>
                                    <div class="d-flex">
                                        <div class="input-group input-group-sm" style="width: 250px;">
                                            <input type="text" class="form-control" placeholder="Cari kategori..." 
                                                   id="searchCategory" onkeyup="searchCategories()">
                                            <button class="btn btn-outline-secondary" type="button">
                                                <i class="fas fa-search"></i>
                                            </button>
                                        </div>
                                        <button class="btn btn-sm btn-outline-secondary ms-2" onclick="resetView()">
                                            <i class="fas fa-redo"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Categories List -->
                    <% 
                    String[] colors = {"#FF6384", "#36A2EB", "#FFCE56", "#4BC0C0", "#9966FF", "#FF9F40"};
                    int colorIndex = 0;
                    
                    for (Category category : categories) {
                        String color = colors[colorIndex % colors.length];
                        colorIndex++;
                    %>
                    <div class="col-md-4 mb-4 category-item" id="category-<%= category.getId() %>">
                        <div class="card h-100 category-card">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <div>
                                        <h5 class="card-title mb-1">
                                            <i class="fas fa-tag me-2" style="color: <%= color %>"></i>
                                            <span class="category-name"><%= category.getName() %></span>
                                        </h5>
                                        <p class="text-muted small mb-0">
                                            <i class="fas fa-hashtag me-1"></i> 
                                            <code class="category-code"><%= category.getCode() %></code>
                                        </p>
                                    </div>
                                    <div class="btn-group">
                                        <button class="btn btn-outline-warning btn-sm btn-action me-1"
                                                onclick="editCategory(<%= category.getId() %>, '<%= category.getName().replace("'", "\\'") %>', '<%= category.getDescription() != null ? category.getDescription().replace("'", "\\'") : "" %>')">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button class="btn btn-outline-danger btn-sm btn-action"
                                                onclick="confirmDelete(<%= category.getId() %>, '<%= category.getName().replace("'", "\\'") %>')">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </div>
                                
                                <p class="card-text text-muted mb-3 category-description">
                                    <%= category.getDescription() != null && !category.getDescription().isEmpty() 
                                        ? category.getDescription() 
                                        : "<span class='text-muted fst-italic'>Tidak ada deskripsi</span>" %>
                                </p>
                                
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="badge <%= category.getProductCount() > 0 ? "bg-primary" : "bg-secondary" %>">
                                        <i class="fas fa-box me-1"></i>
                                        <span class="product-count"><%= category.getProductCount() %></span> produk
                                    </span>
                                    <small class="text-muted">
                                        ID: <span class="category-id"><%= category.getId() %></span>
                                    </small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                
                <!-- Summary Footer -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card border-0 bg-light">
                            <div class="card-body py-3">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <i class="fas fa-info-circle text-primary me-2"></i>
                                        <span class="text-muted">
                                            Menampilkan <strong id="footerCategoryCount"><%= totalCategories %></strong> kategori 
                                            dengan total <strong id="footerProductCount"><%= totalProducts %></strong> produk
                                        </span>
                                    </div>
                                    <div>
                                        <button onclick="exportData()" class="btn btn-sm btn-outline-primary me-2">
                                            <i class="fas fa-download me-1"></i> Export
                                        </button>
                                        <button onclick="refreshData()" class="btn btn-sm btn-outline-success">
                                            <i class="fas fa-sync-alt me-1"></i> Refresh
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <% } else { %>
                <!-- Empty State -->
                <div class="text-center py-5">
                    <div class="mb-4">
                        <i class="fas fa-tags fa-4x text-muted mb-3"></i>
                        <h3 class="text-muted">Belum ada kategori</h3>
                        <p class="text-muted mb-4">
                            Anda belum memiliki kategori produk. 
                            Tambahkan kategori pertama untuk mengorganisir produk Anda.
                        </p>
                    </div>
                    <button class="btn btn-primary btn-lg" data-bs-toggle="modal" data-bs-target="#addCategoryModal">
                        <i class="fas fa-plus me-2"></i> Tambah Kategori Pertama
                    </button>
                    <div class="mt-4">
                        <p class="text-muted small">
                            <i class="fas fa-lightbulb me-1"></i>
                            Tips: Kategori membantu mengelompokkan produk seperti "Elektronik", "Makanan", dll.
                        </p>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>
    
    <!-- Modals -->
    <!-- Add Category Modal -->
    <div class="modal fade" id="addCategoryModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="CategoryManagementServlet" method="POST" id="addCategoryForm">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="fas fa-plus-circle me-2"></i> Tambah Kategori Baru
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Kode Kategori</label>
                            <input type="text" class="form-control" name="code" 
                                   placeholder="CAT001 (kosongkan untuk otomatis)">
                            <div class="form-text">
                                Biarkan kosong untuk generate otomatis (CAT001, CAT002, dst)
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Nama Kategori <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="name" required
                                   placeholder="Contoh: Elektronik, Makanan, Pakaian">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Deskripsi</label>
                            <textarea class="form-control" name="description" rows="3"
                                      placeholder="Deskripsi singkat tentang kategori ini"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-primary" onclick="showRefreshIndicator()">
                            <i class="fas fa-save me-1"></i> Simpan
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Edit Category Modal -->
    <div class="modal fade" id="editCategoryModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="CategoryManagementServlet" method="POST" id="editCategoryForm">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="editId">
                    <div class="modal-header bg-warning">
                        <h5 class="modal-title">
                            <i class="fas fa-edit me-2"></i> Edit Kategori
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Nama Kategori <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="editName" name="name" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Deskripsi</label>
                            <textarea class="form-control" id="editDescription" name="description" rows="3"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-warning text-white" onclick="showRefreshIndicator()">
                            <i class="fas fa-sync-alt me-1"></i> Update
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteCategoryModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="CategoryManagementServlet" method="POST" id="deleteCategoryForm">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="deleteId">
                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title">
                            <i class="fas fa-exclamation-triangle me-2"></i> Konfirmasi Hapus
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>Apakah Anda yakin ingin menghapus kategori berikut?</p>
                        <div class="alert alert-light border">
                            <h5 id="deleteName" class="mb-0 text-danger"></h5>
                        </div>
                        <div class="alert alert-warning">
                            <i class="fas fa-exclamation-triangle me-2"></i>
                            Produk dalam kategori ini akan menjadi tanpa kategori.
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="confirmDelete" required>
                            <label class="form-check-label" for="confirmDelete">
                                Ya, saya yakin ingin menghapus kategori ini
                            </label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-danger" id="deleteBtn" disabled onclick="showRefreshIndicator()">
                            <i class="fas fa-trash me-1"></i> Hapus
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js?t=<%=timestamp%>"></script>
    
    <!-- JavaScript -->
    <script>
        // Initialize modals
        const editModal = new bootstrap.Modal(document.getElementById('editCategoryModal'));
        const deleteModal = new bootstrap.Modal(document.getElementById('deleteCategoryModal'));
        const addModal = new bootstrap.Modal(document.getElementById('addCategoryModal'));
        
        // Function to edit category
        function editCategory(id, name, description) {
            document.getElementById('editId').value = id;
            document.getElementById('editName').value = name;
            document.getElementById('editDescription').value = description || '';
            editModal.show();
        }
        
        // Function to confirm delete
        function confirmDelete(id, name) {
            document.getElementById('deleteId').value = id;
            document.getElementById('deleteName').textContent = name;
            
            // Reset checkbox
            document.getElementById('confirmDelete').checked = false;
            document.getElementById('deleteBtn').disabled = true;
            
            // Add event listener for checkbox
            document.getElementById('confirmDelete').addEventListener('change', function() {
                document.getElementById('deleteBtn').disabled = !this.checked;
            });
            
            deleteModal.show();
        }
        
        // Show refresh indicator
        function showRefreshIndicator() {
            document.getElementById('refreshIndicator').style.display = 'block';
            
            // Auto hide after 2 seconds (fallback)
            setTimeout(() => {
                document.getElementById('refreshIndicator').style.display = 'none';
            }, 2000);
        }
        
        // Search categories
        function searchCategories() {
            const searchTerm = document.getElementById('searchCategory').value.toLowerCase();
            const categoryItems = document.querySelectorAll('.category-item');
            let visibleCount = 0;
            
            categoryItems.forEach(item => {
                const name = item.querySelector('.category-name').textContent.toLowerCase();
                const code = item.querySelector('.category-code').textContent.toLowerCase();
                const description = item.querySelector('.category-description').textContent.toLowerCase();
                
                if (name.includes(searchTerm) || code.includes(searchTerm) || description.includes(searchTerm)) {
                    item.style.display = 'block';
                    visibleCount++;
                } else {
                    item.style.display = 'none';
                }
            });
            
            // Update counter
            updateCounter(visibleCount);
        }
        
        // Update search counter
        function updateCounter(count) {
            const total = <%= totalCategories %>;
            const counterElement = document.getElementById('displayCount');
            if (counterElement) {
                counterElement.textContent = `Menampilkan ${count} dari ${total} kategori`;
            }
        }
        
        // Reset view
        function resetView() {
            document.getElementById('searchCategory').value = '';
            const categoryItems = document.querySelectorAll('.category-item');
            categoryItems.forEach(item => {
                item.style.display = 'block';
            });
            updateCounter(<%= totalCategories %>);
        }
        
        // Export data
        function exportData() {
            const data = {
                title: 'Data Kategori',
                date: new Date().toLocaleDateString('id-ID'),
                totalCategories: <%= totalCategories %>,
                totalProducts: <%= totalProducts %>
            };
            
            alert(`Data akan diexport:\n\nTanggal: ${data.date}\nTotal Kategori: ${data.totalCategories}\nTotal Produk: ${data.totalProducts}`);
            console.log('Exporting data:', data);
        }
        
        // Refresh data
        function refreshData() {
            if (confirm('Refresh data kategori dari database?')) {
                showRefreshIndicator();
                fetch('LoadCategoryServlet?force=true&t=' + new Date().getTime())
                    .then(response => {
                        if (response.ok) {
                            // Redirect dengan timestamp baru
                            setTimeout(() => {
                                window.location.href = 'category-management.jsp?t=' + new Date().getTime();
                            }, 500);
                        }
                    });
            }
        }
        
        // Auto-hide alerts after 5 seconds
        setTimeout(() => {
            const successAlert = document.getElementById('successAlert');
            const errorAlert = document.getElementById('errorAlert');
            
            if (successAlert) {
                const bsAlert = new bootstrap.Alert(successAlert);
                bsAlert.close();
            }
            if (errorAlert) {
                const bsAlert = new bootstrap.Alert(errorAlert);
                bsAlert.close();
            }
            
            // Auto-hide notification alerts
            document.querySelectorAll('.notification-alert').forEach(alert => {
                const bsAlert = new bootstrap.Alert(alert);
                setTimeout(() => bsAlert.close(), 3000);
            });
        }, 5000);
        
        // Auto-refresh if page was loaded from cache
        window.addEventListener('pageshow', function(event) {
            if (event.persisted) {
                console.log('Page loaded from cache, auto-refreshing...');
                setTimeout(() => {
                    window.location.href = 'category-management.jsp?t=' + new Date().getTime();
                }, 100);
            }
        });
        
        // Hide refresh indicator when page loads
        window.addEventListener('load', function() {
            document.getElementById('refreshIndicator').style.display = 'none';
            console.log('Page loaded with <%= totalCategories %> categories');
        });
        
        // Handle form submissions - show loading indicator
        document.addEventListener('submit', function(e) {
            if (e.target.matches('form[action="CategoryManagementServlet"]')) {
                showRefreshIndicator();
            }
        });
        
        // Initialize
        console.log('Category management system initialized');
    </script>
</body>
</html>