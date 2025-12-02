/*
 * UpdateCartServlet.java - Servlet untuk update jumlah item di keranjang (VERSION FIXED)
 */
package com.pos.servlet;

import com.pos.service.CartService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/UpdateCartServlet")
public class UpdateCartServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        CartService cartService = (CartService) session.getAttribute("cartService");
        
        if (cartService == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        String productCode = request.getParameter("productCode");
        int quantity = 1;
        
        try {
            quantity = Integer.parseInt(request.getParameter("quantity"));
        } catch (NumberFormatException e) {
            quantity = 1;
        }
        
        if (productCode != null && !productCode.trim().isEmpty()) {
            cartService.updateQuantity(productCode, quantity);
        }
        
        response.sendRedirect("cart.jsp");
    }
}