<%-- 
    Document   : system-settings
    Created on : 2 Dec 2025, 13.06.21
    Author     : ARJUNA.R.PUTRA
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.pos.model.User" %>
<%@ page import="com.pos.dao.SystemSettingsDAO" %>
<%@ page import="com.pos.model.SystemSettings" %>
<%

    User user = null;
    SystemSettings settings = null;
    String message = null;
    String messageType = null;
    
    try {
        user = (User) session.getAttribute("user");
        if (user == null || !"admin".equals(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }
        SystemSettingsDAO settingsDAO = new SystemSettingsDAO();
        settings = settingsDAO.getSettings();
        
        if (settings == null) {
            settings = new SystemSettings();
        }
        
        message = (String) session.getAttribute("message");
        messageType = (String) session.getAttribute("messageType");
        
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>");
        out.println("<h4>Error Loading System Settings:</h4>");
        out.println("<pre>" + e.getMessage() + "</pre>");
        out.println("</div>");
        out.println("<a href='debug.jsp' class='btn btn-warning'>Debug</a>");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pengaturan Sistem - POS System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">
                <i class="fas fa-store"></i> 
                <%= settings.getStoreName() != null && !settings.getStoreName().isEmpty() ? settings.getStoreName() : "POS System" %>
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
        <!-- Notification Message -->
        <% if (message != null) { %>
            <div class="alert alert-<%= "error".equals(messageType) ? "danger" : "success" %> alert-dismissible fade show" role="alert">
                <i class="fas <%= "error".equals(messageType) ? "fa-exclamation-circle" : "fa-check-circle" %> me-2"></i>
                <%= message %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% 
                session.removeAttribute("message");
                session.removeAttribute("messageType");
            %>
        <% } %>
        
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
                    <a href="category-management.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-tags"></i> Kelola Kategori
                    </a>
                    <a href="sales-report.jsp" class="list-group-item list-group-item-action">
                        <i class="fas fa-chart-bar"></i> Laporan Penjualan
                    </a>
                    <a href="system-settings.jsp" class="list-group-item list-group-item-action active">
                        <i class="fas fa-cog"></i> Pengaturan Sistem
                    </a>
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="col-md-9 col-lg-10">
                <h2 class="mb-4"><i class="fas fa-cog"></i> Pengaturan Sistem</h2>
                
                <!-- Settings Tabs -->
                <ul class="nav nav-tabs mb-4" id="settingsTab" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="general-tab" data-bs-toggle="tab" data-bs-target="#general" type="button">
                            <i class="fas fa-sliders-h"></i> Umum
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="receipt-tab" data-bs-toggle="tab" data-bs-target="#receipt" type="button">
                            <i class="fas fa-receipt"></i> Struk
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="tax-tab" data-bs-toggle="tab" data-bs-target="#tax" type="button">
                            <i class="fas fa-percentage"></i> Pajak & Diskon
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="backup-tab" data-bs-toggle="tab" data-bs-target="#backup" type="button">
                            <i class="fas fa-database"></i> Backup
                        </button>
                    </li>
                </ul>
                
                <div class="tab-content" id="settingsTabContent">
                    <!-- General Settings -->
                    <div class="tab-pane fade show active" id="general" role="tabpanel">
                        <div class="card">
                            <div class="card-body">
                                <form id="generalSettingsForm" action="SystemSettingsServlet" method="POST">
                                    <input type="hidden" name="action" value="updateGeneral">
                                    
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Nama Toko *</label>
                                            <input type="text" class="form-control" name="storeName" 
                                                   value="<%= settings.getStoreName() != null ? settings.getStoreName() : "Toko Makmur Jaya" %>" 
                                                   required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Alamat Toko</label>
                                            <textarea class="form-control" name="storeAddress" rows="2"><%= settings.getStoreAddress() != null ? settings.getStoreAddress() : "Jl. Raya No. 123, Jakarta" %></textarea>
                                        </div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Telepon</label>
                                            <input type="text" class="form-control" name="phone" 
                                                   value="<%= settings.getPhone() != null ? settings.getPhone() : "021-1234567" %>">
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Email</label>
                                            <input type="email" class="form-control" name="email" 
                                                   value="<%= settings.getEmail() != null ? settings.getEmail() : "info@tokomakmurjaya.com" %>">
                                        </div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Mata Uang</label>
                                            <select class="form-control" name="currency">
                                                <option value="IDR" <%= "IDR".equals(settings.getCurrency()) ? "selected" : "" %>>IDR (Rupiah)</option>
                                                <option value="USD" <%= "USD".equals(settings.getCurrency()) ? "selected" : "" %>>USD (Dollar)</option>
                                            </select>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Format Tanggal</label>
                                            <select class="form-control" name="dateFormat">
                                                <option value="DD/MM/YYYY" <%= "DD/MM/YYYY".equals(settings.getDateFormat()) ? "selected" : "" %>>DD/MM/YYYY</option>
                                                <option value="MM/DD/YYYY" <%= "MM/DD/YYYY".equals(settings.getDateFormat()) ? "selected" : "" %>>MM/DD/YYYY</option>
                                                <option value="YYYY-MM-DD" <%= "YYYY-MM-DD".equals(settings.getDateFormat()) ? "selected" : "" %>>YYYY-MM-DD</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="autoPrint" name="autoPrint" 
                                                   <%= settings.isAutoPrint() ? "checked" : "" %>>
                                            <label class="form-check-label" for="autoPrint">
                                                Cetak struk otomatis setelah transaksi
                                            </label>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="showStockAlert" name="showStockAlert"
                                                   <%= settings.isShowStockAlert() ? "checked" : "" %>>
                                            <label class="form-check-label" for="showStockAlert">
                                                Tampilkan peringatan stok rendah
                                            </label>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-save"></i> Simpan Pengaturan
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Receipt Settings -->
                    <div class="tab-pane fade" id="receipt" role="tabpanel">
                        <div class="card">
                            <div class="card-body">
                                <form id="receiptSettingsForm" action="SystemSettingsServlet" method="POST">
                                    <input type="hidden" name="action" value="updateReceipt">
                                    
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Header Struk</label>
                                            <textarea class="form-control" name="receiptHeader" rows="3"><%= settings.getReceiptHeader() != null ? settings.getReceiptHeader() : "TOKO Bersama\nJl. Raya No. 123, Jakarta\nTelp: 021-1234567" %></textarea>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Footer Struk</label>
                                            <textarea class="form-control" name="receiptFooter" rows="3"><%= settings.getReceiptFooter() != null ? settings.getReceiptFooter() : "Terima kasih telah berbelanja\n*** Barang yang sudah dibeli tidak dapat ditukar ***\nwww.tokomakmurjaya.com" %></textarea>
                                        </div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-4">
                                            <label class="form-label">Lebar Struk (mm)</label>
                                            <input type="number" class="form-control" name="receiptWidth" 
                                                   value="<%= settings.getReceiptWidth() %>" min="50" max="100">
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label">Font Size</label>
                                            <select class="form-control" name="receiptFontSize">
                                                <option value="Kecil" <%= "Kecil".equals(settings.getReceiptFontSize()) ? "selected" : "" %>>Kecil (8px)</option>
                                                <option value="Normal" <%= "Normal".equals(settings.getReceiptFontSize()) || settings.getReceiptFontSize() == null ? "selected" : "" %>>Normal (10px)</option>
                                                <option value="Besar" <%= "Besar".equals(settings.getReceiptFontSize()) ? "selected" : "" %>>Besar (12px)</option>
                                            </select>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label">Jumlah Salinan</label>
                                            <input type="number" class="form-control" name="receiptCopies" 
                                                   value="<%= settings.getReceiptCopies() %>" min="1" max="3">
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Preview Struk</label>
                                        <div class="border p-3 bg-light">
                                            <pre style="font-family: 'Courier New', monospace; font-size: <%= "Kecil".equals(settings.getReceiptFontSize()) ? "8px" : "Normal".equals(settings.getReceiptFontSize()) ? "10px" : "12px" %>">
================================
       <%= settings.getStoreName() != null ? settings.getStoreName() : "TOKO MAKMUR JAYA" %>
      <%= settings.getStoreAddress() != null ? settings.getStoreAddress() : "Jl. Raya No. 123, Jakarta" %>
         Telp: <%= settings.getPhone() != null ? settings.getPhone() : "021-1234567" %>
================================
Tanggal: <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new java.util.Date()) %>
Kasir   : <%= user.getFullName() %>
================================
1. Indomie Goreng   2 x 5,000
                    10,000
2. Aqua 600ml       1 x 3,000
                     3,000
================================
Total   : Rp 13,000
Cash    : Rp 20,000
Kembali : Rp 7,000
================================
<%= settings.getReceiptFooter() != null ? settings.getReceiptFooter() : "Terima kasih telah berbelanja" %>
================================</pre>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-save"></i> Simpan Pengaturan Struk
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Tax & Discount Settings -->
                    <div class="tab-pane fade" id="tax" role="tabpanel">
                        <div class="card">
                            <div class="card-body">
                                <form id="taxSettingsForm" action="SystemSettingsServlet" method="POST">
                                    <input type="hidden" name="action" value="updateTax">
                                    
                                    <h5 class="mb-3">Pengaturan Pajak</h5>
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Aktifkan Pajak</label>
                                            <div class="form-check">
                                                <input class="form-check-input" type="radio" name="taxEnabled" id="taxYes" value="on" 
                                                       <%= settings.isTaxEnabled() ? "checked" : "" %>>
                                                <label class="form-check-label" for="taxYes">Ya</label>
                                            </div>
                                            <div class="form-check">
                                                <input class="form-check-input" type="radio" name="taxEnabled" id="taxNo" value="off"
                                                       <%= !settings.isTaxEnabled() ? "checked" : "" %>>
                                                <label class="form-check-label" for="taxNo">Tidak</label>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Persentase Pajak (%)</label>
                                            <input type="number" class="form-control" name="taxPercentage" 
                                                   value="<%= settings.getTaxPercentage() %>" step="0.1" min="0" max="100" required>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Nama Pajak</label>
                                        <input type="text" class="form-control" name="taxName" 
                                               value="<%= settings.getTaxName() != null ? settings.getTaxName() : "PPN" %>" required>
                                    </div>
                                    
                                    <hr class="my-4">
                                    
                                    <h5 class="mb-3">Pengaturan Diskon</h5>
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Diskon Member (%)</label>
                                            <input type="number" class="form-control" name="memberDiscount" 
                                                   value="<%= settings.getMemberDiscount() %>" step="0.1" min="0" max="100" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Minimal Transaksi Diskon</label>
                                            <div class="input-group">
                                                <span class="input-group-text">Rp</span>
                                                <input type="number" class="form-control" name="minDiscountTransaction" 
                                                       value="<%= (int)settings.getMinDiscountTransaction() %>" required>
                                            </div>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-save"></i> Simpan Pengaturan Pajak & Diskon
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Backup Settings -->
                    <div class="tab-pane fade" id="backup" role="tabpanel">
                        <div class="card">
                            <div class="card-body">
                                <form id="backupSettingsForm" action="SystemSettingsServlet" method="POST">
                                    <input type="hidden" name="action" value="updateBackup">
                                    
                                    <h5 class="mb-3">Backup Database</h5>
                                    <div class="alert alert-info">
                                        <i class="fas fa-info-circle"></i>
                                        Backup database dilakukan secara otomatis.
                                        Backup terakhir: <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %>
                                    </div>
                                    
                                    <div class="row mb-4">
                                        <div class="col-md-6">
                                            <div class="card">
                                                <div class="card-body text-center">
                                                    <i class="fas fa-download fa-3x text-primary mb-3"></i>
                                                    <h5>Unduh Backup</h5>
                                                    <p>Download backup terbaru dalam format SQL</p>
                                                    <button type="button" class="btn btn-primary" onclick="downloadBackup()">
                                                        <i class="fas fa-download"></i> Download Backup
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="card">
                                                <div class="card-body text-center">
                                                    <i class="fas fa-upload fa-3x text-success mb-3"></i>
                                                    <h5>Restore Backup</h5>
                                                    <p>Upload file SQL untuk restore database</p>
                                                    <input type="file" class="form-control mb-2" accept=".sql">
                                                    <button type="button" class="btn btn-success">
                                                        <i class="fas fa-upload"></i> Upload & Restore
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <h5 class="mb-3">Backup Otomatis</h5>
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Frekuensi Backup</label>
                                            <select class="form-control" name="backupFrequency">
                                                <option value="Setiap Hari" <%= "Setiap Hari".equals(settings.getBackupFrequency()) ? "selected" : "" %>>Setiap Hari</option>
                                                <option value="Setiap Minggu" <%= "Setiap Minggu".equals(settings.getBackupFrequency()) || settings.getBackupFrequency() == null ? "selected" : "" %>>Setiap Minggu</option>
                                                <option value="Setiap Bulan" <%= "Setiap Bulan".equals(settings.getBackupFrequency()) ? "selected" : "" %>>Setiap Bulan</option>
                                            </select>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Waktu Backup</label>
                                            <input type="time" class="form-control" name="backupTime" 
                                                   value="<%= settings.getBackupTime() != null ? settings.getBackupTime() : "02:00" %>">
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Jumlah Backup Disimpan</label>
                                        <input type="number" class="form-control" name="backupKeepDays" 
                                               value="<%= settings.getBackupKeepDays() %>" min="7" max="365">
                                        <small class="text-muted">Jumlah hari backup yang disimpan (7-365 hari)</small>
                                    </div>
                                    <div class="mb-3">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="cloudBackup" name="cloudBackup"
                                                   <%= settings.isCloudBackup() ? "checked" : "" %>>
                                            <label class="form-check-label" for="cloudBackup">
                                                Simpan backup ke cloud
                                            </label>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-save"></i> Simpan Pengaturan Backup
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Form validation
        document.querySelectorAll('form').forEach(form => {
            form.addEventListener('submit', function(e) {
                // Validasi form sebelum submit
                const requiredFields = this.querySelectorAll('[required]');
                let isValid = true;
                
                requiredFields.forEach(field => {
                    if (!field.value.trim()) {
                        isValid = false;
                        field.classList.add('is-invalid');
                    } else {
                        field.classList.remove('is-invalid');
                    }
                });
                
                if (!isValid) {
                    e.preventDefault();
                    alert('Harap isi semua field yang wajib diisi!');
                }
            });
        });
        
        function downloadBackup() {
            if (confirm('Apakah Anda yakin ingin mendownload backup database?')) {
                // Simulate download
                alert('Backup database akan diunduh sebagai file .sql');
                // In real application: window.location.href = 'DownloadBackupServlet';
            }
        }
        
        // Initialize tabs
        const triggerTabList = document.querySelectorAll('#settingsTab button');
        triggerTabList.forEach(triggerEl => {
            const tabTrigger = new bootstrap.Tab(triggerEl);
            triggerEl.addEventListener('click', event => {
                event.preventDefault();
                tabTrigger.show();
            });
        });
    </script>
</body>
</html>