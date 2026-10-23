package com.VsmartEngine.MediaJungle.test;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table
public class AudioContainer {
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;
	
	@Column(name="container_name" )
	private String container_name;
	
	@Column(name="category_id" )
	private long categoryId;

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getContainer_name() {
		return container_name;
	}

	public void setContainer_name(String container_name) {
		this.container_name = container_name;
	}

	public long getCategoryId() {
		return categoryId;
	}

	public void setCategoryId(long categoryId) {
		this.categoryId = categoryId;
	}

	@Override
	public String toString() {
		return "AudioContainer [id=" + id + ", container_name=" + container_name + ", categoryId=" + categoryId
				+ "]";
	}
	
	
	
	

}
