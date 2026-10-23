package com.VsmartEngine.MediaJungle.model;

import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;


@Entity
@Table
public class PlanDetails {
	
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
	
//	@NotBlank(message = "Plan name is mandatory")
	private String planname;

//	@Positive(message = "Amount must be positive")
	private double amount;

//	@Min(value = 1, message = "Validity must be at least 1 day")
	private int validity;

	
	 @OneToMany(fetch = FetchType.EAGER, cascade = CascadeType.ALL)
	 @JoinColumn(name = "planId") // Optional: Specify the foreign key column
	 private List<PlanDescription> descriptions = new ArrayList<>();	
	
	public PlanDetails() {
		super();
		// TODO Auto-generated constructor stub
	}

	public PlanDetails(Long id, String planname, double amount, int validity, List<PlanDescription> descriptions) {
		super();
		this.id = id;
		this.planname = planname;
		this.amount = amount;
		this.validity = validity;
		this.descriptions = descriptions;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getPlanname() {
		return planname;
	}

	public void setPlanname(String planname) {
		this.planname = planname;
	}

	public double getAmount() {
		return amount;
	}

	public void setAmount(double amount) {
		this.amount = amount;
	}

	public int getValidity() {
		return validity;
	}

	public void setValidity(int validity) {
		this.validity = validity;
	}

	public List<PlanDescription> getDescriptions() {
		return descriptions;
	}

	public void setDescriptions(List<PlanDescription> descriptions) {
		this.descriptions = descriptions;
	}

	

}
