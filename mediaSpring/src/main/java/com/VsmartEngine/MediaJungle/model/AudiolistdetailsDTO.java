package com.VsmartEngine.MediaJungle.model;

import java.util.List;

public class AudiolistdetailsDTO {
	private Long id;
    private String audioTitle;
	private String movie_name;
	private String rating;
	private String description;
	private String production_company;
	private Boolean paid;
	private String audio_file_name;
	private String Audio_Duration;
	private String Certificate_no;
	private String Certificate_name;
	
	 private List<AddNewCategories> Category;
	 private List<Tag> Tag;
	 private  List<CastandCrewDTO> CastandCrew;
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
	public String getMovie_name() {
		return movie_name;
	}
	public void setMovie_name(String movie_name) {
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
	public List<AddNewCategories> getCategory() {
		return Category;
	}
	public void setCategory(List<AddNewCategories> category) {
		Category = category;
	}
	public List<Tag> getTag() {
		return Tag;
	}
	public void setTag(List<Tag> tag) {
		Tag = tag;
	}
	public List<CastandCrewDTO> getCastandCrew() {
		return CastandCrew;
	}
	public void setCastandCrew(List<CastandCrewDTO> castandCrew) {
		CastandCrew = castandCrew;
	}
	
	
	 
	 
	 
	

}
