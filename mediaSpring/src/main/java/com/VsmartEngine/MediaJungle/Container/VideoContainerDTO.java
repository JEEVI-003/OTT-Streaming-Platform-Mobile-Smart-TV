package com.VsmartEngine.MediaJungle.Container;

import java.util.ArrayList;
import java.util.List;

import com.VsmartEngine.MediaJungle.video.VideoDescription;

public class VideoContainerDTO {
	
	private String value;
	private long categoryid;
	private List<VideoDescription> videoDescriptions; // Matching VideoDescriptions
	public VideoContainerDTO() {
		super();
		// TODO Auto-generated constructor stub
	}
	
	

	public VideoContainerDTO(String value, long categoryid, List<VideoDescription> videoDescriptions) {
		super();
		this.value = value;
		this.categoryid = categoryid;
		this.videoDescriptions = videoDescriptions;
	}



	public String getValue() {
		return value;
	}
	public void setValue(String value) {
		this.value = value;
	}
	public List<VideoDescription> getVideoDescriptions() {
		return videoDescriptions;
	}
	public void setVideoDescriptions(List<VideoDescription> videoDescriptions) {
		this.videoDescriptions = videoDescriptions;
	}



	public long getCategoryid() {
		return categoryid;
	}



	public void setCategoryid(long categoryid) {
		this.categoryid = categoryid;
	}

	

	

}
