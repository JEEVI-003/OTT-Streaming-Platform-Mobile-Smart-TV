package com.VsmartEngine.MediaJungle.model;

import com.fasterxml.jackson.annotation.JsonManagedReference;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table
public class AudioCategories {
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long AudioCategories_id;
	
	@ManyToOne
	 @JoinColumn(name = "audio_id")
	 @JsonManagedReference
	 private Audiodescription audio_id;

	 @ManyToOne
	 @JoinColumn(name = "category_id")
	 @JsonManagedReference
	private AddNewCategories Categories_id;

	public long getId() {
		return AudioCategories_id;
	}

	public void setId(long id) {
		this.AudioCategories_id = id;
	}

	public Audiodescription getAudio_id() {
		return audio_id;
	}

	public void setAudio_id(Audiodescription audio_id) {
		this.audio_id = audio_id;
	}

	public AddNewCategories getCategories_id() {
		return Categories_id;
	}

	public void setCategories_id(AddNewCategories categories_id) {
		Categories_id = categories_id;
	}

	@Override
	public String toString() {
		return "AudioCategories [id=" + AudioCategories_id + ", audio_id=" + audio_id + ", Categories_id=" + Categories_id + "]";
	}
	
	
	

}
