/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.servlet;

import com.pos.service.CartService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

/**
 *
 * @author ARJUNA.R.PUTRA
 */

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