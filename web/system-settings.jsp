<%-- 
    Document   : system-settings
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
    <title>Pengaturan Sistem - POS System</title>
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
                                <form id="generalSettingsForm">
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Nama Toko *</label>
                                            <input type="text" class="form-control" value="Toko Makmur Jaya" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Alamat Toko</label>
                                            <textarea class="form-control" rows="2">Jl. Raya No. 123, Jakarta</textarea>
                                        </div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Telepon</label>
                                            <input type="text" class="form-control" value="021-1234567">
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Email</label>
                                            <input type="email" class="form-control" value="info@tokomakmurjaya.com">
                                        </div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Mata Uang</label>
                                            <select class="form-control">
                                                <option selected>IDR (Rupiah)</option>
                                                <option>USD (Dollar)</option>
                                            </select>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Format Tanggal</label>
                                            <select class="form-control">
                                                <option selected>DD/MM/YYYY</option>
                                                <option>MM/DD/YYYY</option>
                                                <option>YYYY-MM-DD</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="autoPrint" checked>
                                            <label class="form-check-label" for="autoPrint">
                                                Cetak struk otomatis setelah transaksi
                                            </label>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="showStockAlert" checked>
                                            <label class="form-check-label" for="showStockAlert">
                                                Tampilkan peringatan stok rendah
                                            </label>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-primary">Simpan Pengaturan</button>
                                </form>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Receipt Settings -->
                    <div class="tab-pane fade" id="receipt" role="tabpanel">
                        <div class="card">
                            <div class="card-body">
                                <form id="receiptSettingsForm">
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Header Struk</label>
                                            <textarea class="form-control" rows="3">TOKO MAKMUR JAYA
Jl. Raya No. 123, Jakarta
Telp: 021-1234567</textarea>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Footer Struk</label>
                                            <textarea class="form-control" rows="3">Terima kasih telah berbelanja
*** Barang yang sudah dibeli tidak dapat ditukar ***
www.tokomakmurjaya.com</textarea>
                                        </div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-4">
                                            <label class="form-label">Lebar Struk (mm)</label>
                                            <input type="number" class="form-control" value="80" min="50" max="100">
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label">Font Size</label>
                                            <select class="form-control">
                                                <option>Kecil (8px)</option>
                                                <option selected>Normal (10px)</option>
                                                <option>Besar (12px)</option>
                                            </select>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label">Jumlah Salinan</label>
                                            <input type="number" class="form-control" value="1" min="1" max="3">
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Template Struk</label>
                                        <div class="border p-3 bg-light">
                                            <pre style="font-family: 'Courier New', monospace;">
================================
       TOKO MAKMUR JAYA
      Jl. Raya No. 123, Jakarta
         Telp: 021-1234567
================================
Tanggal: 01/12/2024 10:30:15
Kasir   : Admin
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
Terima kasih telah berbelanja
================================</pre>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-primary">Simpan Pengaturan Struk</button>
                                </form>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Tax & Discount Settings -->
                    <div class="tab-pane fade" id="tax" role="tabpanel">
                        <div class="card">
                            <div class="card-body">
                                <form id="taxSettingsForm">
                                    <h5 class="mb-3">Pengaturan Pajak</h5>
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Aktifkan Pajak</label>
                                            <div class="form-check">
                                                <input class="form-check-input" type="radio" name="taxEnabled" id="taxYes" checked>
                                                <label class="form-check-label" for="taxYes">Ya</label>
                                            </div>
                                            <div class="form-check">
                                                <input class="form-check-input" type="radio" name="taxEnabled" id="taxNo">
                                                <label class="form-check-label" for="taxNo">Tidak</label>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Persentase Pajak (%)</label>
                                            <input type="number" class="form-control" value="10" step="0.1" min="0" max="100">
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Nama Pajak</label>
                                        <input type="text" class="form-control" value="PPN">
                                    </div>
                                    
                                    <hr class="my-4">
                                    
                                    <h5 class="mb-3">Pengaturan Diskon</h5>
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Diskon Member (%)</label>
                                            <input type="number" class="form-control" value="5" step="0.1" min="0" max="100">
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Minimal Transaksi Diskon</label>
                                            <div class="input-group">
                                                <span class="input-group-text">Rp</span>
                                                <input type="number" class="form-control" value="100000">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Kode Diskon Khusus</label>
                                        <div class="input-group">
                                            <input type="text" class="form-control" placeholder="Masukkan kode diskon">
                                            <button class="btn btn-outline-secondary" type="button">Tambah</button>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-primary">Simpan Pengaturan Pajak & Diskon</button>
                                </form>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Backup Settings -->
                    <div class="tab-pane fade" id="backup" role="tabpanel">
                        <div class="card">
                            <div class="card-body">
                                <h5 class="mb-3">Backup Database</h5>
                                <div class="alert alert-info">
                                    <i class="fas fa-info-circle"></i>
                                    Backup database dilakukan secara otomatis setiap hari pukul 02:00 WIB.
                                    Backup terakhir: 01/12/2024 02:00
                                </div>
                                
                                <div class="row mb-4">
                                    <div class="col-md-6">
                                        <div class="card">
                                            <div class="card-body text-center">
                                                <i class="fas fa-download fa-3x text-primary mb-3"></i>
                                                <h5>Unduh Backup</h5>
                                                <p>Download backup terbaru dalam format SQL</p>
                                                <button class="btn btn-primary" onclick="downloadBackup()">
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
                                                <button class="btn btn-success">
                                                    <i class="fas fa-upload"></i> Upload & Restore
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <h5 class="mb-3">Backup Otomatis</h5>
                                <form id="backupSettingsForm">
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Frekuensi Backup</label>
                                            <select class="form-control">
                                                <option>Setiap Hari</option>
                                                <option selected>Setiap Minggu</option>
                                                <option>Setiap Bulan</option>
                                            </select>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Waktu Backup</label>
                                            <input type="time" class="form-control" value="02:00">
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Jumlah Backup Disimpan</label>
                                        <input type="number" class="form-control" value="30" min="7" max="365">
                                        <small class="text-muted">Jumlah hari backup yang disimpan (7-365 hari)</small>
                                    </div>
                                    <div class="mb-3">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="cloudBackup" checked>
                                            <label class="form-check-label" for="cloudBackup">
                                                Simpan backup ke cloud
                                            </label>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-primary">Simpan Pengaturan Backup</button>
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
        // Form submissions
        document.querySelectorAll('form').forEach(form => {
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                // Simulate saving
                alert('Pengaturan berhasil disimpan!');
                // In real application, send to server
                // fetch('SystemSettingsServlet', { method: 'POST', body: new FormData(this) })
            });
        });
        
        function downloadBackup() {
            // Simulate download
            alert('Backup database akan diunduh sebagai file .sql');
            // In real application: window.location.href = 'DownloadBackupServlet';
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