package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name="video_settings")
public class Videosettings {
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;
	@Column(name = "socket_url")
	private String socket_Url;
	
	@Column(name = "streaming_url")
	private String streaming_URL;
	
	
    
    public Videosettings(long id, String socket_Url, String streaming_URL) {
		super();
		this.id = id;
		this.socket_Url = socket_Url;
		this.streaming_URL = streaming_URL;
	}

	public String getSocket_Url() {
		return socket_Url;
	}

	public void setSocket_Url(String socket_Url) {
		this.socket_Url = socket_Url;
	}

	public String getStreaming_URL() {
		return streaming_URL;
	}

	public void setStreaming_URL(String streaming_URL) {
		this.streaming_URL = streaming_URL;
	}
	
	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}


	

}
