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
public class AddToCartServlet extends HttpServlet {

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
        
        String productCode = request.getParameter("productCode");
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        
        if (cartService.addToCart(productCode, quantity)) {
            session.setAttribute("message", "Produk berhasil ditambahkan ke keranjang");
        } else {
            session.setAttribute("error", "Gagal menambahkan produk ke keranjang");
        }
        
        response.sendRedirect("index.jsp");
    }
}
