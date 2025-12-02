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

@WebServlet("/AddToCartServlet")
public class AddToCartServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        CartService cartService = (CartService) session.getAttribute("cartService");
        
        if (cartService == null) {
            cartService = new CartService();
            session.setAttribute("cartService", cartService);
        }
        
        String productCode = request.getParameter("productCode");
        int quantity = 1;
        
        try {
            quantity = Integer.parseInt(request.getParameter("quantity"));
        } catch (NumberFormatException e) {
            quantity = 1;
        }
        
        if (productCode != null && !productCode.trim().isEmpty() && quantity > 0) {
            cartService.addToCart(productCode, quantity);
            System.out.println("AddToCartServlet: Added " + quantity + " of product " + productCode + " to cart");
        }
        
        // Redirect back to previous page
        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect("index.jsp");
        }
    }
}