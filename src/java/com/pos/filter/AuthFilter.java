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
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        
        String contextPath = req.getContextPath();
        String requestURI = req.getRequestURI();
        String path = requestURI.substring(contextPath.length());
        
        // Debug info
        System.out.println("AuthFilter: Path = " + path);
        
        // Resources yang boleh diakses tanpa login
        boolean isLoginPage = path.equals("/login") || path.equals("/login.jsp");
        boolean isRegisterPage = path.equals("/register") || path.equals("/register.jsp");
        boolean isStaticResource = path.startsWith("/css/") || 
                                  path.endsWith(".css") || 
                                  path.endsWith(".js") || 
                                  path.endsWith(".png") || 
                                  path.endsWith(".jpg");
        boolean isErrorPage = path.equals("/404.jsp") || path.equals("/500.jsp");
        
        User user = null;
        if (session != null) {
            user = (User) session.getAttribute("user");
        }
        
        boolean isLoggedIn = (user != null);
        
        // Allow access to login, register, static resources, and error pages
        if (isLoginPage || isRegisterPage || isStaticResource || isErrorPage) {
            chain.doFilter(request, response);
            return;
        }
        
        // Jika belum login dan mencoba akses halaman terproteksi
        if (!isLoggedIn) {
            System.out.println("AuthFilter: Redirecting to login from " + path);
            res.sendRedirect(contextPath + "/login.jsp");
            return;
        }
        
        // User sudah login, lanjutkan
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