package com.VsmartEngine.MediaJungle.model;

import java.util.Arrays;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;

@Entity
@Table
public class Audioimages {

	@Id
	private long audioId;


	@Lob
	@Column(name="Bannerthumbnail" ,length=1000000)
	private byte[] bannerthumbnail;
	
	@Lob
	@Column(name="Audio_thumbnail" ,length=1000000)
	private byte[] audio_thumbnail;


	

	public byte[] getBannerthumbnail() {
		return bannerthumbnail;
	}

	public void setBannerthumbnail(byte[] bannerthumbnail) {
		this.bannerthumbnail = bannerthumbnail;
	}

	public byte[] getAudio_thumbnail() {
		return audio_thumbnail;
	}

	public void setAudio_thumbnail(byte[] audio_thumbnail) {
		this.audio_thumbnail = audio_thumbnail;
	}

	

	public long getAudioId() {
		return audioId;
	}

	public void setAudioId(long audioId) {
		this.audioId = audioId;
	}

	@Override
	public String toString() {
		return "Audioimages [id=" + ", audio_id=" + audioId + ", bannerthumbnail="
				+ Arrays.toString(bannerthumbnail) + ", audio_thumbnail=" + Arrays.toString(audio_thumbnail) + "]";
	}

	
		
	

	
}
