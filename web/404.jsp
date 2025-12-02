<%-- 
    Document   : 404
    Created on : 2 Dec 2025, 13.27.53
    Author     : ARJUNA.R.PUTRA
--%>


<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Page Not Found</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6 text-center">
                <h1 class="display-1 text-danger">404</h1>
                <h2 class="mb-4">Page Not Found</h2>
                <p class="lead">The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.</p>
                <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">
                    Go to Login Page
                </a>
            </div>
        </div>
    </div>
</body>
</html>
