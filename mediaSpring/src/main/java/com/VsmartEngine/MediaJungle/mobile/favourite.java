package com.VsmartEngine.MediaJungle.mobile;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Table
@Entity
public class favourite {
	
	 @Id
	 @GeneratedValue(strategy = GenerationType.IDENTITY)
	 private Long id;
	 
	 private Long userId;
	 private Long audioId;
	 private Long videoId;
	public favourite() {
		super();
		// TODO Auto-generated constructor stub
	}
	public favourite(Long id, Long userId, Long audioId, Long videoId) {
		super();
		this.id = id;
		this.userId = userId;
		this.audioId = audioId;
		this.videoId = videoId;
	}
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public Long getUserId() {
		return userId;
	}
	public void setUserId(Long userId) {
		this.userId = userId;
	}
	public Long getAudioId() {
		return audioId;
	}
	public void setAudioId(Long audioId) {
		this.audioId = audioId;
	}
	public Long getVideoId() {
		return videoId;
	}
	public void setVideoId(Long videoId) {
		this.videoId = videoId;
	}
	
}
