<%-- 
    Document   : receipt.jsp
    Created on : 28 Nov 2025, 23.35.34
    Author     : ARJUNA.R.PUTRA
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.pos.service.CartService" %>
<%@ page import="com.pos.model.CartItem" %>
<%@ page import="java.util.List" %>
<%
    CartService cartService = (CartService) session.getAttribute("cartService");
    Double cash = (Double) session.getAttribute("cash");
    Double change = (Double) session.getAttribute("change");
    
    if (cartService == null || cash == null || change == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    List<CartItem> cartItems = cartService.getCartItems();
    double total = cartService.getTotal();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Struk Pembayaran</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <style>
        .receipt {
            width: 300px;
            margin: 0 auto;
            padding: 20px;
            border: 1px solid #000;
            font-family: 'Courier New', monospace;
        }
        .receipt-header, .receipt-footer {
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="receipt">
            <div class="receipt-header">
                <h2>TOKO KITA</h2>
                <p>Jl. Contoh No. 123</p>
                <p>Telp: 021-123456</p>
            </div>
            
            <hr>
            <p>Tanggal: <%= new java.util.Date() %></p>
            <hr>
            
            <table width="100%">
                <% for (CartItem item : cartItems) { %>
                <tr>
                    <td><%= item.getProduct().getName() %></td>
                    <td align="right"><%= item.getQuantity() %> x</td>
                    <td align="right">Rp <%= String.format("%,.2f", item.getProduct().getPrice()) %></td>
                </tr>
                <tr>
                    <td></td>
                    <td colspan="2" align="right">Rp <%= String.format("%,.2f", item.getSubtotal()) %></td>
                </tr>
                <% } %>
            </table>
            
            <hr>
            <table width="100%">
                <tr>
                    <td>Total:</td>
                    <td align="right">Rp <%= String.format("%,.2f", total) %></td>
                </tr>
                <tr>
                    <td>Cash:</td>
                    <td align="right">Rp <%= String.format("%,.2f", cash) %></td>
                </tr>
                <tr>
                    <td>Kembali:</td>
                    <td align="right">Rp <%= String.format("%,.2f", change) %></td>
                </tr>
            </table>
            <hr>
            
            <div class="receipt-footer">
                <p>Terima kasih atas kunjungan Anda</p>
                <p>***</p>
            </div>
        </div>
        
        <div style="text-align: center; margin-top: 20px;">
            <button onclick="window.print()">Cetak Struk</button>
            <a href="index.jsp" class="btn">Transaksi Baru</a>
        </div>
    </div>
</body>
</html>