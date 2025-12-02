<%-- 
    Document   : receipt.jsp
    Created on : 28 Nov 2025, 23.35.34
    Author     : ARJUNA.R.PUTRA
--%>


<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    Double total = (Double) request.getAttribute("total");
    Double cash = (Double) request.getAttribute("cash");
    Double change = (Double) request.getAttribute("change");
    
    if (total == null || cash == null || change == null) {
        response.sendRedirect("cart.jsp");
        return;
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    String dateTime = sdf.format(new Date());
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
        
        @media print {
            body {
                background: white;
            }
            
            .btn-group {
                display: none;
            }
            
            .receipt-container {
                box-shadow: none;
            }
        }
    </style>
</head>
<body>
    <div class="receipt-container">
        <div class="receipt-header">
            <h1>TOKO MAKMUR JAYA</h1>
            <p>Jl. Raya No. 123, Jakarta</p>
            <p>Telp: 021-1234567</p>
        </div>
        
        <div class="receipt-details">
            <p><strong>No. Transaksi:</strong> TRX-<%= System.currentTimeMillis() %></p>
            <p><strong>Tanggal:</strong> <%= dateTime %></p>
            <p><strong>Kasir:</strong> <% 
                Object user = session.getAttribute("user");
                if (user != null) {
                    out.print(user.toString());
                } else {
                    out.print("Kasir");
                }
            %></p>
        </div>
        
        <table class="receipt-table">
            <tr>
                <td><strong>ITEM</strong></td>
                <td style="text-align: right;"><strong>HARGA</strong></td>
            </tr>
            <tr>
                <td>Pembayaran</td>
                <td style="text-align: right;">Rp <%= String.format("%,.2f", total) %></td>
            </tr>
        </table>
        
        <div class="receipt-total">
            <table style="width: 100%;">
                <tr>
                    <td>Total:</td>
                    <td style="text-align: right;">Rp <%= String.format("%,.2f", total) %></td>
                </tr>
                <tr>
                    <td>Cash:</td>
                    <td style="text-align: right;">Rp <%= String.format("%,.2f", cash) %></td>
                </tr>
                <tr>
                    <td>Kembali:</td>
                    <td style="text-align: right; color: #28a745; font-size: 1.2em;">
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
        </div>
    </div>
    
    <script>
        // Auto print after 1 second
        setTimeout(() => {
            if (window.confirm('Cetak struk sekarang?')) {
                window.print();
            }
        }, 1000);
        
        // Clear cart after printing
        window.onafterprint = function() {
            fetch('ClearCartServlet');
        };
    </script>
</body>
</html>