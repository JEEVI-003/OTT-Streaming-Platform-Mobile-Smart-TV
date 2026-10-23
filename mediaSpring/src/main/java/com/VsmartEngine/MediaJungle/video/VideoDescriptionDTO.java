package com.VsmartEngine.MediaJungle.video;

public class VideoDescriptionDTO {
	
	   private Long videoId;
	   private byte[] thumbnail;
	public VideoDescriptionDTO() {
		super();
		// TODO Auto-generated constructor stub
	}
	public VideoDescriptionDTO(Long videoId, byte[] thumbnail) {
		super();
		this.videoId = videoId;
		this.thumbnail = thumbnail;
	}
	public Long getVideoId() {
		return videoId;
	}
	public void setVideoId(Long videoId) {
		this.videoId = videoId;
	}
	public byte[] getThumbnail() {
		return thumbnail;
	}
	public void setThumbnail(byte[] thumbnail) {
		this.thumbnail = thumbnail;
	}
	
	   
}
