package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table
public class Tag {

	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long tag_id;
	
	@Column(name = "tag")
	private String tag;

	public Tag() {
		super();
		// TODO Auto-generated constructor stub
	}

	

	public Tag(long tag_id, String tag) {
		super();
		this.tag_id = tag_id;
		this.tag = tag;
	}



	public long getTag_id() {
		return tag_id;
	}



	public void setTag_id(long tag_id) {
		this.tag_id = tag_id;
	}



	public String getTag() {
		return tag;
	}

	public void setTag(String tag) {
		this.tag = tag;
	}			
}
