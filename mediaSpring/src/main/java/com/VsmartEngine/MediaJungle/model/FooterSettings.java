package com.VsmartEngine.MediaJungle.model;

import java.time.LocalDateTime;

import org.springframework.web.bind.annotation.CrossOrigin;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Size;
import lombok.Data;


@CrossOrigin("*")
@Data
@Entity
@Table(name = "footer_settings")
public class FooterSettings {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(columnDefinition = "TEXT")
    private String aboutUsHeaderScript;
    
    @Column(columnDefinition = "TEXT")
    @Size(max = 5000)
    private String aboutUsBodyScript;

    @Column(columnDefinition = "TEXT")
    private String featureBox1HeaderScript;

    @Column(columnDefinition = "TEXT")
    private String featureBox1BodyScript;


    @Column(columnDefinition = "TEXT")
    private String featureBox2HeaderScript;

    @Column(columnDefinition = "TEXT")
    private String featureBox2BodyScript;

    private byte[] aboutUsImage; // Image file path


	@Column(length = 255)
    private String contactUsEmail;

    @Column(columnDefinition = "TEXT")
    private String contactUsBodyScript;

    @Column(length = 20)
    private String callUsPhoneNumber;

    @Column(columnDefinition = "TEXT")
    private String callUsBodyScript;

    @Column(length = 255)
    private String locationMapUrl;

    @Column(columnDefinition = "TEXT")
    private String locationAddress;

    private byte[] contactUsImage; // Image file path

    @Column(length = 255)
    private String appUrlPlaystore;

    @Column(length = 255)
    private String appUrlAppStore;

    @Column(columnDefinition = "TEXT")
    private String copyrightInfo;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(nullable = false)
    private LocalDateTime updatedAt = LocalDateTime.now();

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getAboutUsHeaderScript() {
		return aboutUsHeaderScript;
	}

	public void setAboutUsHeaderScript(String aboutUsHeaderScript) {
		this.aboutUsHeaderScript = aboutUsHeaderScript;
	}

	public String getAboutUsBodyScript() {
		return aboutUsBodyScript;
	}

	public void setAboutUsBodyScript(String aboutUsBodyScript) {
		this.aboutUsBodyScript = aboutUsBodyScript;
	}

	public String getFeatureBox1HeaderScript() {
		return featureBox1HeaderScript;
	}

	public void setFeatureBox1HeaderScript(String featureBox1HeaderScript) {
		this.featureBox1HeaderScript = featureBox1HeaderScript;
	}

	public String getFeatureBox1BodyScript() {
		return featureBox1BodyScript;
	}

	public void setFeatureBox1BodyScript(String featureBox1BodyScript) {
		this.featureBox1BodyScript = featureBox1BodyScript;
	}
    public String getFeatureBox2HeaderScript() {
		return featureBox2HeaderScript;
	}

	public void setFeatureBox2HeaderScript(String featureBox2HeaderScript) {
		this.featureBox2HeaderScript = featureBox2HeaderScript;
	}

	public String getFeatureBox2BodyScript() {
		return featureBox2BodyScript;
	}

	public void setFeatureBox2BodyScript(String featureBox2BodyScript) {
		this.featureBox2BodyScript = featureBox2BodyScript;
	}
	
	public byte[] getAboutUsImage() {
		return aboutUsImage;
	}

	public void setAboutUsImage(byte[] aboutUsImage) {
		this.aboutUsImage = aboutUsImage;
	}
	
	public String getContactUsEmail() {
		return contactUsEmail;
	}

	public void setContactUsEmail(String contactUsEmail) {
		this.contactUsEmail = contactUsEmail;
	}

	public String getContactUsBodyScript() {
		return contactUsBodyScript;
	}

	public void setContactUsBodyScript(String contactUsBodyScript) {
		this.contactUsBodyScript = contactUsBodyScript;
	}

	public String getCallUsPhoneNumber() {
		return callUsPhoneNumber;
	}

	public void setCallUsPhoneNumber(String callUsPhoneNumber) {
		this.callUsPhoneNumber = callUsPhoneNumber;
	}

	public String getCallUsBodyScript() {
		return callUsBodyScript;
	}

	public void setCallUsBodyScript(String callUsBodyScript) {
		this.callUsBodyScript = callUsBodyScript;
	}

	public String getLocationMapUrl() {
		return locationMapUrl;
	}

	public void setLocationMapUrl(String locationMapUrl) {
		this.locationMapUrl = locationMapUrl;
	}

	public String getLocationAddress() {
		return locationAddress;
	}

	public void setLocationAddress(String locationAddress) {
		this.locationAddress = locationAddress;
	}

	public byte[] getContactUsImage() {
		return contactUsImage;
	}

	public void setContactUsImage(byte[] contactUsImage) {
		this.contactUsImage = contactUsImage;
	}

	public String getAppUrlPlaystore() {
		return appUrlPlaystore;
	}

	public void setAppUrlPlaystore(String appUrlPlaystore) {
		this.appUrlPlaystore = appUrlPlaystore;
	}

	public String getAppUrlAppStore() {
		return appUrlAppStore;
	}

	public void setAppUrlAppStore(String appUrlAppStore) {
		this.appUrlAppStore = appUrlAppStore;
	}

	public String getCopyrightInfo() {
		return copyrightInfo;
	}

	public void setCopyrightInfo(String copyrightInfo) {
		this.copyrightInfo = copyrightInfo;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}

	public LocalDateTime getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(LocalDateTime updatedAt) {
		this.updatedAt = updatedAt;
	}
}
