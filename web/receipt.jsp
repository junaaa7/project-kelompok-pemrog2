<%-- 
    Document   : receipt.jsp
    Created on : 28 Nov 2025, 23.35.34
    Author     : ARJUNA.R.PUTRA
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.pos.model.CartItem" %>
<%@ page import="java.util.List" %>
<%
    // Get data from request attributes
    Double total = (Double) request.getAttribute("total");
    Double cash = (Double) request.getAttribute("cash");
    Double change = (Double) request.getAttribute("change");
    String transactionCode = (String) request.getAttribute("transactionCode");
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    
    // If data is null, try to get from session
    if (total == null || cash == null || change == null) {
        response.sendRedirect("cart.jsp");
        return;
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    String dateTime = sdf.format(new Date());
    
    // Get user from session
    Object userObj = session.getAttribute("user");
    String cashierName = "Kasir";
    if (userObj != null) {
        try {
            com.pos.model.User user = (com.pos.model.User) userObj;
            cashierName = user.getFullName();
        } catch (Exception e) {
            // If cast fails, use toString
            cashierName = userObj.toString();
        }
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Struk Pembayaran - POS System</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Courier New', monospace;
        }
        
        body {
            background: #f0f0f0;
            padding: 20px;
        }
        
        .receipt-container {
            max-width: 400px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        
        .receipt-header {
            text-align: center;
            border-bottom: 2px dashed #333;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
        
        .receipt-header h1 {
            font-size: 24px;
            margin-bottom: 5px;
        }
        
        .receipt-details {
            margin-bottom: 20px;
        }
        
        .receipt-details p {
            margin: 5px 0;
        }
        
        .receipt-table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
            font-size: 14px;
        }
        
        .receipt-table td {
            padding: 5px 0;
            border-bottom: 1px dashed #ccc;
        }
        
        .receipt-table tr:last-child td {
            border-bottom: none;
        }
        
        .receipt-total {
            border-top: 2px solid #333;
            margin-top: 15px;
            padding-top: 10px;
            font-weight: bold;
        }
        
        .receipt-footer {
            text-align: center;
            margin-top: 20px;
            padding-top: 10px;
            border-top: 1px dashed #333;
            font-size: 12px;
            color: #666;
        }
        
        .btn-group {
            display: flex;
            gap: 10px;
            margin-top: 20px;
            justify-content: center;
        }
        
        .btn {
            padding: 10px 20px;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            border: none;
            cursor: pointer;
            font-size: 14px;
        }
        
        .btn:hover {
            background: #0056b3;
        }
        
        .btn-print {
            background: #28a745;
        }
        
        .btn-print:hover {
            background: #218838;
        }
        
        .btn-transaction {
            background: #6c757d;
        }
        
        .btn-transaction:hover {
            background: #545b62;
        }
        
        @media print {
            body {
                background: white;
                padding: 0;
            }
            
            .btn-group {
                display: none;
            }
            
            .receipt-container {
                box-shadow: none;
                max-width: 100%;
                padding: 10px;
            }
            
            .receipt-header h1 {
                font-size: 20px;
            }
            
            .receipt-table {
                font-size: 12px;
            }
        }
        
        .item-name {
            width: 60%;
        }
        
        .item-qty, .item-price, .item-subtotal {
            text-align: right;
            width: 13.33%;
        }
        
        .text-right {
            text-align: right;
        }
        
        .text-center {
            text-align: center;
        }
        
        .success-message {
            background-color: #d4edda;
            color: #155724;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="receipt-container">
        <!-- Success Message -->
        <div class="success-message">
            ✅ Transaksi Berhasil!
        </div>
        
        <div class="receipt-header">
            <h1>TOKO MAKMUR JAYA</h1>
            <p>Jl. Raya No. 123, Jakarta</p>
            <p>Telp: 021-1234567</p>
        </div>
        
        <div class="receipt-details">
            <p><strong>No. Transaksi:</strong> <%= transactionCode %></p>
            <p><strong>Tanggal:</strong> <%= dateTime %></p>
            <p><strong>Kasir:</strong> <%= cashierName %></p>
        </div>
        
        <table class="receipt-table">
            <thead>
                <tr>
                    <td class="item-name"><strong>ITEM</strong></td>
                    <td class="item-qty"><strong>QTY</strong></td>
                    <td class="item-price"><strong>HARGA</strong></td>
                    <td class="item-subtotal"><strong>SUB</strong></td>
                </tr>
            </thead>
            <tbody>
                <% 
                if (cartItems != null && !cartItems.isEmpty()) {
                    for (CartItem item : cartItems) { 
                %>
                <tr>
                    <td class="item-name"><%= item.getProduct().getName() %></td>
                    <td class="item-qty"><%= item.getQuantity() %></td>
                    <td class="item-price">Rp <%= String.format("%,.0f", item.getProduct().getPrice()) %></td>
                    <td class="item-subtotal">Rp <%= String.format("%,.0f", item.getSubtotal()) %></td>
                </tr>
                <% 
                    }
                } else {
                %>
                <tr>
                    <td colspan="4" class="text-center">Tidak ada item</td>
                </tr>
                <% } %>
            </tbody>
        </table>
        
        <div class="receipt-total">
            <table style="width: 100%;">
                <tr>
                    <td>Total:</td>
                    <td class="text-right">Rp <%= String.format("%,.2f", total) %></td>
                </tr>
                <tr>
                    <td>Cash:</td>
                    <td class="text-right">Rp <%= String.format("%,.2f", cash) %></td>
                </tr>
                <tr>
                    <td>Kembali:</td>
                    <td class="text-right" style="color: #28a745; font-size: 1.2em;">
                        Rp <%= String.format("%,.2f", change) %>
                    </td>
                </tr>
            </table>
        </div>
        
        <div class="receipt-footer">
            <p>Terima kasih telah berbelanja</p>
            <p>*** Barang yang sudah dibeli tidak dapat ditukar ***</p>
            <p>www.tokomakmurjaya.com</p>
        </div>
        
        <div class="btn-group">
            <button onclick="window.print()" class="btn btn-print">🖨️ Cetak Struk</button>
            <a href="index.jsp" class="btn">🔄 Transaksi Baru</a>
            <a href="cashier-transactions.jsp" class="btn btn-transaction">📋 Riwayat Transaksi</a>
        </div>
    </div>
    
    <script>
        // Auto print after 1 second
        setTimeout(() => {
            if (confirm('Cetak struk sekarang?')) {
                window.print();
            }
        }, 1000);
        
        // Clear cart after printing
        window.onafterprint = function() {
            // Cart already cleared by ProcessPaymentServlet
            console.log('Struk telah dicetak');
        };
        
        // Auto redirect to transactions after 10 seconds (optional)
        setTimeout(() => {
            if (!document.hidden) {
                console.log('Redirecting to transactions page...');
                // window.location.href = 'cashier-transactions.jsp';
            }
        }, 10000);
    </script>
</body>
</html>