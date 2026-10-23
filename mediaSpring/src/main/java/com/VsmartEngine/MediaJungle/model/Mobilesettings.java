package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
@Entity
@Table(name="mobile_settings")
public class Mobilesettings {
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;

	@Column (name ="google_analytics")
	private String google_analytics;
	
	@Column (name ="header_scripts")
	private String header_scripts;
	
	@Column (name ="body_scripts")
	private String body_scripts;

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getGoogle_analytics() {
		return google_analytics;
	}

	public void setGoogle_analytics(String google_analytics) {
		this.google_analytics = google_analytics;
	}

	public String getHeader_scripts() {
		return header_scripts;
	}

	public void setHeader_scripts(String header_scripts) {
		this.header_scripts = header_scripts;
	}

	public String getBody_scripts() {
		return body_scripts;
	}

	public void setBody_scripts(String body_scripts) {
		this.body_scripts = body_scripts;
	}

	public Mobilesettings(long id, String google_analytics, String header_scripts, String body_scripts) {
		super();
		this.id = id;
		this.google_analytics = google_analytics;
		this.header_scripts = header_scripts;
		this.body_scripts = body_scripts;
	}
	
	
}
