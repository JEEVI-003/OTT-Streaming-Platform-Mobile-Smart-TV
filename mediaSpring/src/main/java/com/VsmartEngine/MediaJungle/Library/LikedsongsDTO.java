package com.VsmartEngine.MediaJungle.Library;

public class LikedsongsDTO {
	
	private Long audioId;
	private String audio_title;
	public LikedsongsDTO() {
		super();
		// TODO Auto-generated constructor stub
	}
	
	public LikedsongsDTO(Long audioId, String audio_title) {
		super();
		this.audioId = audioId;
		this.audio_title = audio_title;
	}

	public Long getAudioId() {
		return audioId;
	}
	public void setAudioId(Long audioId) {
		this.audioId = audioId;
	}
	public String getAudio_title() {
		return audio_title;
	}

	public void setAudio_title(String audio_title) {
		this.audio_title = audio_title;
	}

	
	
	

}
