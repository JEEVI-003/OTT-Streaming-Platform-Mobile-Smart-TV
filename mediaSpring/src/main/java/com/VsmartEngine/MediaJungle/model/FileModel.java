package com.VsmartEngine.MediaJungle.model;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class FileModel {
	
	
	private String videoFileName ;
	private String videotrailerfilename;
//	private Double duration ;
	public String getVideoFileName() {
		return videoFileName;
	}
	public void setVideoFileName(String videoFileName) {
		this.videoFileName = videoFileName;
		
	}
	

	public String getVideotrailerfilename() {
		return videotrailerfilename;
	}
	public void setVideotrailerfilename(String videotrailerfilename) {
		this.videotrailerfilename = videotrailerfilename;
	}
	public FileModel(String videoFileName,String videotrailerfilename) {
		super();
		this.videoFileName = videoFileName;
		this.videotrailerfilename = videotrailerfilename;
	}

	public FileModel() {
		super();
		// TODO Auto-generated constructor stub
	}
//	public Double getDuration() {
//		return duration;
//	}
//	public void setDuration(Double duration) {
//		this.duration = duration;
//	}

}
