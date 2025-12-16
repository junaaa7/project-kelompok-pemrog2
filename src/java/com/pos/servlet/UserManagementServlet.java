/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.servlet;

import com.pos.dao.UserManagementDAO;
import com.pos.model.User;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.*;

/**
 *
 * @author ARJUNA.R.PUTRA
 */

@WebServlet("/UserManagementServlet")
public class UserManagementServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        UserManagementDAO userDAO = new UserManagementDAO();
        String message = null;
        String error = null;
        
        try {
            if ("add".equals(action)) {
                String username = request.getParameter("username");
                String password = request.getParameter("password");
                String confirmPassword = request.getParameter("confirmPassword");
                
                // Validasi
                if (username == null || username.trim().isEmpty()) {
                    error = "Username tidak boleh kosong!";
                } else if (password == null || password.trim().isEmpty()) {
                    error = "Password tidak boleh kosong!";
                } else if (!password.equals(confirmPassword)) {
                    error = "Password dan Konfirmasi Password tidak sama!";
                } else if (userDAO.usernameExists(username)) {
                    error = "Username sudah terdaftar!";
                } else {
                    User user = new User();
                    user.setUsername(username.trim());
                    user.setPassword(password); // Plain text sesuai database
                    user.setFullName(request.getParameter("fullName"));
                    user.setEmail(request.getParameter("email"));
                    user.setRole(request.getParameter("role"));
                    user.setActive(true);
                    
                    if (userDAO.addUser(user)) {
                        message = "User " + username + " berhasil ditambahkan!";
                    } else {
                        error = "Gagal menambahkan user. Silakan coba lagi.";
                    }
                }
                
            } else if ("update".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                User user = userDAO.getUserById(userId);
                
                if (user != null) {
                    user.setFullName(request.getParameter("fullName"));
                    user.setEmail(request.getParameter("email"));
                    user.setRole(request.getParameter("role"));
                    user.setActive("on".equals(request.getParameter("isActive")));
                    
                    // Update password jika diisi
                    String newPassword = request.getParameter("password");
                    boolean success;
                    
                    if (newPassword != null && !newPassword.trim().isEmpty()) {
                        user.setPassword(newPassword);
                        success = userDAO.updateUserWithPassword(user);
                    } else {
                        success = userDAO.updateUser(user);
                    }
                    
                    if (success) {
                        message = "User " + user.getUsername() + " berhasil diupdate!";
                    } else {
                        error = "Gagal mengupdate user.";
                    }
                } else {
                    error = "User tidak ditemukan!";
                }
                
            } else if ("toggleStatus".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                
                if (userId == currentUser.getId()) {
                    error = "Tidak dapat mengubah status user sendiri!";
                } else {
                    User user = userDAO.getUserById(userId);
                    if (user != null) {
                        boolean newStatus = !user.isActive();
                        if (userDAO.toggleUserStatus(userId, newStatus)) {
                            message = "Status user " + user.getUsername() + " berhasil diubah!";
                        } else {
                            error = "Gagal mengubah status user.";
                        }
                    } else {
                        error = "User tidak ditemukan!";
                    }
                }
                
            } else if ("delete".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                
                if (userId == currentUser.getId()) {
                    error = "Tidak dapat menghapus user sendiri!";
                } else {
                    if (userDAO.deleteUser(userId)) {
                        message = "User berhasil dihapus!";
                    } else {
                        error = "Gagal menghapus user.";
                    }
                }
            }
            
        } catch (NumberFormatException e) {
            error = "ID user tidak valid!";
            e.printStackTrace();
        } catch (Exception e) {
            error = "Terjadi kesalahan sistem: " + e.getMessage();
            e.printStackTrace();
        }
        
        // Set attributes
        if (message != null) {
            request.setAttribute("message", message);
        }
        if (error != null) {
            request.setAttribute("error", error);
        }
        
        // Redirect ke user-management.jsp
        RequestDispatcher dispatcher = request.getRequestDispatcher("user-management.jsp");
        dispatcher.forward(request, response);
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect ke POST atau tampilkan form
        doPost(request, response);
    }
}