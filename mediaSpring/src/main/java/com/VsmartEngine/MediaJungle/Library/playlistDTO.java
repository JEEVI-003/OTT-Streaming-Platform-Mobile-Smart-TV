package com.VsmartEngine.MediaJungle.Library;

import java.util.List;

public class playlistDTO {
	
	private Long userId;
	private Long playlistId;
    private String title;
    private String description;
    
    private List<LikedsongsDTO> audioDetails;

	public playlistDTO() {
		super();
		// TODO Auto-generated constructor stub
	}

	

	public playlistDTO(Long userId, Long playlistId, String title, String description,
			List<LikedsongsDTO> audioDetails) {
		super();
		this.userId = userId;
		this.playlistId = playlistId;
		this.title = title;
		this.description = description;
		this.audioDetails = audioDetails;
	}



	public Long getUserId() {
		return userId;
	}

	public void setUserId(Long userId) {
		this.userId = userId;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public List<LikedsongsDTO> getAudioDetails() {
		return audioDetails;
	}

	public void setAudioDetails(List<LikedsongsDTO> audioDetails) {
		this.audioDetails = audioDetails;
	}



	public Long getPlaylistId() {
		return playlistId;
	}



	public void setPlaylistId(Long playlistId) {
		this.playlistId = playlistId;
	}
    
    

}
