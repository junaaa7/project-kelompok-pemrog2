package com.pos.filter;

import com.pos.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, 
                         FilterChain chain) throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        String path = httpRequest.getRequestURI().substring(
            httpRequest.getContextPath().length()
        );
        
        System.out.println("AuthFilter: Checking access for path: " + path);
        
        // Skip filter for public resources
        if (path.startsWith("/login") || 
            path.startsWith("/register") || 
            path.startsWith("/css/") || 
            path.startsWith("/js/") || 
            path.startsWith("/images/") ||
            path.startsWith("/resources/") ||
            path.endsWith(".css") || 
            path.endsWith(".js") ||
            path.endsWith(".png") ||
            path.endsWith(".jpg") ||
            path.endsWith(".jpeg") ||
            path.endsWith(".gif") ||
            path.endsWith(".ico")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Check if user is logged in
        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);
        
        // If not logged in, redirect to login page
        if (!isLoggedIn) {
            System.out.println("AuthFilter: User not logged in, redirecting to login");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login.jsp");
            return;
        }
        
        // Get user from session
        User user = (User) session.getAttribute("user");
        String role = user.getRole();
        String username = user.getUsername();
        
        System.out.println("AuthFilter: User " + username + " with role " + role + " accessing " + path);
        
        // ADMIN PAGES - Block Cashier Access
        if (role.equals("cashier")) {
            String[] adminPages = {
                "/user-management.jsp",
                "/product-management.jsp", 
                "/category-management.jsp",
                "/sales-report.jsp",
                "/system-settings.jsp",
                "/product-form.jsp",
                "/UserManagementServlet",
                "/ProductManagementServlet",
                "/CategoryManagementServlet",
                "/SalesReportServlet"
            };
            
            for (String adminPage : adminPages) {
                if (path.contains(adminPage)) {
                    System.out.println("AuthFilter: Cashier " + username + " tried to access admin page: " + adminPage);
                    httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, 
                        "Access Denied: Cashier cannot access admin pages");
                    return;
                }
            }
        }
        
        // CASHIER PAGES - Block Admin Access
        if (role.equals("admin")) {
            String[] cashierOnlyPages = {
                "/index.jsp",
                "/cart.jsp",
                "/receipt.jsp",
                "/cashier-transactions.jsp",
                "/AddToCartServlet",
                "/RemoveFromCartServlet",
                "/UpdateCartServlet",
                "/ClearCartServlet",
                "/ProcessPaymentServlet"
            };
            
            for (String cashierPage : cashierOnlyPages) {
                if (path.equals(httpRequest.getContextPath() + cashierPage) || 
                    path.contains(cashierPage)) {
                    System.out.println("AuthFilter: Admin " + username + " tried to access cashier page: " + cashierPage);
                    httpResponse.sendRedirect(httpRequest.getContextPath() + "/dashboard.jsp");
                    return;
                }
            }
        }
        
        chain.doFilter(request, response);
    }
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("AuthFilter initialized");
    }
    
    @Override
    public void destroy() {
        System.out.println("AuthFilter destroyed");
    }
}