package com.VsmartEngine.MediaJungle.Banner;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table
public class VideoBanner {
	
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

   
    private long videoId;
	public VideoBanner() {
		super();
		// TODO Auto-generated constructor stub
	}
	public VideoBanner(long id, long videoId) {
		super();
		this.id = id;
		this.videoId = videoId;
	}
	public long getId() {
		return id;
	}
	public void setId(long id) {
		this.id = id;
	}

	public long getVideoId() {
		return videoId;
	}
	public void setVideoId(long videoId) {
		this.videoId = videoId;
	}
    
    

}
