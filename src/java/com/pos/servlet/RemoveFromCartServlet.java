/*
 * RemoveFromCartServlet.java - Servlet untuk menghapus item dari keranjang
 */
package com.pos.servlet;

import com.pos.service.CartService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/RemoveFromCartServlet")
public class RemoveFromCartServlet extends HttpServlet {
    
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
        
        if (productCode != null && !productCode.trim().isEmpty()) {
            cartService.removeFromCart(productCode);
        }
        
        response.sendRedirect("cart.jsp");
    }
}