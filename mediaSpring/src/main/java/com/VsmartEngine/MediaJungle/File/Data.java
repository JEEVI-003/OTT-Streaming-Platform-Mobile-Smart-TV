package com.VsmartEngine.MediaJungle.File;

import jakarta.xml.bind.annotation.XmlElement;

class Data {
	private String companyName;
	private String productName;
	private String storagesize;
	private String version;
	private String key;
	private String key2;
	private String type;
	private String course;
	private String trainer;
	private String student;
	private String validity;

	@XmlElement(name = "company_name")
	public String getCompanyName() {
		return companyName;
	}

	public void setCompanyName(String companyName) {
		this.companyName = companyName;
	}
	
	@XmlElement(name = "storagesize")
	public String getStorageSize() {
		return storagesize;
	}

	public void setStorageSize(String storage_size) {
		this.storagesize = storage_size;
	}

	@XmlElement(name = "product_name")
	public String getProductName() {
		return productName;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	@XmlElement(name = "version")
	public String getVersion() {
		return version;
	}

	public void setVersion(String version) {
		this.version = version;
	}

	@XmlElement(name = "key")
	public String getKey() {
		return key;
	}

	public void setKey(String key) {
		this.key = key;
	}
	
	@XmlElement(name = "key2")
	public String getKey2() {
		return key2;
	}

	public void setKey2(String key2) {
		this.key2 = key2;
	}

	@XmlElement(name = "type")
	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}
	@XmlElement(name = "course")
	public String getCourse() {
		return course;
	}

	public void setCourse(String course) {
		this.course = course;
	}

	@XmlElement(name = "trainer")
	public String getTrainer() {
		return trainer;
	}

	public void setTrainer(String trainer) {
		this.trainer = trainer;
	}
	
	@XmlElement(name = "student")
	public String getStudent() {
		return student;
	}

	public void setStudent(String student) {
		this.student = student;
	}

	@XmlElement(name = "validity")
	public String getValidity() {
		return validity;
	}

	public void setValidity(String validity) {
		this.validity = validity;
	}

	public Data(String companyName, String productName, String storagesize, String version, String key, String key2,
			String type, String course, String trainer, String student, String validity) {
		super();
		this.companyName = companyName;
		this.productName = productName;
		this.storagesize = storagesize;
		this.version = version;
		this.key = key;
		this.key2 = key2;
		this.type = type;
		this.course = course;
		this.trainer = trainer;
		this.student = student;
		this.validity = validity;
	}

	
}