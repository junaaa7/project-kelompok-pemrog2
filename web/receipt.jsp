<%-- 
    Document   : receipt
    Created on : 3 Dec 2025, 10.00.00
    Author     : ARJUNA.R.PUTRA
--%>

<%@page import="java.util.Date"%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.pos.model.CartItem" %>
<%@ page import="com.pos.model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Get data from request attributes
    Double total = (Double) request.getAttribute("total");
    Double cash = (Double) request.getAttribute("cash");
    Double change = (Double) request.getAttribute("change");
    String transactionCode = (String) request.getAttribute("transactionCode");
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    Date transactionDate = (Date) request.getAttribute("transactionDate");
    com.pos.model.User user = (com.pos.model.User) request.getAttribute("user");
    
    // Get SYSTEM SETTINGS from request
    String storeName = (String) request.getAttribute("storeName");
    String storeAddress = (String) request.getAttribute("storeAddress");
    String storePhone = (String) request.getAttribute("storePhone");
    String storeEmail = (String) request.getAttribute("storeEmail");
    String receiptHeader = (String) request.getAttribute("receiptHeader");
    String receiptFooter = (String) request.getAttribute("receiptFooter");
    String currency = (String) request.getAttribute("currency");
    String receiptFontSize = (String) request.getAttribute("receiptFontSize");
    Integer receiptCopies = (Integer) request.getAttribute("receiptCopies");
    
    // Default values if null - UKURAN OPTIMAL
    if (storeName == null || storeName.trim().isEmpty()) storeName = "TOKO MAKMUR JAYA";
    if (storeAddress == null || storeAddress.trim().isEmpty()) storeAddress = "Jl. Raya No. 123, Jakarta";
    if (storePhone == null || storePhone.trim().isEmpty()) storePhone = "Telp: 021-1234567";
    if (storeEmail == null) storeEmail = "info@tokomakmurjaya.com";
    if (receiptHeader == null || receiptHeader.trim().isEmpty()) {
        receiptHeader = storeName + "\n" + storeAddress + "\n" + storePhone;
    }
    if (receiptFooter == null || receiptFooter.trim().isEmpty()) {
        receiptFooter = "Terima kasih telah berbelanja\n*** Barang yang sudah dibeli tidak dapat ditukar ***";
    }
    if (currency == null) currency = "IDR";
    if (receiptFontSize == null) receiptFontSize = "14px";
    if (receiptCopies == null) receiptCopies = 1;
    
    // Get cashier name properly
    String cashierName = "Kasir";
    if (user != null && user.getFullName() != null) {
        cashierName = user.getFullName();
    } else if (request.getAttribute("cashierName") != null) {
        cashierName = (String) request.getAttribute("cashierName");
    }
    
    // Formatting
    DecimalFormat df = new DecimalFormat("#,###");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
    SimpleDateFormat dateOnlyFormat = new SimpleDateFormat("dd/MM/yyyy");
    
    // Determine optimal font size for receipt
    int fontSize = 12;
    try {
        if (receiptFontSize != null && !receiptFontSize.isEmpty()) {
            if (receiptFontSize.contains("px")) {
                fontSize = Integer.parseInt(receiptFontSize.replace("px", "").trim());
            } else if (receiptFontSize.equalsIgnoreCase("small")) {
                fontSize = 11;
            } else if (receiptFontSize.equalsIgnoreCase("normal")) {
                fontSize = 12;
            } else if (receiptFontSize.equalsIgnoreCase("large")) {
                fontSize = 14;
            }
        }
    } catch (Exception e) {
        fontSize = 12;
    }
    
    // Ensure reasonable size
    if (fontSize < 10) fontSize = 12;
    if (fontSize > 16) fontSize = 14;
    
    // Receipt settings
    String receiptWidth = "300px";
    String receiptPadding = "15px";
    int headerSize = fontSize + 2;
    int totalSize = fontSize + 4;
