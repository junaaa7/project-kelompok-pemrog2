<%-- 
    Document   : category-management
    Created on : 2 Dec 2025, 13.06.21
    Author     : ARJUNA.R.PUTRA
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.pos.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola Kategori - POS System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
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
                    <a href="product-management.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-box"></i> Kelola Produk
                    </a>
                    <a href="category-management.jsp" class="list-group-item list-group-item-action active">
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
                    <h2><i class="fas fa-tags"></i> Kelola Kategori</h2>
                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addCategoryModal">
                        <i class="fas fa-plus"></i> Tambah Kategori
                    </button>
                </div>
                
                <!-- Categories Grid -->
                <div class="row" id="categoriesContainer">
                    <!-- Categories will be loaded here -->
                </div>
            </div>
        </div>
    </div>
    
    <!-- Add Category Modal -->
    <div class="modal fade" id="addCategoryModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form id="addCategoryForm">
                    <div class="modal-header">
                        <h5 class="modal-title">Tambah Kategori Baru</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Nama Kategori *</label>
                            <input type="text" class="form-control" id="categoryName" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Deskripsi</label>
                            <textarea class="form-control" id="categoryDescription" rows="3"></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Warna</label>
                            <input type="color" class="form-control form-control-color" id="categoryColor" value="#007bff">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-primary">Simpan</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Edit Category Modal -->
    <div class="modal fade" id="editCategoryModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form id="editCategoryForm">
                    <div class="modal-header">
                        <h5 class="modal-title">Edit Kategori</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" id="editCategoryId">
                        <div class="mb-3">
                            <label class="form-label">Nama Kategori *</label>
                            <input type="text" class="form-control" id="editCategoryName" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Deskripsi</label>
                            <textarea class="form-control" id="editCategoryDescription" rows="3"></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Warna</label>
                            <input type="color" class="form-control form-control-color" id="editCategoryColor">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-primary">Update</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Sample categories data
        let categories = [
            { id: 1, name: 'Makanan', description: 'Produk makanan', color: '#FF6384', productCount: 15 },
            { id: 2, name: 'Minuman', description: 'Minuman kemasan', color: '#36A2EB', productCount: 12 },
            { id: 3, name: 'Snack', description: 'Camilan ringan', color: '#FFCE56', productCount: 8 },
            { id: 4, name: 'Rokok', description: 'Produk tembakau', color: '#4BC0C0', productCount: 5 },
            { id: 5, name: 'ATK', description: 'Alat tulis kantor', color: '#9966FF', productCount: 3 },
            { id: 6, name: 'Lainnya', description: 'Produk lainnya', color: '#FF9F40', productCount: 7 }
        ];
        
        function loadCategories() {
            const container = document.getElementById('categoriesContainer');
            container.innerHTML = '';
            
            categories.forEach(category => {
                const col = document.createElement('div');
                col.className = 'col-md-4 mb-3';
                
                col.innerHTML = `
                    <div class="card" style="border-left: 5px solid ${category.color}">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h5 class="card-title">${category.name}</h5>
                                <div class="btn-group btn-group-sm">
                                    <button class="btn btn-warning" onclick="editCategory(${category.id})">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn btn-danger" onclick="deleteCategory(${category.id})">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </div>
                            <p class="card-text text-muted small">${category.description || 'Tidak ada deskripsi'}</p>
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="badge bg-secondary">
                                    ${category.productCount} produk
                                </span>
                                <span class="badge" style="background-color: ${category.color}">
                                    ${category.color}
                                </span>
                            </div>
                        </div>
                    </div>
                `;
                
                container.appendChild(col);
            });
        }
        
        function editCategory(id) {
            const category = categories.find(c => c.id === id);
            if (category) {
                document.getElementById('editCategoryId').value = category.id;
                document.getElementById('editCategoryName').value = category.name;
                document.getElementById('editCategoryDescription').value = category.description || '';
                document.getElementById('editCategoryColor').value = category.color;
                
                const editModal = new bootstrap.Modal(document.getElementById('editCategoryModal'));
                editModal.show();
            }
        }
        
        function deleteCategory(id) {
            if (confirm('Yakin ingin menghapus kategori ini? Produk dalam kategori akan menjadi tanpa kategori.')) {
                // Remove category from array
                categories = categories.filter(c => c.id !== id);
                loadCategories();
                
                // Show success message
                alert('Kategori berhasil dihapus!');
            }
        }
        
        // Form submissions
        document.getElementById('addCategoryForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const newCategory = {
                id: categories.length + 1,
                name: document.getElementById('categoryName').value,
                description: document.getElementById('categoryDescription').value,
                color: document.getElementById('categoryColor').value,
                productCount: 0
            };
            
            categories.push(newCategory);
            loadCategories();
            
            // Reset form and close modal
            this.reset();
            document.getElementById('categoryColor').value = '#007bff';
            bootstrap.Modal.getInstance(document.getElementById('addCategoryModal')).hide();
            
            alert('Kategori berhasil ditambahkan!');
        });
        
        document.getElementById('editCategoryForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const id = parseInt(document.getElementById('editCategoryId').value);
            const category = categories.find(c => c.id === id);
            
            if (category) {
                category.name = document.getElementById('editCategoryName').value;
                category.description = document.getElementById('editCategoryDescription').value;
                category.color = document.getElementById('editCategoryColor').value;
                
                loadCategories();
                bootstrap.Modal.getInstance(document.getElementById('editCategoryModal')).hide();
                
                alert('Kategori berhasil diperbarui!');
            }
        });
        
        // Initialize on load
        document.addEventListener('DOMContentLoaded', loadCategories);
    </script>
</body>
</html>