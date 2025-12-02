/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.servlet;

import com.pos.dao.UserDAO;
import com.pos.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 *
 * @author ARJUNA.R.PUTRA
 */

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    
    private final UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Jika sudah login, redirect ke dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        
        // Tampilkan halaman login
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        try {
            User user = userDAO.authenticate(username, password);
            
            if (user != null) {
                // Login berhasil
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                
                // Redirect berdasarkan role
                if ("admin".equals(user.getRole())) {
                    response.sendRedirect("dashboard.jsp");
                } else {
                    response.sendRedirect("index.jsp");
                }
            } else {
                // Login gagal
                request.setAttribute("error", "Username atau password salah");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }
        } catch (ServletException | IOException e) {
            request.setAttribute("error", "Terjadi kesalahan sistem: " + e.getMessage());
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}