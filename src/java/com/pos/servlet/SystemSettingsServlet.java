package com.pos.controller;

import com.pos.dao.SystemSettingsDAO;
import com.pos.model.SystemSettings;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/SystemSettingsServlet")
public class SystemSettingsServlet extends HttpServlet {
    
    private SystemSettingsDAO settingsDAO;
    
    @Override
    public void init() {
        settingsDAO = new SystemSettingsDAO();
        // Initialize settings if not exists
        settingsDAO.initializeSettings();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        
        if ("updateGeneral".equals(action)) {
            updateGeneralSettings(request, session);
        } else if ("updateReceipt".equals(action)) {
            updateReceiptSettings(request, session);
        } else if ("updateTax".equals(action)) {
            updateTaxSettings(request, session);
        } else if ("updateBackup".equals(action)) {
            updateBackupSettings(request, session);
        }
        
        // Redirect kembali ke halaman settings
        response.sendRedirect("system-settings.jsp");
    }
    
    private void updateGeneralSettings(HttpServletRequest request, HttpSession session) {
        try {
            SystemSettings settings = new SystemSettings();
            settings.setStoreName(request.getParameter("storeName"));
            settings.setStoreAddress(request.getParameter("storeAddress"));
            settings.setPhone(request.getParameter("phone"));
            settings.setEmail(request.getParameter("email"));
            settings.setCurrency(request.getParameter("currency"));
            settings.setDateFormat(request.getParameter("dateFormat"));
            settings.setAutoPrint("on".equals(request.getParameter("autoPrint")));
            settings.setShowStockAlert("on".equals(request.getParameter("showStockAlert")));
            
            // Simpan ke database
            boolean success = settingsDAO.updateGeneralSettings(settings);
            
            if (success) {
                session.setAttribute("message", "Pengaturan umum berhasil disimpan!");
                session.setAttribute("messageType", "success");
                
                // Update session dengan data baru
                session.setAttribute("storeName", settings.getStoreName());
            } else {
                session.setAttribute("message", "Gagal menyimpan pengaturan umum!");
                session.setAttribute("messageType", "error");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Error: " + e.getMessage());
            session.setAttribute("messageType", "error");
        }
    }
    
    private void updateReceiptSettings(HttpServletRequest request, HttpSession session) {
        try {
            SystemSettings settings = new SystemSettings();
            settings.setReceiptHeader(request.getParameter("receiptHeader"));
            settings.setReceiptFooter(request.getParameter("receiptFooter"));
            settings.setReceiptWidth(Integer.parseInt(request.getParameter("receiptWidth")));
            settings.setReceiptFontSize(request.getParameter("receiptFontSize"));
            settings.setReceiptCopies(Integer.parseInt(request.getParameter("receiptCopies")));
            
            boolean success = settingsDAO.updateReceiptSettings(settings);
            
            if (success) {
                session.setAttribute("message", "Pengaturan struk berhasil disimpan!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Gagal menyimpan pengaturan struk!");
                session.setAttribute("messageType", "error");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Error: " + e.getMessage());
            session.setAttribute("messageType", "error");
        }
    }
    
    private void updateTaxSettings(HttpServletRequest request, HttpSession session) {
        try {
            SystemSettings settings = new SystemSettings();
            
            // Handle radio button for taxEnabled
            String taxEnabledParam = request.getParameter("taxEnabled");
            settings.setTaxEnabled("on".equals(taxEnabledParam) || "yes".equals(taxEnabledParam));
            
            settings.setTaxPercentage(Double.parseDouble(request.getParameter("taxPercentage")));
            settings.setTaxName(request.getParameter("taxName"));
            settings.setMemberDiscount(Double.parseDouble(request.getParameter("memberDiscount")));
            settings.setMinDiscountTransaction(Double.parseDouble(request.getParameter("minDiscountTransaction")));
            
            boolean success = settingsDAO.updateTaxSettings(settings);
            
            if (success) {
                session.setAttribute("message", "Pengaturan pajak & diskon berhasil disimpan!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Gagal menyimpan pengaturan pajak & diskon!");
                session.setAttribute("messageType", "error");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Error: " + e.getMessage());
            session.setAttribute("messageType", "error");
        }
    }
    
    private void updateBackupSettings(HttpServletRequest request, HttpSession session) {
        try {
            SystemSettings settings = new SystemSettings();
            settings.setBackupFrequency(request.getParameter("backupFrequency"));
            settings.setBackupTime(request.getParameter("backupTime"));
            settings.setBackupKeepDays(Integer.parseInt(request.getParameter("backupKeepDays")));
            settings.setCloudBackup("on".equals(request.getParameter("cloudBackup")));
            
            boolean success = settingsDAO.updateBackupSettings(settings);
            
            if (success) {
                session.setAttribute("message", "Pengaturan backup berhasil disimpan!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Gagal menyimpan pengaturan backup!");
                session.setAttribute("messageType", "error");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Error: " + e.getMessage());
            session.setAttribute("messageType", "error");
        }
    }
}