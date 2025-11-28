/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.service;

import com.pos.model.CartItem;
import com.pos.model.Product;
import com.pos.dao.ProductDAO;
import java.util.*;
/**
 *
 * @author ARJUNA.R.PUTRA
 */
public class CartService {
    private final List<CartItem> cartItems;
    private final ProductDAO productDAO;
    
    public CartService() {
        this.cartItems = new ArrayList<>();
        this.productDAO = new ProductDAO();
    }
    
    public boolean addToCart(String productCode, int quantity) {
        Product product = productDAO.getProductByCode(productCode);
        if (product != null && product.getStock() >= quantity) {
            // Check if product already in cart
            for (CartItem item : cartItems) {
                if (item.getProduct().getCode().equals(productCode)) {
                    item.setQuantity(item.getQuantity() + quantity);
                    return true;
                }
            }
            // Add new item to cart
            cartItems.add(new CartItem(product, quantity));
            return true;
        }
        return false;
    }
    
    public void removeFromCart(String productCode) {
        cartItems.removeIf(item -> item.getProduct().getCode().equals(productCode));
    }
    
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
    
    public double getTotal() {
        return cartItems.stream().mapToDouble(CartItem::getSubtotal).sum();
    }
    
    public double calculateChange(double cash) {
        return cash - getTotal();
    }
    
    public void clearCart() {
        cartItems.clear();
    }
    
    public List<CartItem> getCartItems() {
        return new ArrayList<>(cartItems);
    }
    
    public List<Product> getAllProducts() {
        return productDAO.getAllProducts();
    }
    
    public boolean processPayment(double cash) {
        if (cash >= getTotal()) {
            // Update stock for each item
            for (CartItem item : cartItems) {
                if (!productDAO.updateProductStock(
                    item.getProduct().getCode(), item.getQuantity())) {
                    return false;
                }
            }
            return true;
        }
        return false;
    }
}