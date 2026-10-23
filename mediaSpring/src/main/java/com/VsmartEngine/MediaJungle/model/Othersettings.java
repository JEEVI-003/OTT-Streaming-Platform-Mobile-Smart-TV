package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
@Entity
@Table(name="other_settings")
public class Othersettings {

	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;
	
	@Column (name="appstore")
	private String appstore;
	
	@Column (name="playstore")
	private String playstore;
	
	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getAppstore() {
		return appstore;
	}

	public void setAppstore(String appstore) {
		this.appstore = appstore;
	}

	public String getPlaystore() {
		return playstore;
	}

	public void setPlaystore(String playstore) {
		this.playstore = playstore;
	}

	public Othersettings(long id, String appstore, String playstore) {
		super();
		this.id = id;
		this.appstore = appstore;
		this.playstore = playstore;
	}

	public Othersettings() {
		super();
		// TODO Auto-generated constructor stub
	}

	
	
	
}
