/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.model;

/**
 *
 * @author ARJUNA.R.PUTRA
 */
public class CartItem {
    private Product product;
    private int quantity;
    private double subtotal;
    
    public CartItem() {}
    
    public CartItem(Product product, int quantity) {
        this.product = product;
        this.quantity = quantity;
        this.subtotal = product.getPrice() * quantity;
    }
    
    // Getters and Setters
    public Product getProduct() { return product; }
    public void setProduct(Product product) { 
        this.product = product;
        calculateSubtotal();
    }
    
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { 
        this.quantity = quantity;
        calculateSubtotal();
    }
    
    public double getSubtotal() { return subtotal; }
    
    private void calculateSubtotal() {
        this.subtotal = product.getPrice() * quantity;
    }
}