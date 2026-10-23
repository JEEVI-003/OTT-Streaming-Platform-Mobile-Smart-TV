package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table
public class AddCertificate {

	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
    private long id;
	
    @Column(name="certificate")
    private String certificate;
    
    @Column(name="description")
    private String description;
    
    @Column(name="issuedby")
    private String issuedby;

	public AddCertificate() {
		super();
		// TODO Auto-generated constructor stub
	}

	public AddCertificate(long id, String certificate, String description, String issuedby) {
		super();
		this.id = id;
		this.certificate = certificate;
		this.description = description;
		this.issuedby = issuedby;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getCertificate() {
		return certificate;
	}

	public void setCertificate(String certificate) {
		this.certificate = certificate;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getIssuedby() {
		return issuedby;
	}

	public void setIssuedby(String issuedby) {
		this.issuedby = issuedby;
	}
	
}
