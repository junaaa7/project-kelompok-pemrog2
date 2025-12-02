<%-- 
    Document   : cart.jsp
    Created on : 28 Nov 2025, 23.35.04
    Author     : ARJUNA.R.PUTRA
--%>

<%-- 
    cart.jsp - Halaman keranjang belanja
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.pos.service.CartService" %>
<%@ page import="com.pos.model.CartItem" %>
<%@ page import="java.util.List" %>
<%
    CartService cartService = (CartService) session.getAttribute("cartService");
    if (cartService == null) {
        cartService = new CartService();
        session.setAttribute("cartService", cartService);
    }
    
    List<CartItem> cartItems = cartService.getCartItems();
    double total = cartService.calculateTotal();
    
    // Get error/success messages
    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keranjang Belanja - POS System</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <style>
        .container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .cart-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        
        .cart-summary {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            border-left: 5px solid #28a745;
        }
        
        .cart-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
            background: white;
            border-radius: 10px;
            overflow: hidden;
        }
        
        .cart-table th {
            background: #343a40;
            color: white;
            padding: 15px;
            text-align: left;
        }
        
        .cart-table td {
            padding: 12px;
            border-bottom: 1px solid #dee2e6;
        }
        
        .cart-table tr:hover {
            background: #f8f9fa;
        }
        
        .quantity-input {
            width: 70px;
            padding: 5px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            text-align: center;
        }
        
        .payment-form {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-top: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .payment-form input[type="number"] {
            width: 200px;
            padding: 10px;
            border: 2px solid #007bff;
            border-radius: 5px;
            font-size: 18px;
            font-weight: bold;
        }
        
        .empty-cart {
            text-align: center;
            padding: 50px;
            color: #6c757d;
        }
        
        .empty-cart i {
            font-size: 50px;
            color: #adb5bd;
            margin-bottom: 20px;
        }
        
        .btn-group {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="cart-header">
            <h1>🛒 Keranjang Belanja</h1>
            <a href="index.jsp" class="btn">← Kembali ke Produk</a>
        </div>
        
        <%-- Error messages --%>
        <% if (error != null) { %>
            <div class="alert alert-danger">
                <strong>Error:</strong> <%= error %>
            </div>
        <% } %>
        
        <%-- Success messages --%>
        <% if (success != null) { %>
            <div class="alert alert-success">
                <strong>Sukses:</strong> <%= success %>
            </div>
        <% } %>
        
        <% if (cartItems == null || cartItems.isEmpty()) { %>
            <div class="empty-cart">
                <div>🛒</div>
                <h2>Keranjang Belanja Kosong</h2>
                <p>Belum ada produk di keranjang belanja Anda.</p>
                <a href="index.jsp" class="btn">Lihat Produk</a>
            </div>
        <% } else { %>
            <div class="cart-summary">
                <h3>Ringkasan Belanja</h3>
                <p>Total Item: <strong><%= cartItems.size() %></strong></p>
                <p>Total Harga: <strong style="color: #28a745; font-size: 1.2em;">Rp <%= String.format("%,.2f", total) %></strong></p>
            </div>
            
            <table class="cart-table">
                <thead>
                    <tr>
                        <th>No</th>
                        <th>Produk</th>
                        <th>Harga Satuan</th>
                        <th>Jumlah</th>
                        <th>Subtotal</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <% int i = 1; %>
                    <% for (CartItem item : cartItems) { %>
                    <tr>
                        <td><%= i++ %></td>
                        <td>
                            <strong><%= item.getProduct().getName() %></strong><br>
                            <small>Kode: <%= item.getProduct().getCode() %></small>
                        </td>
                        <td>Rp <%= String.format("%,.2f", item.getProduct().getPrice()) %></td>
                        <td>
                            <form action="UpdateCartServlet" method="post" style="display: flex; gap: 5px; align-items: center;">
                                <input type="hidden" name="productCode" value="<%= item.getProduct().getCode() %>">
                                <input type="number" name="quantity" value="<%= item.getQuantity() %>" 
                                       min="1" max="<%= item.getProduct().getStock() %>" class="quantity-input">
                                <button type="submit" class="btn btn-secondary" style="padding: 5px 10px;">Update</button>
                            </form>
                        </td>
                        <td style="font-weight: bold; color: #007bff;">
                            Rp <%= String.format("%,.2f", item.getSubtotal()) %>
                        </td>
                        <td>
                            <form action="RemoveFromCartServlet" method="post" style="display: inline;">
                                <input type="hidden" name="productCode" value="<%= item.getProduct().getCode() %>">
                                <button type="submit" class="btn btn-danger" style="padding: 5px 10px;">Hapus</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
                <tfoot>
                    <tr style="background: #f8f9fa; font-weight: bold;">
                        <td colspan="4" style="text-align: right;">Total:</td>
                        <td colspan="2" style="color: #28a745; font-size: 1.2em;">
                            Rp <%= String.format("%,.2f", total) %>
                        </td>
                    </tr>
                </tfoot>
            </table>
            
            <div class="btn-group">
                <a href="ClearCartServlet" class="btn btn-danger" 
                   onclick="return confirm('Yakin ingin mengosongkan keranjang?')">
                    🗑️ Kosongkan Keranjang
                </a>
                <a href="index.jsp" class="btn btn-secondary">➕ Tambah Produk Lain</a>
            </div>
            
            <div class="payment-form">
                <h3>💳 Proses Pembayaran</h3>
                <form action="ProcessPaymentServlet" method="post">
                    <div style="margin-bottom: 15px;">
                        <label>Total yang harus dibayar:</label>
                        <div style="font-size: 24px; font-weight: bold; color: #28a745;">
                            Rp <%= String.format("%,.2f", total) %>
                        </div>
                    </div>
                    
                    <div style="margin-bottom: 15px;">
                        <label for="cash">Uang Diterima (Rp):</label><br>
                        <input type="number" id="cash" name="cash" 
                               min="<%= total %>" step="500" required
                               placeholder="Masukkan jumlah uang">
                    </div>
                    
                    <button type="submit" class="btn btn-success" style="padding: 15px 30px; font-size: 18px;">
                        💰 Proses Pembayaran
                    </button>
                </form>
            </div>
        <% } %>
    </div>
    
    <script>
        // Auto-calculate change
        document.getElementById('cash')?.addEventListener('input', function() {
            const cash = parseFloat(this.value) || 0;
            const total = <%= total %>;
            const change = cash - total;
            
            const changeElement = document.getElementById('change-display');
            if (changeElement) {
                if (change >= 0) {
                    changeElement.innerHTML = 'Kembalian: Rp ' + change.toLocaleString('id-ID', {
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 2
                    });
                    changeElement.style.color = '#28a745';
                } else {
                    changeElement.innerHTML = 'Kurang: Rp ' + Math.abs(change).toLocaleString('id-ID', {
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 2
                    });
                    changeElement.style.color = '#dc3545';
                }
            }
        });
        
        // Confirm before clearing cart
        document.querySelector('a[href="ClearCartServlet"]')?.addEventListener('click', function(e) {
            if (!confirm('Yakin ingin mengosongkan keranjang belanja?')) {
                e.preventDefault();
            }
        });
    </script>
</body>
</html>