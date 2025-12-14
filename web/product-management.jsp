<%-- 
    Document   : product-management
    Created on : 2 Dec 2025, 13.06.21
    Author     : ARJUNA.R.PUTRA
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.pos.model.User" %>
<%@ page import="com.pos.model.Product" %>
<%@ page import="com.pos.dao.ProductDAO" %>
<%@ page import="java.util.List" %>
<%
    System.out.println("=== PRODUCT MANAGEMENT JSP STARTED ===");
    
    // Get session
    HttpSession currentSession = request.getSession(false);
    
    // Check if user is logged in
    User user = null;
    if (currentSession != null) {
        user = (User) currentSession.getAttribute("user");
        System.out.println("Session user: " + (user != null ? user.getUsername() : "null"));
    }
    
    // Redirect if not logged in
    if (user == null) {
        System.out.println("User not logged in, redirecting to login");
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
    
    // Check if user is admin
    if (!"admin".equals(user.getRole())) {
        System.out.println("User is not admin, role: " + user.getRole());
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
        return;
    }
    
    // Get messages from session (set by servlet)
    String successMessage = (String) currentSession.getAttribute("successMessage");
    String errorMessage = (String) currentSession.getAttribute("errorMessage");
    
    // Clear messages from session after displaying
    if (successMessage != null) {
        currentSession.removeAttribute("successMessage");
    }
    if (errorMessage != null) {
        currentSession.removeAttribute("errorMessage");
    }
    
    // Get data from DAO
    ProductDAO productDAO = new ProductDAO();
    List<Product> products = productDAO.getAllProducts();
    List<String> categories = productDAO.getAllCategories();
    
    System.out.println("Products count: " + products.size());
    System.out.println("Categories count: " + categories.size());
    System.out.println("=== PRODUCT MANAGEMENT JSP COMPLETED ===");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola Produk - POS System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .product-image {
            width: 50px;
            height: 50px;
            object-fit: cover;
            border-radius: 5px;
        }
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        .action-buttons .btn-sm {
            padding: 3px 8px;
            font-size: 12px;
        }
        .stock-low {
            color: #dc3545;
            font-weight: bold;
        }
        .stock-medium {
            color: #ffc107;
            font-weight: bold;
        }
        .stock-high {
            color: #28a745;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">
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
            <div class="col-md-3 col-lg-2">
                <div class="list-group">
                    <a href="dashboard.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-tachometer-alt"></i> Dashboard
                    </a>
                    <a href="user-management.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-users"></i> Kelola User
                    </a>
                    <a href="product-management.jsp" class="list-group-item list-group-item-action active">
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
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="col-md-9 col-lg-10">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="fas fa-box"></i> Kelola Produk</h2>
                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addProductModal">
                        <i class="fas fa-plus"></i> Tambah Produk
                    </button>
                </div>
                
                <!-- Messages -->
                <% if (successMessage != null) { %>
                    <div class="alert alert-success alert-dismissible fade show" role="alert" id="successAlert">
                        <i class="fas fa-check-circle"></i> <%= successMessage %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>
                
                <% if (errorMessage != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert" id="errorAlert">
                        <i class="fas fa-exclamation-triangle"></i> <%= errorMessage %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>
                
                <!-- Search and Filter -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="input-group">
                                    <input type="text" class="form-control" placeholder="Cari produk..." 
                                           id="searchInput" onkeyup="searchProducts()">
                                    <button class="btn btn-outline-primary" type="button" onclick="searchProducts()">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <select class="form-control" id="categoryFilter" onchange="filterByCategory()">
                                    <option value="">Semua Kategori</option>
                                    <% for (String category : categories) { %>
                                        <option value="<%= category %>"><%= category %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <select class="form-control" id="statusFilter" onchange="filterByStatus()">
                                    <option value="">Semua Status</option>
                                    <option value="active">Aktif</option>
                                    <option value="inactive">Nonaktif</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Products Table -->
                <div class="card">
                    <div class="card-body">
                        <% if (products.isEmpty()) { %>
                            <div class="text-center py-5">
                                <i class="fas fa-box fa-4x text-muted mb-3"></i>
                                <h5 class="text-muted">Tidak ada produk</h5>
                                <p class="text-muted">Klik "Tambah Produk" untuk menambahkan produk pertama</p>
                            </div>
                        <% } else { %>
                            <div class="table-responsive">
                                <table class="table table-hover" id="productsTable">
                                    <thead class="table-dark">
                                        <tr>
                                            <th>Kode</th>
                                            <th>Nama</th>
                                            <th>Kategori</th>
                                            <th>Harga</th>
                                            <th>Stok</th>
                                            <th>Status</th>
                                            <th>Aksi</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Product product : products) { 
                                            String stockClass = "";
                                            if (product.getStock() == 0) {
                                                stockClass = "stock-low";
                                            } else if (product.getStock() < 10) {
                                                stockClass = "stock-medium";
                                            } else {
                                                stockClass = "stock-high";
                                            }
                                        %>
                                        <tr data-category="<%= product.getCategoryName() != null ? product.getCategoryName() : "" %>"
                                            data-status="<%= product.isActive() ? "active" : "inactive" %>">
                                            <td>
                                                <strong><%= product.getCode() %></strong>
                                                <% if (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) { %>
                                                    <br>
                                                    <img src="<%= product.getImageUrl() %>" alt="<%= product.getName() %>" 
                                                         class="product-image mt-1" 
                                                         onerror="this.src='https://via.placeholder.com/50'">
                                                <% } %>
                                            </td>
                                            <td>
                                                <strong><%= product.getName() %></strong>
                                                <% if (product.getDescription() != null && !product.getDescription().isEmpty()) { %>
                                                    <br>
                                                    <small class="text-muted"><%= product.getDescription().length() > 50 ? 
                                                        product.getDescription().substring(0, 50) + "..." : product.getDescription() %></small>
                                                <% } %>
                                            </td>
                                            <td>
                                                <%= product.getCategoryName() != null ? product.getCategoryName() : 
                                                    "<span class='text-muted fst-italic'>Tanpa kategori</span>" %>
                                            </td>
                                            <td>
                                                <strong>Rp <%= String.format("%,.0f", product.getPrice()) %></strong>
                                            </td>
                                            <td>
                                                <span class="<%= stockClass %>">
                                                    <%= product.getStock() %>
                                                </span>
                                            </td>
                                            <td>
                                                <span class="badge bg-<%= product.isActive() ? "success" : "danger" %>">
                                                    <%= product.isActive() ? "Aktif" : "Nonaktif" %>
                                                </span>
                                            </td>
                                            <td>
                                                <div class="action-buttons">
                                                    <button class="btn btn-warning btn-sm" 
                                                            onclick="editProduct(
                                                                <%= product.getId() %>, 
                                                                '<%= product.getCode() %>', 
                                                                '<%= escapeJavaScript(product.getName()) %>', 
                                                                '<%= escapeJavaScript(product.getDescription()) %>', 
                                                                <%= product.getPrice() %>, 
                                                                <%= product.getStock() %>, 
                                                                <%= product.getCategoryId() != null ? product.getCategoryId() : "null" %>, 
                                                                <%= product.isActive() %>, 
                                                                '<%= escapeJavaScript(product.getImageUrl()) %>'
                                                            )">
                                                        <i class="fas fa-edit"></i>
                                                    </button>
                                                    <form action="ProductManagementServlet" method="post" style="display: inline;">
                                                        <input type="hidden" name="action" value="toggleStatus">
                                                        <input type="hidden" name="productId" value="<%= product.getId() %>">
                                                        <button type="submit" class="btn btn-sm <%= product.isActive() ? "btn-secondary" : "btn-success" %>"
                                                                onclick="return confirm('Yakin ingin <%= product.isActive() ? "nonaktifkan" : "aktifkan" %> produk <%= product.getName() %>?')">
                                                            <i class="fas <%= product.isActive() ? "fa-ban" : "fa-check" %>"></i>
                                                        </button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                            
                            <div class="mt-3 text-muted">
                                <i class="fas fa-info-circle"></i> 
                                Menampilkan <%= products.size() %> produk
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Add Product Modal -->
    <div class="modal fade" id="addProductModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form action="ProductManagementServlet" method="post" id="addProductForm">
                    <div class="modal-header">
                        <h5 class="modal-title">Tambah Produk Baru</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="action" value="add">
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Kode Produk *</label>
                                <input type="text" class="form-control" name="code" required
                                       placeholder="PRD001" maxlength="20">
                                <div class="form-text">Kode unik untuk produk</div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Nama Produk *</label>
                                <input type="text" class="form-control" name="name" required
                                       placeholder="Nama produk" maxlength="100">
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Harga *</label>
                                <div class="input-group">
                                    <span class="input-group-text">Rp</span>
                                    <input type="number" class="form-control" name="price" 
                                           step="0.01" min="0" required placeholder="0">
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Stok *</label>
                                <input type="number" class="form-control" name="stock" 
                                       min="0" required placeholder="0">
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Kategori</label>
                            <select class="form-control" name="categoryId">
                                <option value="">Pilih Kategori</option>
                                <% for (String category : categories) { %>
                                    <option value="<%= productDAO.getCategoryIdByName(category) %>">
                                        <%= category %>
                                    </option>
                                <% } %>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Deskripsi</label>
                            <textarea class="form-control" name="description" rows="3" 
                                      placeholder="Deskripsi produk" maxlength="500"></textarea>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Gambar URL</label>
                            <input type="text" class="form-control" name="imageUrl"
                                   placeholder="https://example.com/image.jpg">
                            <div class="form-text">Opsional. URL gambar produk</div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-primary" id="addProductSubmit">
                            <i class="fas fa-save"></i> Simpan
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Edit Product Modal -->
    <div class="modal fade" id="editProductModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form action="ProductManagementServlet" method="post" id="editProductForm">
                    <div class="modal-header">
                        <h5 class="modal-title">Edit Produk</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="productId" id="editProductId">
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Kode Produk</label>
                                <input type="text" class="form-control" id="editCode" readonly>
                                <div class="form-text">Kode produk tidak dapat diubah</div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Nama Produk *</label>
                                <input type="text" class="form-control" name="name" id="editName" required>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Harga *</label>
                                <div class="input-group">
                                    <span class="input-group-text">Rp</span>
                                    <input type="number" class="form-control" name="price" id="editPrice" 
                                           step="0.01" min="0" required>
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Stok *</label>
                                <input type="number" class="form-control" name="stock" id="editStock" 
                                       min="0" required>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Kategori</label>
                            <select class="form-control" name="categoryId" id="editCategoryId">
                                <option value="">Pilih Kategori</option>
                                <% for (String category : categories) { %>
                                    <option value="<%= productDAO.getCategoryIdByName(category) %>">
                                        <%= category %>
                                    </option>
                                <% } %>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Deskripsi</label>
                            <textarea class="form-control" name="description" id="editDescription" rows="3"></textarea>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Gambar URL</label>
                            <input type="text" class="form-control" name="imageUrl" id="editImageUrl"
                                   placeholder="https://example.com/image.jpg">
                        </div>
                        
                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" name="isActive" id="editIsActive">
                                <label class="form-check-label">Produk Aktif</label>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-primary" id="editProductSubmit">
                            <i class="fas fa-save"></i> Update
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Helper function to escape JavaScript strings
        function escapeJavaScript(text) {
            if (text === null || text === undefined) return '';
            return text.toString()
                .replace(/\\/g, '\\\\')
                .replace(/'/g, "\\'")
                .replace(/"/g, '\\"')
                .replace(/\n/g, '\\n')
                .replace(/\r/g, '\\r')
                .replace(/\t/g, '\\t');
        }
        
        // Edit product function
        function editProduct(id, code, name, description, price, stock, categoryId, isActive, imageUrl) {
            console.log('Editing product:', {
                id: id,
                code: code,
                name: name,
                description: description,
                price: price,
                stock: stock,
                categoryId: categoryId,
                isActive: isActive,
                imageUrl: imageUrl
            });
            
            // Set form values
            document.getElementById('editProductId').value = id;
            document.getElementById('editCode').value = code || '';
            document.getElementById('editName').value = name || '';
            document.getElementById('editPrice').value = price || 0;
            document.getElementById('editStock').value = stock || 0;
            document.getElementById('editCategoryId').value = categoryId || '';
            document.getElementById('editDescription').value = description || '';
            document.getElementById('editImageUrl').value = imageUrl || '';
            document.getElementById('editIsActive').checked = isActive === true;
            
            // Show modal
            const editModal = new bootstrap.Modal(document.getElementById('editProductModal'));
            editModal.show();
        }
        
        // Form validation and submission
        document.getElementById('addProductForm').addEventListener('submit', function(e) {
            const submitBtn = document.getElementById('addProductSubmit');
            submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Menyimpan...';
            submitBtn.disabled = true;
            
            // Form will submit normally
        });
        
        document.getElementById('editProductForm').addEventListener('submit', function(e) {
            const submitBtn = document.getElementById('editProductSubmit');
            submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Memperbarui...';
            submitBtn.disabled = true;
            
            // Form will submit normally
        });
        
        // Reset form buttons when modal is hidden
        document.getElementById('addProductModal').addEventListener('hidden.bs.modal', function() {
            const submitBtn = document.getElementById('addProductSubmit');
            submitBtn.innerHTML = '<i class="fas fa-save"></i> Simpan';
            submitBtn.disabled = false;
        });
        
        document.getElementById('editProductModal').addEventListener('hidden.bs.modal', function() {
            const submitBtn = document.getElementById('editProductSubmit');
            submitBtn.innerHTML = '<i class="fas fa-save"></i> Update';
            submitBtn.disabled = false;
        });
        
        // Search and filter functions
        function searchProducts() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            const rows = document.querySelectorAll('#productsTable tbody tr');
            
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(searchTerm) ? '' : 'none';
            });
        }
        
        function filterByCategory() {
            const category = document.getElementById('categoryFilter').value;
            const rows = document.querySelectorAll('#productsTable tbody tr');
            
            rows.forEach(row => {
                const rowCategory = row.getAttribute('data-category');
                row.style.display = (category === '' || rowCategory === category) ? '' : 'none';
            });
        }
        
        function filterByStatus() {
            const status = document.getElementById('statusFilter').value;
            const rows = document.querySelectorAll('#productsTable tbody tr');
            
            rows.forEach(row => {
                const rowStatus = row.getAttribute('data-status');
                row.style.display = (status === '' || rowStatus === status) ? '' : 'none';
            });
        }
        
        // Auto close alerts after 5 seconds
        setTimeout(function() {
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
        }, 5000);
        
        // Focus on search input on page load
        document.addEventListener('DOMContentLoaded', function() {
            const searchInput = document.getElementById('searchInput');
            if (searchInput) {
                searchInput.focus();
            }
        });
    </script>
</body>
</html>

<%!
    // Helper method for JavaScript string escaping in JSP
    private String escapeJavaScript(String input) {
        if (input == null) return "";
        return input.replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
%>