package com.VsmartEngine.MediaJungle.dto;

public class DiscountRequest {
    private double monthlyAmount;
    private int totalMonths;
    private int discountedMonths;

    // Getters and setters
    public double getMonthlyAmount() { return monthlyAmount; }
    public void setMonthlyAmount(double monthlyAmount) { this.monthlyAmount = monthlyAmount; }

    public int getTotalMonths() { return totalMonths; }
    public void setTotalMonths(int totalMonths) { this.totalMonths = totalMonths; }

    public int getDiscountedMonths() { return discountedMonths; }
    public void setDiscountedMonths(int discountedMonths) { this.discountedMonths = discountedMonths; }
}