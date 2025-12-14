<%-- 
    Document   : user-management
    Created on : 2 Dec 2025, 13.06.21
    Author     : ARJUNA.R.PUTRA
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.pos.model.User" %>
<%@ page import="com.pos.dao.UserManagementDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Debug info
    System.out.println("=== USER MANAGEMENT JSP STARTED ===");
    
    User user = (User) session.getAttribute("user");
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
    
    UserManagementDAO userDAO = new UserManagementDAO();
    List<User> users = new ArrayList<>();
    
    try {
        System.out.println("Getting all users...");
        users = userDAO.getAllUsers();
        System.out.println("Successfully retrieved " + users.size() + " users");
    } catch (Exception e) {
        System.err.println("Error getting users: " + e.getMessage());
        e.printStackTrace();
        out.println("<div class='alert alert-danger'>Error loading users: " + e.getMessage() + "</div>");
    }
    
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
    
    int totalUsers = users.size();
    int activeUsers = 0;
    int cashierCount = 0;
    int adminCount = 0;
    
    for (User u : users) {
        if (u.isActive()) activeUsers++;
        if ("cashier".equals(u.getRole())) cashierCount++;
        if ("admin".equals(u.getRole())) adminCount++;
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola User - POS System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        .action-buttons .btn-sm {
            padding: 2px 8px;
            font-size: 12px;
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
                    <a href="user-management.jsp" class="list-group-item list-group-item-action active">
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
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="col-md-9 col-lg-10">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="fas fa-users"></i> Kelola User</h2>
                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addUserModal">
                        <i class="fas fa-user-plus"></i> Tambah User Baru
                    </button>
                </div>
                
                <!-- Messages -->
                <% if (message != null) { %>
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle"></i> <%= message %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>
                
                <% if (error != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-triangle"></i> <%= error %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>
                
                <!-- Debug Info -->
                <div class="alert alert-info alert-dismissible fade show" role="alert">
                    <strong><i class="fas fa-info-circle"></i> Info:</strong> 
                    Menampilkan <%= totalUsers %> user dari database
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                
                <!-- Stats Cards -->
                <div class="row mb-4">
                    <div class="col-md-3 mb-3">
                        <div class="card bg-primary text-white shadow">
                            <div class="card-body text-center">
                                <h5 class="card-title">Total User</h5>
                                <p class="card-text display-6"><%= totalUsers %></p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-3">
                        <div class="card bg-success text-white shadow">
                            <div class="card-body text-center">
                                <h5 class="card-title">User Aktif</h5>
                                <p class="card-text display-6"><%= activeUsers %></p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-3">
                        <div class="card bg-warning text-white shadow">
                            <div class="card-body text-center">
                                <h5 class="card-title">Kasir</h5>
                                <p class="card-text display-6"><%= cashierCount %></p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-3">
                        <div class="card bg-info text-white shadow">
                            <div class="card-body text-center">
                                <h5 class="card-title">Admin</h5>
                                <p class="card-text display-6"><%= adminCount %></p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- User Table -->
                <div class="card shadow">
                    <div class="card-header bg-light">
                        <h5 class="mb-0">Daftar User</h5>
                    </div>
                    <div class="card-body">
                        <% if (users.isEmpty()) { %>
                        <div class="text-center py-5">
                            <i class="fas fa-users fa-4x text-muted mb-3"></i>
                            <h5 class="text-muted">Tidak ada data user</h5>
                            <p class="text-muted">Klik "Tambah User Baru" untuk menambahkan user pertama</p>
                        </div>
                        <% } else { %>
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th>ID</th>
                                        <th>Username</th>
                                        <th>Nama Lengkap</th>
                                        <th>Email</th>
                                        <th>Role</th>
                                        <th>Status</th>
                                        <th>Tanggal Dibuat</th>
                                        <th>Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (User u : users) { 
                                        String createdAt = "";
                                        if (u.getCreatedAt() != null) {
                                            createdAt = dateFormat.format(u.getCreatedAt());
                                        }
                                    %>
                                    <tr>
                                        <td><%= u.getId() %></td>
                                        <td><strong><%= u.getUsername() %></strong></td>
                                        <td><%= u.getFullName() %></td>
                                        <td><%= u.getEmail() != null ? u.getEmail() : "-" %></td>
                                        <td>
                                            <span class="badge <%= "admin".equals(u.getRole()) ? "bg-danger" : "bg-primary" %>">
                                                <%= "admin".equals(u.getRole()) ? "Admin" : "Kasir" %>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge <%= u.isActive() ? "bg-success" : "bg-secondary" %>">
                                                <%= u.isActive() ? "Aktif" : "Nonaktif" %>
                                            </span>
                                        </td>
                                        <td><%= createdAt %></td>
                                        <td>
                                            <div class="action-buttons">
                                                <button class="btn btn-sm btn-warning" 
                                                        onclick="editUser(<%= u.getId() %>, '<%= u.getUsername() %>', '<%= u.getFullName() %>', '<%= u.getEmail() != null ? u.getEmail() : "" %>', '<%= u.getRole() %>', <%= u.isActive() %>)">
                                                    <i class="fas fa-edit"></i>
                                                </button>
                                                <% if (u.getId() != user.getId()) { %>
                                                <form action="UserManagementServlet" method="post" style="display: inline;">
                                                    <input type="hidden" name="action" value="toggleStatus">
                                                    <input type="hidden" name="userId" value="<%= u.getId() %>">
                                                    <button type="submit" class="btn btn-sm <%= u.isActive() ? "btn-secondary" : "btn-success" %>"
                                                            onclick="return confirm('Yakin ingin <%= u.isActive() ? "nonaktifkan" : "aktifkan" %> user <%= u.getUsername() %>?')">
                                                        <i class="fas <%= u.isActive() ? "fa-ban" : "fa-check" %>"></i>
                                                    </button>
                                                </form>
                                                <form action="UserManagementServlet" method="post" style="display: inline;">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="userId" value="<%= u.getId() %>">
                                                    <button type="submit" class="btn btn-sm btn-danger" 
                                                            onclick="return confirm('Yakin ingin menghapus user <%= u.getUsername() %>? Tindakan ini tidak dapat dibatalkan!')">
                                                        <i class="fas fa-trash"></i>
                                                    </button>
                                                </form>
                                                <% } else { %>
                                                <span class="badge bg-info">Anda</span>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Add User Modal -->
    <div class="modal fade" id="addUserModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="UserManagementServlet" method="post" id="addUserForm">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fas fa-user-plus"></i> Tambah User Baru</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="action" value="add">
                        <div class="mb-3">
                            <label class="form-label">Username *</label>
                            <input type="text" class="form-control" name="username" required 
                                   placeholder="username unik" maxlength="50">
                            <div class="form-text">Username harus unik dan tidak boleh mengandung spasi</div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Password *</label>
                                <input type="password" class="form-control" name="password" id="password" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Konfirmasi Password *</label>
                                <input type="password" class="form-control" name="confirmPassword" id="confirmPassword" required>
                            </div>
                        </div>
                        <div id="passwordError" class="text-danger small mb-3" style="display: none;">
                            Password tidak sama!
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Nama Lengkap *</label>
                            <input type="text" class="form-control" name="fullName" required 
                                   placeholder="Nama lengkap user" maxlength="100">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <input type="email" class="form-control" name="email" 
                                   placeholder="email@example.com" maxlength="100">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Role *</label>
                            <select class="form-control" name="role" required>
                                <option value="cashier">Kasir</option>
                                <option value="admin">Admin</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-primary">Simpan User</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Edit User Modal -->
    <div class="modal fade" id="editUserModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="UserManagementServlet" method="post">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fas fa-edit"></i> Edit User</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="userId" id="editUserId">
                        <div class="mb-3">
                            <label class="form-label">Username</label>
                            <input type="text" class="form-control" id="editUsername" readonly>
                            <div class="form-text">Username tidak dapat diubah</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Password Baru</label>
                            <input type="password" class="form-control" name="password" 
                                   placeholder="Kosongkan jika tidak ingin mengubah">
                            <div class="form-text">Minimal 6 karakter</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Nama Lengkap *</label>
                            <input type="text" class="form-control" name="fullName" id="editFullName" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <input type="email" class="form-control" name="email" id="editEmail">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Role *</label>
                            <select class="form-control" name="role" id="editRole" required>
                                <option value="cashier">Kasir</option>
                                <option value="admin">Admin</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" name="isActive" id="editIsActive">
                                <label class="form-check-label">User Aktif</label>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-primary">Update User</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Password validation for add user form
        document.getElementById('addUserForm').addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const errorDiv = document.getElementById('passwordError');
            
            if (password !== confirmPassword) {
                e.preventDefault();
                errorDiv.style.display = 'block';
                document.getElementById('confirmPassword').focus();
            } else {
                errorDiv.style.display = 'none';
            }
        });
        
        // Edit user function
        function editUser(id, username, fullName, email, role, isActive) {
            document.getElementById('editUserId').value = id;
            document.getElementById('editUsername').value = username;
            document.getElementById('editFullName').value = fullName;
            document.getElementById('editEmail').value = email;
            document.getElementById('editRole').value = role;
            document.getElementById('editIsActive').checked = isActive;
            
            const editModal = new bootstrap.Modal(document.getElementById('editUserModal'));
            editModal.show();
        }
        
        // Clear form when modal is hidden
        document.getElementById('addUserModal').addEventListener('hidden.bs.modal', function () {
            document.getElementById('addUserForm').reset();
            document.getElementById('passwordError').style.display = 'none';
        });
    </script>
</body>
</html>