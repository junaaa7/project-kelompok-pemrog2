<%-- 
    Document   : index.jsp
    Created on : 28 Nov 2025, 23.34.08
    Author     : ARJUNA.R.PUTRA
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.pos.service.CartService" %>
<%@ page import="com.pos.model.Product" %>
<%@ page import="java.util.List" %>
<%
    CartService cartService = (CartService) session.getAttribute("cartService");
    if (cartService == null) {
        cartService = new CartService();
        session.setAttribute("cartService", cartService);
    }
    
    List<Product> products = cartService.getAllProducts();
%>
<!DOCTYPE html>
<html>
<head>
    <title>POS System - Home</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <div class="container">
        <h1>Sistem Kasir POS</h1>
        
        <div class="menu">
            <a href="product-form.jsp" class="btn">Input Barang Baru</a>
            <a href="cart.jsp" class="btn">Keranjang Belanja</a>
        </div>
        
        <h2>Daftar Produk</h2>
        <table border="1" class="product-table">
            <tr>
                <th>Kode</th>
                <th>Nama</th>
                <th>Harga</th>
                <th>Stok</th>
                <th>Aksi</th>
            </tr>
            <% for (Product product : products) { %>
            <tr>
                <td><%= product.getCode() %></td>
                <td><%= product.getName() %></td>
                <td>Rp <%= String.format("%,.2f", product.getPrice()) %></td>
                <td><%= product.getStock() %></td>
                <td>
                    <form action="AddToCartServlet" method="post" style="display:inline;">
                        <input type="hidden" name="productCode" value="<%= product.getCode() %>">
                        <input type="number" name="quantity" value="1" min="1" max="<%= product.getStock() %>" style="width: 60px;">
                        <button type="submit">Tambah</button>
                    </form>
                </td>
            </tr>
            <% } %>
        </table>
    </div>
</body>
</html>
