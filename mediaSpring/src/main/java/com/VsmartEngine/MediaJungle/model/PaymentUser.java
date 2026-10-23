package com.VsmartEngine.MediaJungle.model;

import java.time.LocalDate;
import java.util.Objects;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "payment_user") // Specify the table name if different from the class name
public class PaymentUser {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String orderId;
    
    @Column(unique = true)
    private Long userId;
    
    private String paymentId;
    private Long amount; // Changed from Amount to amount
    private LocalDate expiryDate;
    private String status;
    private String subscriptionTitle;

    // No-argument constructor
    public PaymentUser() {
    }

    // Parameterized constructor
    public PaymentUser(Long id, String orderId, Long userId, String paymentId, Long amount, LocalDate expiryDate,
                       String status, String subscriptionTitle) {
        this.id = id;
        this.orderId = orderId;
        this.userId = userId;
        this.paymentId = paymentId;
        this.amount = amount; // Changed from Amount to amount
        this.expiryDate = expiryDate;
        this.status = status;
        this.subscriptionTitle = subscriptionTitle;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(String paymentId) {
        this.paymentId = paymentId;
    }

    public Long getAmount() {
        return amount; // Changed from Amount to amount
    }

    public void setAmount(Long amount) {
        this.amount = amount; // Changed from Amount to amount
    }

    public LocalDate getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(LocalDate expiryDate) {
        this.expiryDate = expiryDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getSubscriptionTitle() {
        return subscriptionTitle;
    }

    public void setSubscriptionTitle(String subscriptionTitle) {
        this.subscriptionTitle = subscriptionTitle;
    }

    // Override equals and hashCode
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof PaymentUser)) return false;
        PaymentUser that = (PaymentUser) o;
        return Objects.equals(id, that.id) && Objects.equals(userId, that.userId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, userId);
    }

    // Override toString
    @Override
    public String toString() {
        return "PaymentUser{" +
                "id=" + id +
                ", orderId='" + orderId + '\'' +
                ", userId=" + userId +
                ", paymentId='" + paymentId + '\'' +
                ", amount=" + amount +
                ", expiryDate=" + expiryDate +
                ", status='" + status + '\'' +
                ", subscriptionTitle='" + subscriptionTitle + '\'' +
                '}';
    }


}