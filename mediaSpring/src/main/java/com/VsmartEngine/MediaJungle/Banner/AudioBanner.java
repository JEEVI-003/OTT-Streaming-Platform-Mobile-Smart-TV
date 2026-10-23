package com.VsmartEngine.MediaJungle.Banner;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table
public class AudioBanner {
	
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    private long movienameID;
	public AudioBanner() {
		super();
		// TODO Auto-generated constructor stub
	}
	public AudioBanner(long id, long movienameID) {
		super();
		this.id = id;
		this.movienameID = movienameID;
	}
	public long getId() {
		return id;
	}
	public void setId(long id) {
		this.id = id;
	}
	public long getMovienameID() {
		return movienameID;
	}
	public void setMovienameID(long movienameID) {
		this.movienameID = movienameID;
	}
    
    

}
