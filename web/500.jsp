<%-- 
    Document   : 500
    Created on : 2 Dec 2025, 13.28.12
    Author     : ARJUNA.R.PUTRA
--%>

<%-- File: 500.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 - Internal Server Error</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6 text-center">
                <h1 class="display-1 text-danger">500</h1>
                <h2 class="mb-4">Internal Server Error</h2>
                <p class="lead">Something went wrong on our end. Please try again later.</p>
                <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">
                    Go to Login Page
                </a>
            </div>
        </div>
    </div>
</body>
</html>
