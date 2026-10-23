package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;


@Entity
@Table
public class Audiodescription {
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;
	
	@Column(name="audio_title" )
	private String audio_title;
	
	@Column(name="movie_name" )
	private long movie_name;
	
	@Column(name="rating" )
	private String rating;
	
	@Column(name="description" )
	private String description;
	
	@Column(name="production_company" )
	private String production_company;

	@Column(name="subscription_type" )
	private Boolean paid;
	
	@Column(name="audio_file_name" )
	private String audio_file_name;
	
	@Column(name="audio_Duration" )
	private String Audio_Duration;
	
	@Column(name="certificate_no" )
	private String Certificate_no;
	
	@Column(name="certificate_name" )
	private String Certificate_name;
	
	
//	 @Transient
//	 private String AudioFile;
//	
	
	
	public long getId() {
		return id;
	}
	public void setId(long id) {
		this.id = id;
	}
	
	public String getAudio_title() {
		return audio_title;
	}
	public void setAudio_title(String audio_title) {
		this.audio_title = audio_title;
	}
	public long getMovie_name() {
		return movie_name;
	}
	public void setMovie_name(long movie_name) {
		this.movie_name = movie_name;
	}
	public String getRating() {
		return rating;
	}
	public void setRating(String rating) {
		this.rating = rating;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getProduction_company() {
		return production_company;
	}
	public void setProduction_company(String production_company) {
		this.production_company = production_company;
	}
	
	public Boolean getPaid() {
		return paid;
	}
	public void setPaid(Boolean paid) {
		this.paid = paid;
	}
	
	
	public String getAudio_file_name() {
		return audio_file_name;
	}
	public void setAudio_file_name(String audio_file_name) {
		this.audio_file_name = audio_file_name;
	}
	
	public String getAudio_Duration() {
		return Audio_Duration;
	}
	public void setAudio_Duration(String audio_Duration) {
		Audio_Duration = audio_Duration;
	}
	public String getCertificate_no() {
		return Certificate_no;
	}
	public void setCertificate_no(String certificate_no) {
		Certificate_no = certificate_no;
	}
	public String getCertificate_name() {
		return Certificate_name;
	}
	public void setCertificate_name(String certificate_name) {
		Certificate_name = certificate_name;
	}
	@Override
	public String toString() {
		return "Audiodescription [id=" + id + ", audio_title=" + audio_title + ", movie_name=" + movie_name
				+ ", rating=" + rating + ", description=" + description + ", production_company=" + production_company
				+ ", paid=" + paid + ", audio_file_name=" + audio_file_name + ", Audio_Duration=" + Audio_Duration
				+ ", Certificate_no=" + Certificate_no + ", Certificate_name=" + Certificate_name + "]";
	}
	
	
	
	
	
	

}
