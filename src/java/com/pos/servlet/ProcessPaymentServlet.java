/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.servlet;

import com.pos.service.CartService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.*;
/**
 *
 * @author ARJUNA.R.PUTRA
 */
public class ProcessPaymentServlet extends HttpServlet {

    /**
     *
     * @param request
     * @param response
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        CartService cartService = (CartService) session.getAttribute("cartService");
        
        double cash = Double.parseDouble(request.getParameter("cash"));
        double total = cartService.getTotal();
        double change = cartService.calculateChange(cash);
        
        if (change >= 0) {
            if (cartService.processPayment(cash)) {
                session.setAttribute("cash", cash);
                session.setAttribute("change", change);
                cartService.clearCart();
                response.sendRedirect("receipt.jsp");
            } else {
                session.setAttribute("error", "Gagal memproses pembayaran");
                response.sendRedirect("cart.jsp");
            }
        } else {
            session.setAttribute("error", "Cash tidak mencukupi");
            response.sendRedirect("cart.jsp");
        }
    }
}
