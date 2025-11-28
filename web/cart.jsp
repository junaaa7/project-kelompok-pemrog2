<%-- 
    Document   : cart.jsp
    Created on : 28 Nov 2025, 23.35.04
    Author     : ARJUNA.R.PUTRA
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.pos.service.CartService" %>
<%@ page import="com.pos.model.CartItem" %>
<%@ page import="java.util.List" %>
<%
    CartService cartService = (CartService) session.getAttribute("cartService");
    if (cartService == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    List<CartItem> cartItems = cartService.getCartItems();
    double total = cartService.getTotal();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Keranjang Belanja</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <div class="container">
        <h1>Keranjang Belanja</h1>
        
        <a href="index.jsp" class="btn">Kembali ke Beranda</a>
        
        <% if (cartItems.isEmpty()) { %>
            <p>Keranjang belanja kosong.</p>
        <% } else { %>
            <table border="1" class="cart-table">
                <tr>
                    <th>Kode</th>
                    <th>Nama</th>
                    <th>Harga</th>
                    <th>Qty</th>
                    <th>Subtotal</th>
                    <th>Aksi</th>
                </tr>
                <% for (CartItem item : cartItems) { %>
                <tr>
                    <td><%= item.getProduct().getCode() %></td>
                    <td><%= item.getProduct().getName() %></td>
                    <td>Rp <%= String.format("%,.2f", item.getProduct().getPrice()) %></td>
                    <td>
                        <form action="UpdateCartServlet" method="post" style="display:inline;">
                            <input type="hidden" name="productCode" value="<%= item.getProduct().getCode() %>">
                            <input type="number" name="quantity" value="<%= item.getQuantity() %>" 
                                   min="1" max="<%= item.getProduct().getStock() + item.getQuantity() %>"
                                   style="width: 60px;">
                            <button type="submit">Update</button>
                        </form>
                    </td>
                    <td>Rp <%= String.format("%,.2f", item.getSubtotal()) %></td>
                    <td>
                        <form action="RemoveFromCartServlet" method="post" style="display:inline;">
                            <input type="hidden" name="productCode" value="<%= item.getProduct().getCode() %>">
                            <button type="submit">Hapus</button>
                        </form>
                    </td>
                </tr>
                <% } %>
                <tr>
                    <td colspan="4" align="right"><strong>Total:</strong></td>
                    <td colspan="2"><strong>Rp <%= String.format("%,.2f", total) %></strong></td>
                </tr>
            </table>
            
            <div class="payment-section">
                <h3>Pembayaran</h3>
                <form action="ProcessPaymentServlet" method="post">
                    <table>
                        <tr>
                            <td>Total Belanja:</td>
                            <td><strong>Rp <%= String.format("%,.2f", total) %></strong></td>
                        </tr>
                        <tr>
                            <td>Cash:</td>
                            <td><input type="number" name="cash" step="0.01" required></td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <button type="submit">Proses Pembayaran</button>
                            </td>
                        </tr>
                    </table>
                </form>
            </div>
        <% } %>
    </div>
</body>
</html>