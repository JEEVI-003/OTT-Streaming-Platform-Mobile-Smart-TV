package com.VsmartEngine.MediaJungle.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.VsmartEngine.MediaJungle.dto.DiscountRequest;


@RestController
@RequestMapping("/api/v2")
@CrossOrigin(origins = "*")
public class DiscountController {
	   @PostMapping("/calculateDiscount")
	    public ResponseEntity<Double> calculateDiscount(@RequestBody DiscountRequest request) {
	        double monthlyAmount = request.getMonthlyAmount();
	        int totalMonths = request.getTotalMonths();
	        int discountedMonths = request.getDiscountedMonths();

	        // Calculate the discounted amount
	        double totalAmount = monthlyAmount * totalMonths;
	        double discountAmount = monthlyAmount * discountedMonths;
	        double finalAmount = totalAmount - discountAmount;

	        return ResponseEntity.ok(finalAmount);
	    }
	   
}
