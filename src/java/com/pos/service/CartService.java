/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.service;

import com.pos.dao.ProductDAO;
import com.pos.model.CartItem;
import com.pos.model.Product;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ARJUNA.R.PUTRA
 */


public class CartService {
    private List<CartItem> cartItems;
    private ProductDAO productDAO;
    
    public CartService() {
        cartItems = new ArrayList<>();
        productDAO = new ProductDAO();
    }
    
    // Get all products
    public List<Product> getAllProducts() {
        System.out.println("CartService: Getting all products from DAO");
        List<Product> products = productDAO.getAllProducts();
        System.out.println("CartService: Received " + (products != null ? products.size() : "null") + " products");
        return products;
    }
    
    // Get product by code
    public Product getProductByCode(String code) {
        return productDAO.getProductByCode(code);
    }
    
    // Add item to cart
    public void addToCart(String productCode, int quantity) {
        Product product = getProductByCode(productCode);
        if (product != null) {
            // Check if product already in cart
            for (CartItem item : cartItems) {
                if (item.getProduct().getCode().equals(productCode)) {
                    item.setQuantity(item.getQuantity() + quantity);
                    return;
                }
            }
            // Add new item
            cartItems.add(new CartItem(product, quantity));
        }
    }
    
    // Remove item from cart
    public void removeFromCart(String productCode) {
        cartItems.removeIf(item -> item.getProduct().getCode().equals(productCode));
    }
    
    // Update cart item quantity - method yang diperlukan UpdateCartServlet
    public void updateQuantity(String productCode, int quantity) {
        for (CartItem item : cartItems) {
            if (item.getProduct().getCode().equals(productCode)) {
                if (quantity <= 0) {
                    removeFromCart(productCode);
                } else {
                    item.setQuantity(quantity);
                }
                break;
            }
        }
    }
    
    // Alias untuk updateQuantity (untuk konsistensi)
    public void updateCartItem(String productCode, int quantity) {
        updateQuantity(productCode, quantity);
    }
    
    // Clear cart
    public void clearCart() {
        cartItems.clear();
    }
    
    // Get all cart items
    public List<CartItem> getCartItems() {
        return cartItems;
    }
    
    // Calculate total - method yang diperlukan ProcessPaymentServlet
    public double getTotal() {
        return calculateTotal();
    }
    
    // Calculate total
    public double calculateTotal() {
        double total = 0;
        for (CartItem item : cartItems) {
            total += item.getSubtotal();
        }
        return total;
    }
    
    // Calculate change - method yang diperlukan ProcessPaymentServlet
    public double calculateChange(double cash) {
        double total = calculateTotal();
        return cash - total;
    }
    
    // Process payment - method yang diperlukan ProcessPaymentServlet
    public boolean processPayment(double cash) {
        try {
            double total = calculateTotal();
            if (cash >= total) {
                // Update stock for each item
                for (CartItem item : cartItems) {
                    String productCode = item.getProduct().getCode();
                    int quantity = item.getQuantity();
                    productDAO.updateProductStock(productCode, quantity);
                }
                clearCart();
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get cart size
    public int getCartSize() {
        return cartItems.size();
    }
    
    // Get item count for a specific product
    public int getItemQuantity(String productCode) {
        for (CartItem item : cartItems) {
            if (item.getProduct().getCode().equals(productCode)) {
                return item.getQuantity();
            }
        }
        return 0;
    }
    
    // Check if cart is empty
    public boolean isEmpty() {
        return cartItems.isEmpty();
    }
    
    // Remove item by index
    public void removeItem(int index) {
        if (index >= 0 && index < cartItems.size()) {
            cartItems.remove(index);
        }
    }
    
    // Get item by index
    public CartItem getItem(int index) {
        if (index >= 0 && index < cartItems.size()) {
            return cartItems.get(index);
        }
        return null;
    }
}