%>
<!DOCTYPE html>
<html>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Struk - <%= storeName %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        /* ==================== PRINT STYLES - UKURAN OPTIMAL ==================== */
        @media print {
            @page {
                size: 80mm auto; /* Ukuran struk thermal */
                margin: 2mm;
            }
            
            body {
                margin: 0 !important;
                padding: 0 !important;
                font-family: 'Courier New', monospace !important;
                font-size: <%= fontSize %>pt !important;
                line-height: 1.2 !important;
                width: 100% !important;
            }
            
            .receipt-container {
                width: 100% !important;
                max-width: 76mm !important;
                margin: 0 auto !important;
                padding: 5px !important;
                box-sizing: border-box !important;
                border: none !important;
                background: white !important;
            }
            
            .no-print {
                display: none !important;
            }
            
            .print-only {
                display: block !important;
            }
            
            .btn, button {
                display: none !important;
            }
            
            table {
                width: 100% !important;
                font-size: <%= fontSize %>pt !important;
            }
            
            .total-section {
                font-size: <%= totalSize %>pt !important;
                font-weight: bold !important;
            }
        }
        
        /* ==================== SCREEN STYLES ==================== */
        .dashboard-card {
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .receipt-preview {
            max-width: 320px;
            margin: 20px auto;
            border: 1px solid #ddd;
            padding: 10px;
            background: white;
        }
        
        .receipt-container {
            width: <%= receiptWidth %>;
            margin: 0 auto;
            font-family: 'Courier New', monospace;
            font-size: <%= fontSize %>px;
            line-height: 1.3;
            padding: <%= receiptPadding %>;
            background: white;
            border: 1px solid #000;
        }
        
        .store-header {
            text-align: center;
            margin-bottom: 10px;
            padding-bottom: 5px;
            border-bottom: 1px solid #000;
        }
        
        .store-name {
            font-size: <%= headerSize %>px;
            font-weight: bold;
            margin-bottom: 3px;
        }
        
        .store-info {
            font-size: <%= fontSize %>px;
            margin: 2px 0;
        }
        
        .transaction-header {
            text-align: center;
            font-weight: bold;
            font-size: <%= fontSize + 1 %>px;
            margin: 8px 0;
            padding: 5px;
            border-top: 1px dashed #000;
            border-bottom: 1px dashed #000;
        }
        
        .transaction-info {
            margin: 10px 0;
            font-size: <%= fontSize %>px;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            margin: 4px 0;
        }
        
        /* TABLE STYLES */
        .items-table {
            width: 100%;
            border-collapse: collapse;
            margin: 10px 0;
            font-size: <%= fontSize %>px;
        }
        
        .items-table th {
            padding: 6px 3px;
            border-bottom: 2px solid #000;
            text-align: left;
            font-weight: bold;
        }
        
        .items-table td {
            padding: 4px 3px;
            border-bottom: 1px dashed #ccc;
        }
        
        .item-name {
            width: 50%;
        }
        
        .item-qty {
            width: 15%;
            text-align: center;
        }
        
        .item-price {
            width: 20%;
            text-align: right;
        }
        
        .item-subtotal {
            width: 15%;
            text-align: right;
            font-weight: bold;
        }
        
        /* TOTALS SECTION */
        .totals-section {
            margin: 15px 0;
            padding: 10px;
            border-top: 2px solid #000;
            border-bottom: 2px solid #000;
            font-size: <%= fontSize + 1 %>px;
        }
        
        .total-row {
            display: flex;
            justify-content: space-between;
            margin: 8px 0;
        }
        
        .grand-total {
            font-size: <%= totalSize %>px;
            font-weight: bold;
            color: #000;
        }
        
        /* FOOTER */
        .receipt-footer {
            text-align: center;
            margin-top: 15px;
            padding-top: 10px;
            border-top: 1px dashed #000;
            font-size: <%= fontSize - 1 %>px;
        }
        
        /* SEPARATOR */
        .separator {
            border-top: 1px dashed #000;
            margin: 8px 0;
        }
        
        .dashed-line {
            border-top: 1px dashed #000;
            margin: 5px 0;
        }
    </style>

<body>
    <!-- ==================== DASHBOARD (NON-PRINT) ==================== -->
    <div class="container-fluid mt-3 no-print">
        <div class="row">
            <div class="col-md-8 offset-md-2">
                <div class="card dashboard-card">
                    <div class="card-header bg-primary text-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">
                                <i class="fas fa-receipt"></i> Struk Transaksi
                            </h5>
                            <div>
                                <button class="btn btn-light btn-sm me-2" onclick="printReceipt()">
                                    <i class="fas fa-print"></i> Cetak Struk
                                </button>
                                <a href="cart.jsp" class="btn btn-success btn-sm">
                                    <i class="fas fa-shopping-cart"></i> Transaksi Baru
                                </a>
                            </div>
                        </div>
                    </div>
                    
                    <div class="card-body">
                        <!-- TRANSACTION SUMMARY -->
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header bg-light">
                                        <h6 class="mb-0">Informasi Transaksi</h6>
                                    </div>
                                    <div class="card-body">
                                        <table class="table table-sm">
                                            <tr>
                                                <td><strong>No. Transaksi:</strong></td>
                                                <td><%= transactionCode %></td>
                                            </tr>
                                            <tr>
                                                <td><strong>Tanggal:</strong></td>
                                                <td><%= dateFormat.format(transactionDate) %></td>
                                            </tr>
                                            <tr>
                                                <td><strong>Kasir:</strong></td>
                                                <td><%= cashierName %></td>
                                            </tr>
                                            <tr class="table-success">
                                                <td><strong>Total:</strong></td>
                                                <td class="fw-bold">Rp <%= df.format(total) %></td>
                                            </tr>
                                            <tr>
                                                <td><strong>Cash:</strong></td>
                                                <td>Rp <%= df.format(cash) %></td>
                                            </tr>
                                            <tr class="table-warning">
                                                <td><strong>Kembali:</strong></td>
                                                <td class="fw-bold">Rp <%= df.format(change) %></td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header bg-light">
                                        <h6 class="mb-0">Informasi Toko</h6>
                                    </div>
                                    <div class="card-body">
                                        <p class="mb-1"><strong><%= storeName %></strong></p>
                                        <p class="mb-1"><small><%= storeAddress %></small></p>
                                        <p class="mb-1"><small><%= storePhone %></small></p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- ITEMS TABLE -->
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <div class="card">
                                    <div class="card-header bg-light">
                                        <h6 class="mb-0">Detail Barang (<%= cartItems != null ? cartItems.size() : 0 %> item)</h6>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table table-sm">
                                                <thead>
                                                    <tr>
                                                        <th>#</th>
                                                        <th>Nama Produk</th>
                                                        <th class="text-center">Qty</th>
                                                        <th class="text-end">Harga</th>
                                                        <th class="text-end">Subtotal</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <% 
                                                    if (cartItems != null && !cartItems.isEmpty()) {
                                                        int counter = 1;
                                                        for (CartItem item : cartItems) {
                                                            Product product = item.getProduct();
                                                    %>
                                                    <tr>
                                                        <td><%= counter++ %></td>
                                                        <td><%= product.getName() %></td>
                                                        <td class="text-center"><%= item.getQuantity() %></td>
                                                        <td class="text-end">Rp <%= df.format(product.getPrice()) %></td>
                                                        <td class="text-end fw-bold">Rp <%= df.format(item.getSubtotal()) %></td>
                                                    </tr>
                                                    <% 
                                                        }
                                                    }
                                                    %>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- PREVIEW STRUK -->
                        <div class="row">
                            <div class="col-md-12">
                                <div class="card">
                                    <div class="card-header bg-light">
                                        <h6 class="mb-0">
                                            <i class="fas fa-eye"></i> Preview Struk 
                                        </h6>
                                    </div>
                                    <div class="card-body">
                                        <div class="receipt-preview">
                                            <div class="receipt-container">
                                                <!-- HEADER -->
                                                <div class="store-header">
                                                    <div class="store-name"><%= storeName %></div>
                                                    <div class="store-info"><%= storeAddress %></div>
                                                    <div class="store-info"><%= storePhone %></div>
                                                </div>
                                                
                                                <div class="dashed-line"></div>
                                                
                                                <!-- TRANSACTION INFO -->
                                                <div class="transaction-header">STRUK PEMBAYARAN</div>
                                                
                                                <div class="transaction-info">
                                                    <div class="info-row">
                                                        <span>No. Transaksi:</span>
                                                        <span><strong><%= transactionCode %></strong></span>
                                                    </div>
                                                    <div class="info-row">
                                                        <span>Tanggal:</span>
                                                        <span><%= dateOnlyFormat.format(transactionDate) %> <%= timeFormat.format(transactionDate) %></span>
                                                    </div>
                                                    <div class="info-row">
                                                        <span>Kasir:</span>
                                                        <span><strong><%= cashierName %></strong></span>
                                                    </div>
                                                </div>
                                                
                                                <div class="dashed-line"></div>
                                                
                                                <!-- ITEMS TABLE -->
                                                <table class="items-table">
                                                    <thead>
                                                        <tr>
                                                            <th class="item-name">ITEM</th>
                                                            <th class="item-qty">QTY</th>
                                                            <th class="item-price">HARGA</th>
                                                            <th class="item-subtotal">TOTAL</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <% 
                                                        if (cartItems != null) {
                                                            for (CartItem item : cartItems) {
                                                                Product product = item.getProduct();
                                                        %>
                                                        <tr>
                                                            <td class="item-name"><%= product.getName() %></td>
                                                            <td class="item-qty"><%= item.getQuantity() %></td>
                                                            <td class="item-price">Rp <%= df.format(product.getPrice()) %></td>
                                                            <td class="item-subtotal">Rp <%= df.format(item.getSubtotal()) %></td>
                                                        </tr>
                                                        <% 
                                                            }
                                                        }
                                                        %>
                                                    </tbody>
                                                </table>
                                                
                                                <div class="separator"></div>
                                                
                                                <!-- TOTALS -->
                                                <div class="totals-section">
                                                    <div class="total-row">
                                                        <span>Total:</span>
                                                        <span>Rp <%= df.format(total) %></span>
                                                    </div>
                                                    <div class="total-row">
                                                        <span>Cash:</span>
                                                        <span>Rp <%= df.format(cash) %></span>
                                                    </div>
                                                    <div class="total-row grand-total">
                                                        <span>Kembali:</span>
                                                        <span>Rp <%= df.format(change) %></span>
                                                    </div>
                                                </div>
                                                
                                                <!-- FOOTER -->
                                                <div class="receipt-footer">
                                                    <div><strong>Terima kasih telah berbelanja</strong></div>
                                                    <div>*** Barang tidak dapat ditukar ***</div>
                                                    <div style="margin-top: 5px; font-size: <%= fontSize - 2 %>px;">
                                                        <%= storeEmail %>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="card-footer text-center">
                        <button class="btn btn-primary me-2" onclick="printReceipt()">
                            <i class="fas fa-print"></i> Cetak Struk
                        </button>
                        <a href="cart.jsp" class="btn btn-success me-2">
                            <i class="fas fa-redo"></i> Transaksi Baru
                        </a>
                        <a href="dashboard.jsp" class="btn btn-secondary">
                            <i class="fas fa-home"></i> Dashboard
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- ==================== AREA UNTUK CETAK ==================== -->
    <div id="print-area" style="display: none;">
        <% for (int copy = 1; copy <= receiptCopies; copy++) { %>
        <div class="receipt-container print-only">
            <!-- HEADER -->
            <div class="store-header">
                <div class="store-name"><%= storeName %></div>
                <div class="store-info"><%= storeAddress %></div>
                <div class="store-info"><%= storePhone %></div>
            </div>
            
            <div class="dashed-line"></div>
            
            <!-- TRANSACTION INFO -->
            <div class="transaction-header">STRUK PEMBAYARAN</div>
            
            <div class="transaction-info">
                <div class="info-row">
                    <span>No. Transaksi:</span>
                    <span><strong><%= transactionCode %></strong></span>
                </div>
                <div class="info-row">
                    <span>Tanggal:</span>
                    <span><%= dateOnlyFormat.format(transactionDate) %> <%= timeFormat.format(transactionDate) %></span>
                </div>
                <div class="info-row">
                    <span>Kasir:</span>
                    <span><strong><%= cashierName %></strong></span>
                </div>
            </div>
            
            <div class="dashed-line"></div>
            
            <!-- ITEMS TABLE -->
            <table class="items-table">
                <thead>
                    <tr>
                        <th class="item-name">ITEM</th>
                        <th class="item-qty">QTY</th>
                        <th class="item-price">HARGA</th>
                        <th class="item-subtotal">TOTAL</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                    if (cartItems != null && !cartItems.isEmpty()) {
                        for (CartItem item : cartItems) {
                            Product product = item.getProduct();
                    %>
                    <tr>
                        <td class="item-name"><%= product.getName() %></td>
                        <td class="item-qty"><%= item.getQuantity() %></td>
                        <td class="item-price">Rp <%= df.format(product.getPrice()) %></td>
                        <td class="item-subtotal">Rp <%= df.format(item.getSubtotal()) %></td>
                    </tr>
                    <% 
                        }
                    }
                    %>
                </tbody>
            </table>
            
            <div class="separator"></div>
            
            <!-- TOTALS -->
            <div class="totals-section">
                <div class="total-row">
                    <span>Total:</span>
                    <span>Rp <%= df.format(total) %></span>
                </div>
                <div class="total-row">
                    <span>Cash:</span>
                    <span>Rp <%= df.format(cash) %></span>
                </div>
                <div class="total-row grand-total">
                    <span>Kembali:</span>
                    <span>Rp <%= df.format(change) %></span>
                </div>
            </div>
            
            <!-- FOOTER -->
            <div class="receipt-footer">
                <div><strong>Terima kasih telah berbelanja</strong></div>
                <div>*** Barang tidak dapat ditukar ***</div>
                <% if (receiptCopies > 1) { %>
                <div style="font-size: <%= fontSize - 2 %>px; margin-top: 5px;">
                    Salinan: <%= copy %>/<%= receiptCopies %>
                </div>
                <% } %>
            </div>
            
            <!-- END MARKER -->
            <div style="text-align: center; margin-top: 10px; font-size: <%= fontSize - 2 %>px;">
                ====
            </div>
        </div>
        
        <!-- PAGE BREAK FOR MULTIPLE COPIES -->
        <% if (copy < receiptCopies) { %>
        <div style="page-break-after: always;"></div>
        <% } %>
        
        <% } %>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function printReceipt() {
            // Show print area
            document.getElementById('print-area').style.display = 'block';
            
            // Wait a bit then print
            setTimeout(function() {
                window.print();
                
                // Hide print area after printing
                setTimeout(function() {
                    document.getElementById('print-area').style.display = 'none';
                }, 100);
            }, 50);
        }
        
        // Auto print if needed
        <% if ("on".equals(request.getParameter("autoPrint"))) { %>
        setTimeout(function() {
            printReceipt();
        }, 1000);
        <% } %>
        
        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey && e.key === 'p') {
                e.preventDefault();
                printReceipt();
            }
            if (e.key === 'Escape') {
                window.location.href = 'cart.jsp';
            }
        });
        
        // Notification for multiple copies
        <% if (receiptCopies > 1) { %>
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Akan dicetak ' + <%= receiptCopies %> + ' salinan struk');
        });
        <% } %>
    </script>
</body>
</html>