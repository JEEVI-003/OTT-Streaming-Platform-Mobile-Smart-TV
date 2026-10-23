package com.VsmartEngine.MediaJungle.video;

import java.util.ArrayList;
import java.util.List;

import com.VsmartEngine.MediaJungle.model.CastAndCrewModalDTO;

public class VideoScreenDTO {
	
	private long videoid;
	private String videotitle;
	private String duration;
	private boolean videoAccessType;
	private List<String> category = new ArrayList<>();
	private List<CastAndCrewModalDTO> castandcrew;
	private String description;
	private List<VideoDescription> videoDescriptions; // Matching VideoDescriptions
	public VideoScreenDTO() {
		super();
		// TODO Auto-generated constructor stub
	}
	
	
	public VideoScreenDTO(long videoid, String videotitle, String duration, boolean videoAccessType,
			List<String> category, List<CastAndCrewModalDTO> castandcrew, String description,
			List<VideoDescription> videoDescriptions) {
		super();
		this.videoid = videoid;
		this.videotitle = videotitle;
		this.duration = duration;
		this.videoAccessType = videoAccessType;
		this.category = category;
		this.castandcrew = castandcrew;
		this.description = description;
		this.videoDescriptions = videoDescriptions;
	}


	public long getVideoid() {
		return videoid;
	}
	public void setVideoid(long videoid) {
		this.videoid = videoid;
	}
	public String getVideotitle() {
		return videotitle;
	}
	public void setVideotitle(String videotitle) {
		this.videotitle = videotitle;
	}
	public List<String> getCategory() {
		return category;
	}
	public void setCategory(List<String> category) {
		this.category = category;
	}
	public List<CastAndCrewModalDTO> getCastandcrew() {
		return castandcrew;
	}
	public void setCastandcrew(List<CastAndCrewModalDTO> castandcrew) {
		this.castandcrew = castandcrew;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public List<VideoDescription> getVideoDescriptions() {
		return videoDescriptions;
	}
	public void setVideoDescriptions(List<VideoDescription> videoDescriptions) {
		this.videoDescriptions = videoDescriptions;
	}
	public String getDuration() {
		return duration;
	}
	public void setDuration(String duration) {
		this.duration = duration;
	}
	public boolean isVideoAccessType() {
		return videoAccessType;
	}
	public void setVideoAccessType(boolean videoAccessType) {
		this.videoAccessType = videoAccessType;
	}
	
	
}
