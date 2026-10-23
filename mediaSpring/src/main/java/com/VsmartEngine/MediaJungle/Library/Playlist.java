package com.VsmartEngine.MediaJungle.Library;

import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.JoinColumn;

@Entity
@Table
public class Playlist {
	
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
	
	private Long userId;

    private String title;
    private String description;
    
    @ElementCollection
    @CollectionTable(name = "playlist_audio_ids", joinColumns = @JoinColumn(name = "playlist_id"))
    @Column(name = "audio_id")
    private List<Long> audioIds = new ArrayList<>();

	public Playlist() {
		super();
		// TODO Auto-generated constructor stub
	}

	public Playlist(Long id, Long userId, String title, String description, List<Long> audioIds) {
		super();
		this.id = id;
		this.userId = userId;
		this.title = title;
		this.description = description;
		this.audioIds = audioIds;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
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

	public List<Long> getAudioIds() {
		return audioIds;
	}

	public void setAudioIds(List<Long> audioIds) {
		this.audioIds = audioIds;
	}

	public Long getUserId() {
		return userId;
	}

	public void setUserId(Long userId) {
		this.userId = userId;
	}
    
    

}
