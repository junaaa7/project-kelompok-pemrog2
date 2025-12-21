<%-- 
    Document   : index.jsp
    Created on : 28 Nov 2025, 23.34.08
    Author     : ARJUNA.R.PUTRA
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.pos.service.CartService" %>
<%@ page import="com.pos.model.Product" %>
<%@ page import="com.pos.model.User" %>
<%@ page import="java.util.List" %>
<%

    Object userObj = session.getAttribute("user");
    boolean isLoggedIn = (userObj != null);

    if (!isLoggedIn) {
        response.sendRedirect("login.jsp");
        return;
    }

    if (userObj instanceof User) {
        User user = (User) userObj;
        if ("admin".equals(user.getRole())) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
    }
    

    CartService cartService = (CartService) session.getAttribute("cartService");
    if (cartService == null) {
        cartService = new CartService();
        session.setAttribute("cartService", cartService);
        System.out.println("index.jsp: Created new CartService");
    }

    List<Product> products = cartService.getAllProducts();
    System.out.println("index.jsp: Retrieved " + (products != null ? products.size() : "null") + " products");

    if (products != null) {
        for (Product p : products) {
            System.out.println("index.jsp DEBUG: " + p.getCode() + " - " + p.getName() + " - Rp" + p.getPrice());
        }
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kasir POS - Transaksi</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background-color: #f5f5f5;
            color: #333;
            line-height: 1.6;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px 0;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        
        header h1 {
            text-align: center;
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .user-info {
            text-align: center;
            padding: 0 20px;
            font-size: 0.9em;
            margin-top: 10px;
        }
        
        .menu-bar {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin: 20px 0;
        }
        
        .btn {
            background: #4CAF50;
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 5px;
            text-decoration: none;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-block;
            text-align: center;
        }
        
        .btn:hover {
            background: #45a049;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }
        
        .btn-secondary {
            background: #f0ad4e;
        }
        
        .btn-secondary:hover {
            background: #ec971f;
        }
        
        .btn-danger {
            background: #d9534f;
        }
        
        .btn-danger:hover {
            background: #c9302c;
        }
        
        .cart-info {
            background: #e7f3ff;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .cart-count {
            background: #ff6b6b;
            color: white;
            padding: 5px 10px;
            border-radius: 20px;
            font-weight: bold;
        }
        
        .products-container {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-top: 20px;
        }
        
        .products-container h2 {
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #4CAF50;
        }
        
        .product-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        .product-table th {
            background: #4CAF50;
            color: white;
            padding: 12px;
            text-align: left;
        }
        
        .product-table td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        
        .product-table tr:hover {
            background: #f5f5f5;
        }
        
        .product-table input[type="number"] {
            width: 70px;
            padding: 5px;
            border: 1px solid #ddd;
            border-radius: 3px;
        }
        
        .product-table button {
            background: #2196F3;
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 3px;
            cursor: pointer;
            transition: background 0.3s;
        }
        
        .product-table button:hover {
            background: #0b7dda;
        }
        
        .error-message {
            background: #ffebee;
            color: #c62828;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            border-left: 4px solid #c62828;
        }
        
        .debug-info {
            background: #e8f5e8;
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
            font-family: monospace;
            font-size: 12px;
        }
        
        @media (max-width: 768px) {
            .menu-bar {
                flex-direction: column;
                align-items: center;
            }
            
            .btn {
                width: 80%;
                margin-bottom: 10px;
            }
            
            .product-table {
                font-size: 14px;
            }
            
            .product-table input[type="number"] {
                width: 50px;
            }
        }
        
        .cashier-badge {
            background: #28a745;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
            display: inline-block;
            margin-top: 5px;
        }
        
        .nav-back {
            position: absolute;
            left: 20px;
            top: 20px;
        }
        
        .nav-back a {
            color: white;
            text-decoration: none;
            background: rgba(255, 255, 255, 0.2);
            padding: 5px 15px;
            border-radius: 5px;
            transition: background 0.3s;
        }
        
        .nav-back a:hover {
            background: rgba(255, 255, 255, 0.3);
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <!-- Tombol kembali ke dashboard -->
            <div class="nav-back">
                <a href="dashboard.jsp">← Dashboard</a>
            </div>
            
            <h1>🏪 Kasir POS - Transaksi</h1>
            <div class="user-info">
                <% if (userObj != null) { 
                    User user = (User) userObj;
                %>
                    <p>Selamat datang, <strong><%= user.getFullName() %></strong></p>
                    <span class="cashier-badge">KASIR</span>
                <% } %>
            </div>
        </header>
        
        <div class="menu-bar">
            <a href="cart.jsp" class="btn">🛒 Keranjang Belanja 
                <% if (cartService.getCartSize() > 0) { %>
                    <span class="cart-count"><%= cartService.getCartSize() %></span>
                <% } %>
            </a>
            <a href="dashboard.jsp" class="btn btn-secondary">📊 Dashboard</a>
        </div>
        
        <div class="cart-info">
            <div>
                <strong>Keranjang:</strong> <%= cartService.getCartSize() %> item
                <strong>Total:</strong> Rp <%= String.format("%,.2f", cartService.calculateTotal()) %>
            </div>
     
        </div>
        
        <div class="products-container">
            <h2>📋 Daftar Produk Tersedia</h2>
            
            <%-- Tampilkan pesan error jika tidak ada produk --%>
            <% if (products == null || products.isEmpty()) { %>
                <div class="error-message">
                    <h3>⚠️ Tidak Ada Produk yang Ditemukan!</h3>
                    <p>Kemungkinan penyebab:</p>
                    <ul>
                        <li>Database belum terisi data produk</li>
                        <li>Koneksi database bermasalah</li>
                        <li>Query SQL tidak sesuai dengan struktur database</li>
                        <li>Semua produk dalam status tidak aktif (is_active = FALSE)</li>
                    </ul>
                    <p>
                        <a href="product-form.jsp" class="btn">Tambah Produk Baru</a>
                        <a href="javascript:location.reload()" class="btn btn-secondary">Refresh Halaman</a>
                    </p>
                </div>
                
                <%-- Debug info --%>
                <div class="debug-info">
                    <strong>Debug Information:</strong><br>
                    Products List: <%= products %><br>
                    List Size: <%= products != null ? products.size() : "null" %><br>
                    Session ID: <%= session.getId() %><br>
                    Cart Service: <%= cartService %>
                </div>
            <% } else { %>
                <table class="product-table">
                    <thead>
                        <tr>
                            <th>Kode</th>
                            <th>Nama Produk</th>
                            <th>Kategori</th>
                            <th>Harga (Rp)</th>
                            <th>Stok</th>
                            <th>Deskripsi</th>
                            <th>Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Product product : products) { %>
                        <tr>
                            <td><strong><%= product.getCode() %></strong></td>
                            <td><%= product.getName() %></td>
                            <td>
                                <% if (product.getCategoryName() != null && !product.getCategoryName().isEmpty()) { %>
                                    <%= product.getCategoryName() %>
                                <% } else { %>
                                    <span style="color: #999; font-style: italic;">Tanpa Kategori</span>
                                <% } %>
                            </td>
                            <td style="font-weight: bold; color: #2e7d32;">
                                Rp <%= String.format("%,.2f", product.getPrice()) %>
                            </td>
                            <td>
                                <% if (product.getStock() > 10) { %>
                                    <span style="color: #4CAF50;"><%= product.getStock() %></span>
                                <% } else if (product.getStock() > 0) { %>
                                    <span style="color: #ff9800;"><%= product.getStock() %></span>
                                <% } else { %>
                                    <span style="color: #f44336;">Habis</span>
                                <% } %>
                            </td>
                            <td style="font-size: 0.9em; color: #666;">
                                <%= (product.getDescription() != null && product.getDescription().length() > 50) ? 
                                    product.getDescription().substring(0, 50) + "..." : 
                                    (product.getDescription() != null ? product.getDescription() : "-") %>
                            </td>
                            <td>
                                <form action="AddToCartServlet" method="post" style="display: inline;">
                                    <input type="hidden" name="productCode" value="<%= product.getCode() %>">
                                    <input type="number" name="quantity" value="1" min="1" 
                                           max="<%= product.getStock() %>" 
                                           <% if (product.getStock() <= 0) { %>disabled<% } %>>
                                    <button type="submit" <% if (product.getStock() <= 0) { %>disabled<% } %>>
                                        <%= product.getStock() > 0 ? "➕ Tambah" : "❌ Habis" %>
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                
                <div style="margin-top: 20px; text-align: center; color: #666;">
                    <p>Total <strong><%= products.size() %></strong> produk ditemukan</p>
                </div>
            <% } %>
        </div>
        
        <%-- Quick Stats --%>
        <div style="display: flex; justify-content: space-around; margin-top: 30px; flex-wrap: wrap;">
            <div style="background: white; padding: 15px; border-radius: 5px; text-align: center; min-width: 200px; margin: 10px;">
                <h3>📦 Total Produk</h3>
                <p style="font-size: 2em; color: #2196F3;"><%= products != null ? products.size() : 0 %></p>
            </div>
            <div style="background: white; padding: 15px; border-radius: 5px; text-align: center; min-width: 200px; margin: 10px;">
                <h3>🛒 Item Keranjang</h3>
                <p style="font-size: 2em; color: #4CAF50;"><%= cartService.getCartSize() %></p>
            </div>
            <div style="background: white; padding: 15px; border-radius: 5px; text-align: center; min-width: 200px; margin: 10px;">
                <h3>💰 Total Belanja</h3>
                <p style="font-size: 1.5em; color: #FF9800;">Rp <%= String.format("%,.2f", cartService.calculateTotal()) %></p>
            </div>
        </div>
        
        <footer style="margin-top: 50px; text-align: center; color: #666; font-size: 0.9em;">
            <p>Sistem Kasir POS &copy; 2024 - Dibangun dengan Java Servlet & JSP</p>
            <p>User: <%= userObj != null ? ((User)userObj).getFullName() : "Guest" %> | Role: <%= userObj != null ? ((User)userObj).getRole() : "-" %></p>
        </footer>
    </div>
    
    <script>
        // Auto-refresh keranjang setiap 30 detik
        setInterval(function() {
            fetch('cart-count')
                .then(response => response.text())
                .then(count => {
                    const cartElement = document.querySelector('.cart-count');
                    if (cartElement) {
                        cartElement.textContent = count;
                    }
                });
        }, 30000);
        
        // Form validation
        document.querySelectorAll('form').forEach(form => {
            form.addEventListener('submit', function(e) {
                const quantityInput = this.querySelector('input[name="quantity"]');
                if (quantityInput && quantityInput.value <= 0) {
                    e.preventDefault();
                    alert('Jumlah harus lebih dari 0');
                    quantityInput.focus();
                }
            });
        });
        
        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // F1 - Bantuan
            if (e.key === 'F1') {
                e.preventDefault();
                alert('Keyboard Shortcuts:\nF1 - Bantuan\nF5 - Refresh\nEsc - Clear cart\nCtrl+F - Search products');
            }
            // F5 - Refresh
            if (e.key === 'F5') {
                e.preventDefault();
                location.reload();
            }
            // Esc - Clear cart
            if (e.key === 'Escape') {
                if (confirm('Hapus semua item dari keranjang?')) {
                    window.location.href = 'ClearCartServlet';
                }
            }
            // Ctrl+D - Dashboard
            if (e.ctrlKey && e.key === 'd') {
                e.preventDefault();
                window.location.href = 'dashboard.jsp';
            }
        });
        
        // Notification untuk stok rendah
        <% if (products != null) { %>
            <% for (Product p : products) { %>
                <% if (p.getStock() > 0 && p.getStock() <= 5) { %>
                    console.log('⚠️ Stok rendah: <%= p.getName() %> (sisa <%= p.getStock() %>)');
                <% } %>
            <% } %>
        <% } %>
        
        // Auto focus on first product quantity input
        document.addEventListener('DOMContentLoaded', function() {
            const firstQtyInput = document.querySelector('input[name="quantity"]');
            if (firstQtyInput) {
                firstQtyInput.focus();
            }
        });
    </script>
</body>
</html>