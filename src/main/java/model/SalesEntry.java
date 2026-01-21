package model;

import java.io.Serializable;

public class SalesEntry implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int id; // Thêm ID (Số thứ tự trong Database)
    private String entryDate;
    private String customerName;
    private String description;
    private int quantity;
    private double price;
    private double revenue;

    // Constructor đầy đủ
    public SalesEntry(int id, String entryDate, String customerName, String description, int quantity, double price) {
        this.id = id;
        this.entryDate = entryDate;
        this.customerName = customerName;
        this.description = description;
        this.quantity = quantity;
        this.price = price;
        this.revenue = quantity * price;
    }
    
    // Constructor cho báo cáo (không cần ID)
    public SalesEntry(String entryDate, String description, double revenue) {
        this.entryDate = entryDate;
        this.description = description;
        this.revenue = revenue;
    }

    public int getId() { return id; } // Getter cho ID
    public String getEntryDate() { return entryDate; }
    public String getCustomerName() { return customerName; }
    public String getDescription() { return description; }
    public int getQuantity() { return quantity; }
    public double getPrice() { return price; }
    public double getRevenue() { return revenue; }
}