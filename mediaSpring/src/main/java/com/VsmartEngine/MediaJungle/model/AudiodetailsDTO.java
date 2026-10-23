package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;

public class AudiodetailsDTO {

	private Long id;
	private String audioTitle;
	private Boolean paid;
	private String production_company;
	private String rating;
	private String categories;

	public AudiodetailsDTO(Long id, String audioTitle, Boolean paid, String production_company, String rating,
			String categories) {
		super();
		this.id = id;
		this.audioTitle = audioTitle;
		this.paid = paid;
		this.production_company = production_company;
		this.rating = rating;
		this.categories = categories;
	}

	// Getters and setters (optional)
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getAudioTitle() {
		return audioTitle;
	}

	public void setAudioTitle(String audioTitle) {
		this.audioTitle = audioTitle;
	}

	public Boolean getPaid() {
		return paid;
	}

	public void setPaid(Boolean paid) {
		this.paid = paid;
	}

	public String getProduction_company() {
		return production_company;
	}

	public void setProduction_company(String production_company) {
		this.production_company = production_company;
	}

	public String getRating() {
		return rating;
	}

	public void setRating(String rating) {
		this.rating = rating;
	}

	public String getCategories() {
		return categories;
	}

	public void setCategories(String categories) {
		this.categories = categories;
	}

	@Override
	public String toString() {
		return "AudiodetailsDTO [id=" + id + ", audioTitle=" + audioTitle + ", paid=" + paid + ", production_company="
				+ production_company + ", rating=" + rating + ", categories=" + categories + "]";
	}

}
