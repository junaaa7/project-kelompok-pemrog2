package com.pos.model;

public class SystemSettings {
    private int id;
    private String storeName;
    private String storeAddress;
    private String phone;
    private String email;
    private String currency;
    private String dateFormat;
    private boolean autoPrint;
    private boolean showStockAlert;
    
    // Receipt settings
    private String receiptHeader;
    private String receiptFooter;
    private int receiptWidth;
    private String receiptFontSize;
    private int receiptCopies;
    
    // Tax settings
    private boolean taxEnabled;
    private double taxPercentage;
    private String taxName;
    
    // Discount settings
    private double memberDiscount;
    private double minDiscountTransaction;
    
    // Backup settings
    private String backupFrequency;
    private String backupTime;
    private int backupKeepDays;
    private boolean cloudBackup;
    
    // Default constructor
    public SystemSettings() {
        this.storeName = "Toko Makmur Jaya";
        this.storeAddress = "Jl. Raya No. 123, Jakarta";
        this.phone = "021-1234567";
        this.email = "info@tokomakmurjaya.com";
        this.currency = "IDR";
        this.dateFormat = "DD/MM/YYYY";
        this.autoPrint = true;
        this.showStockAlert = true;
        this.receiptHeader = "TOKO MAKMUR JAYA\nJl. Raya No. 123, Jakarta\nTelp: 021-1234567";
        this.receiptFooter = "Terima kasih telah berbelanja\n*** Barang yang sudah dibeli tidak dapat ditukar ***\nwww.tokomakmurjaya.com";
        this.receiptWidth = 80;
        this.receiptFontSize = "Normal";
        this.receiptCopies = 1;
        this.taxEnabled = true;
        this.taxPercentage = 10.0;
        this.taxName = "PPN";
        this.memberDiscount = 5.0;
        this.minDiscountTransaction = 100000.00;
        this.backupFrequency = "Setiap Minggu";
        this.backupTime = "02:00";
        this.backupKeepDays = 30;
        this.cloudBackup = true;
    }
    
    // Getters and Setters (semua getter dan setter lengkap)
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getStoreName() { return storeName; }
    public void setStoreName(String storeName) { this.storeName = storeName; }
    
    public String getStoreAddress() { return storeAddress; }
    public void setStoreAddress(String storeAddress) { this.storeAddress = storeAddress; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    
    public String getDateFormat() { return dateFormat; }
    public void setDateFormat(String dateFormat) { this.dateFormat = dateFormat; }
    
    public boolean isAutoPrint() { return autoPrint; }
    public void setAutoPrint(boolean autoPrint) { this.autoPrint = autoPrint; }
    
    public boolean isShowStockAlert() { return showStockAlert; }
    public void setShowStockAlert(boolean showStockAlert) { this.showStockAlert = showStockAlert; }
    
    public String getReceiptHeader() { return receiptHeader; }
    public void setReceiptHeader(String receiptHeader) { this.receiptHeader = receiptHeader; }
    
    public String getReceiptFooter() { return receiptFooter; }
    public void setReceiptFooter(String receiptFooter) { this.receiptFooter = receiptFooter; }
    
    public int getReceiptWidth() { return receiptWidth; }
    public void setReceiptWidth(int receiptWidth) { this.receiptWidth = receiptWidth; }
    
    public String getReceiptFontSize() { return receiptFontSize; }
    public void setReceiptFontSize(String receiptFontSize) { this.receiptFontSize = receiptFontSize; }
    
    public int getReceiptCopies() { return receiptCopies; }
    public void setReceiptCopies(int receiptCopies) { this.receiptCopies = receiptCopies; }
    
    public boolean isTaxEnabled() { return taxEnabled; }
    public void setTaxEnabled(boolean taxEnabled) { this.taxEnabled = taxEnabled; }
    
    public double getTaxPercentage() { return taxPercentage; }
    public void setTaxPercentage(double taxPercentage) { this.taxPercentage = taxPercentage; }
    
    public String getTaxName() { return taxName; }
    public void setTaxName(String taxName) { this.taxName = taxName; }
    
    public double getMemberDiscount() { return memberDiscount; }
    public void setMemberDiscount(double memberDiscount) { this.memberDiscount = memberDiscount; }
    
    public double getMinDiscountTransaction() { return minDiscountTransaction; }
    public void setMinDiscountTransaction(double minDiscountTransaction) { 
        this.minDiscountTransaction = minDiscountTransaction; 
    }
    
    public String getBackupFrequency() { return backupFrequency; }
    public void setBackupFrequency(String backupFrequency) { this.backupFrequency = backupFrequency; }
    
    public String getBackupTime() { return backupTime; }
    public void setBackupTime(String backupTime) { this.backupTime = backupTime; }
    
    public int getBackupKeepDays() { return backupKeepDays; }
    public void setBackupKeepDays(int backupKeepDays) { this.backupKeepDays = backupKeepDays; }
    
    public boolean isCloudBackup() { return cloudBackup; }
    public void setCloudBackup(boolean cloudBackup) { this.cloudBackup = cloudBackup; }
}