package com.VsmartEngine.MediaJungle.model;

import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table
public class AudioCastAndCrew {
	
	@Id
	private long audio_id;

	private List<Long> castandcrewlist = new ArrayList<>();
	 
	
	public long getAudio_id() {
		return audio_id;
	}

	public void setAudio_id(long audio_id) {
		this.audio_id = audio_id;
	}

	public List<Long> getCastandcrewlist() {
		return castandcrewlist;
	}

	public void setCastandcrewlist(List<Long> castandcrewlist) {
		this.castandcrewlist = castandcrewlist;
	}



	 

}
