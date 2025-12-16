/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.pos.model;

/**
 *
 * @author ARJUNA.R.PUTRA
 */

public class Category {
    private int id;
    private String code;
    private String name;
    private String description;
    private int productCount;
    
    // Constructors
    public Category() {}
    
    public Category(int id, String code, String name, String description) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.description = description;
    }
    
    // Getters and Setters
    public int getId() { 
        return id; 
    }
    
    public void setId(int id) { 
        this.id = id; 
    }
    
    public String getCode() { 
        return code; 
    }
    
    public void setCode(String code) { 
        this.code = code; 
    }
    
    public String getName() { 
        return name; 
    }
    
    public void setName(String name) { 
        this.name = name; 
    }
    
    public String getDescription() { 
        return description; 
    }
    
    public void setDescription(String description) { 
        this.description = description; 
    }
    
    public int getProductCount() { 
        return productCount; 
    }
    
    public void setProductCount(int productCount) { 
        this.productCount = productCount; 
    }
}