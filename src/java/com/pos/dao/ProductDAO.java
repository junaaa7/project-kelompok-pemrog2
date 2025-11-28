/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.dao;

import com.pos.model.Product;
import java.util.*;

/**
 *
 * @author ARJUNA.R.PUTRA
 */
public class ProductDAO {
    private static Map<String, Product> products = new HashMap<>();
    
    static {
        // Sample data
        products.put("P001", new Product("P001", "Buku Tulis", 5000, 100));
        products.put("P002", new Product("P002", "Pensil", 2000, 150));
        products.put("P003", new Product("P003", "Penghapus", 1500, 80));
    }
    
    public List<Product> getAllProducts() {
        return new ArrayList<>(products.values());
    }
    
    public Product getProductByCode(String code) {
        return products.get(code);
    }
    
    public void addProduct(Product product) {
        products.put(product.getCode(), product);
    }
    
    public boolean updateProductStock(String code, int quantity) {
        Product product = products.get(code);
        if (product != null && product.getStock() >= quantity) {
            product.setStock(product.getStock() - quantity);
            return true;
        }
        return false;
    }
}