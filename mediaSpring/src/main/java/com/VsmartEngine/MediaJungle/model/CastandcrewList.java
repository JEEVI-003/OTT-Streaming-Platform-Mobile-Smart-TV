package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table
public class CastandcrewList {
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;
	
	private long castandcrewid;
	
	private long videoid;

	public CastandcrewList() {
		super();
		// TODO Auto-generated constructor stub
	}

	public CastandcrewList(long id, long castandcrewid, long videoid) {
		super();
		this.id = id;
		this.castandcrewid = castandcrewid;
		this.videoid = videoid;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public long getCastandcrewid() {
		return castandcrewid;
	}

	public void setCastandcrewid(long castandcrewid) {
		this.castandcrewid = castandcrewid;
	}

	public long getVideoid() {
		return videoid;
	}

	public void setVideoid(long videoid) {
		this.videoid = videoid;
	}
	
	
	
	

}
