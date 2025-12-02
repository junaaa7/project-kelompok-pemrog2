/*
 * ClearCartServlet.java - Servlet untuk mengosongkan keranjang
 */
package com.pos.servlet;

import com.pos.service.CartService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/ClearCartServlet")
public class ClearCartServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        CartService cartService = (CartService) session.getAttribute("cartService");
        
        if (cartService != null) {
            cartService.clearCart();
        }
        
        response.sendRedirect("cart.jsp");
    }
}