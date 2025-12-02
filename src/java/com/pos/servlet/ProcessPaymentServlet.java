/*
 * ProcessPaymentServlet.java - Servlet untuk proses pembayaran (VERSION FIXED)
 */
package com.pos.servlet;

import com.pos.service.CartService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/ProcessPaymentServlet")
public class ProcessPaymentServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        CartService cartService = (CartService) session.getAttribute("cartService");
        
        if (cartService == null || cartService.isEmpty()) {
            response.sendRedirect("cart.jsp?error=Keranjang kosong");
            return;
        }
        
        try {
            double cash = Double.parseDouble(request.getParameter("cash"));
            double total = cartService.getTotal();
            double change = cartService.calculateChange(cash);
            
            if (cash < total) {
                response.sendRedirect("cart.jsp?error=Uang tidak cukup&total=" + total + "&cash=" + cash);
                return;
            }
            
            if (cartService.processPayment(cash)) {
                // Payment successful
                request.setAttribute("total", total);
                request.setAttribute("cash", cash);
                request.setAttribute("change", change);
                
                // Redirect to receipt page
                RequestDispatcher dispatcher = request.getRequestDispatcher("receipt.jsp");
                dispatcher.forward(request, response);
            } else {
                response.sendRedirect("cart.jsp?error=Gagal memproses pembayaran");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("cart.jsp?error=Input uang tidak valid");
        }
    }
}