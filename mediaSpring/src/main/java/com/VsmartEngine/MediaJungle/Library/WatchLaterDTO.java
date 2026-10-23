package com.VsmartEngine.MediaJungle.Library;

public class WatchLaterDTO {
	
	 private Long videoId;
	 private String videoTitle;
	public WatchLaterDTO() {
		super();
		// TODO Auto-generated constructor stub
	}
	public WatchLaterDTO(Long videoId, String videoTitle) {
		super();
		this.videoId = videoId;
		this.videoTitle = videoTitle;
	}
	public Long getVideoId() {
		return videoId;
	}
	public void setVideoId(Long videoId) {
		this.videoId = videoId;
	}
	public String getVideoTitle() {
		return videoTitle;
	}
	public void setVideoTitle(String videoTitle) {
		this.videoTitle = videoTitle;
	}
	 
	 

}
