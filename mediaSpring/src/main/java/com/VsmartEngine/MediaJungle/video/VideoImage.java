package com.VsmartEngine.MediaJungle.video;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;

@Entity
@Table
public class VideoImage {
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;
	
	@Column(name="videoId",unique = true) 
	private long videoId;
	
	@Lob
	@Column(name="videoThumbnail" ,length=1000000)
	private byte[] videoThumbnail;
	
	@Lob
	@Column(name="trailerThumbnail" ,length=1000000)
	private byte[] trailerThumbnail;
	
	@Lob
	@Column(name="userBanner" ,length=1000000)
	private byte[] userBanner;
	public VideoImage() {
		super();
		// TODO Auto-generated constructor stub
	}
	public VideoImage(long id, long videoId, byte[] videoThumbnail, byte[] trailerThumbnail, byte[] userBanner) {
		super();
		this.id = id;
		this.videoId = videoId;
		this.videoThumbnail = videoThumbnail;
		this.trailerThumbnail = trailerThumbnail;
		this.userBanner = userBanner;
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
	public byte[] getVideoThumbnail() {
		return videoThumbnail;
	}
	public void setVideoThumbnail(byte[] videoThumbnail) {
		this.videoThumbnail = videoThumbnail;
	}
	public byte[] getTrailerThumbnail() {
		return trailerThumbnail;
	}
	public void setTrailerThumbnail(byte[] trailerThumbnail) {
		this.trailerThumbnail = trailerThumbnail;
	}
	public byte[] getUserBanner() {
		return userBanner;
	}
	public void setUserBanner(byte[] userBanner) {
		this.userBanner = userBanner;
	}
	
	

}
