package com.VsmartEngine.MediaJungle.model;

import java.time.LocalDate;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table
public class SubScription {

	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String subscriptionTitle;
    private String paymentId;
    private String orderId;
    private double paidAmount;
    private LocalDate expiryDate;
    private String status;
    private Long userId;


	public SubScription() {
		super();
		// TODO Auto-generated constructor stub
	}


	public SubScription(Long id, String subscriptionTitle, String paymentId, String orderId, double paidAmount,
			LocalDate expiryDate, String status, Long userId) {
		super();
		this.id = id;
		this.subscriptionTitle = subscriptionTitle;
		this.paymentId = paymentId;
		this.orderId = orderId;
		this.paidAmount = paidAmount;
		this.expiryDate = expiryDate;
		this.status = status;
		this.userId = userId;
	}


	public Long getId() {
		return id;
	}


	public void setId(Long id) {
		this.id = id;
	}


	public String getSubscriptionTitle() {
		return subscriptionTitle;
	}


	public void setSubscriptionTitle(String subscriptionTitle) {
		this.subscriptionTitle = subscriptionTitle;
	}


	public String getPaymentId() {
		return paymentId;
	}


	public void setPaymentId(String paymentId) {
		this.paymentId = paymentId;
	}


	public String getOrderId() {
		return orderId;
	}


	public void setOrderId(String orderId) {
		this.orderId = orderId;
	}


	public double getPaidAmount() {
		return paidAmount;
	}


	public void setPaidAmount(double paidAmount) {
		this.paidAmount = paidAmount;
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


	public Long getUserId() {
		return userId;
	}


	public void setUserId(Long userId) {
		this.userId = userId;
	}

	
}
