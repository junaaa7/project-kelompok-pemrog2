<%-- 
    Document   : product-form.jsp
    Created on : 28 Nov 2025, 23.34.42
    Author     : ARJUNA.R.PUTRA
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Tambah Produk Baru</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <div class="container">
        <h1>Tambah Produk Baru</h1>
        
        <form action="AddProductServlet" method="post">
            <table class="form-table">
                <tr>
                    <td>Kode Produk:</td>
                    <td><input type="text" name="code" required></td>
                </tr>
                <tr>
                    <td>Nama Produk:</td>
                    <td><input type="text" name="name" required></td>
                </tr>
                <tr>
                    <td>Harga:</td>
                    <td><input type="number" name="price" step="0.01" required></td>
                </tr>
                <tr>
                    <td>Stok:</td>
                    <td><input type="number" name="stock" required></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <button type="submit">Simpan</button>
                        <a href="index.jsp" class="btn">Kembali</a>
                    </td>
                </tr>
            </table>
        </form>
    </div>
</body>
</html>
