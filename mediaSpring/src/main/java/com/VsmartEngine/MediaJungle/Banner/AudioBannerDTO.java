package com.VsmartEngine.MediaJungle.Banner;

import java.util.List;

public class AudioBannerDTO {
	
	private String moviename;
	private long id;
	private String audio_title;
	private boolean like;
	private String audio_file_name;
    private String audio_Duration;
	public AudioBannerDTO() {
		super();
		// TODO Auto-generated constructor stub
	}
	public AudioBannerDTO(String moviename, long id, String audio_title, boolean like, String audio_file_name,
			String audio_Duration) {
		super();
		this.moviename = moviename;
		this.id = id;
		this.audio_title = audio_title;
		this.like = like;
		this.audio_file_name = audio_file_name;
		this.audio_Duration = audio_Duration;
	}
	public String getMoviename() {
		return moviename;
	}
	public void setMoviename(String moviename) {
		this.moviename = moviename;
	}
	public long getId() {
		return id;
	}
	public void setId(long id) {
		this.id = id;
	}
	public String getAudio_title() {
		return audio_title;
	}
	public void setAudio_title(String audio_title) {
		this.audio_title = audio_title;
	}
	public boolean isLike() {
		return like;
	}
	public void setLike(boolean like) {
		this.like = like;
	}
	public String getAudio_file_name() {
		return audio_file_name;
	}
	public void setAudio_file_name(String audio_file_name) {
		this.audio_file_name = audio_file_name;
	}
	public String getAudio_Duration() {
		return audio_Duration;
	}
	public void setAudio_Duration(String audio_Duration) {
		this.audio_Duration = audio_Duration;
	}
    
    

}
