package com.VsmartEngine.MediaJungle.model;

import com.VsmartEngine.MediaJungle.video.VideoDescription;
import com.fasterxml.jackson.annotation.JsonManagedReference;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

@Entity
@Table
public class VideoCastAndCrew {
	
	 @Id
	 @GeneratedValue(strategy = GenerationType.IDENTITY)
	 private long id;

	 @ManyToOne
	 @JoinColumn(name = "video_id")
	 @JsonManagedReference
	 private VideoDescription videoDescription;

	 @ManyToOne
	 @JoinColumn(name = "castandcrew_id")
	 @JsonManagedReference
	 private CastandCrew castAndCrew;
	 
	 @Transient
	 private String castAndCrewImage;

	public VideoCastAndCrew() {
		super();
		// TODO Auto-generated constructor stub
	}

	

	public String getCastAndCrewImage() {
		return castAndCrewImage;
	}



	public void setCastAndCrewImage(String castAndCrewImage) {
		this.castAndCrewImage = castAndCrewImage;
	}



	public VideoCastAndCrew(long id, VideoDescription videoDescription, CastandCrew castAndCrew,
			String castAndCrewImage) {
		super();
		this.id = id;
		this.videoDescription = videoDescription;
		this.castAndCrew = castAndCrew;
		this.castAndCrewImage = castAndCrewImage;
	}



	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public VideoDescription getVideoDescription() {
		return videoDescription;
	}

	public void setVideoDescription(VideoDescription videoDescription) {
		this.videoDescription = videoDescription;
	}

	public CastandCrew getCastAndCrew() {
		return castAndCrew;
	}

	
	public void setCastAndCrew(CastandCrew castAndCrew) {
		this.castAndCrew = castAndCrew;
	}
	 
	 

}
