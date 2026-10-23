package com.VsmartEngine.MediaJungle.model;

import com.fasterxml.jackson.annotation.JsonManagedReference;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;


@Entity
@Table
public class AudioTags {
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long AudioTags_id;
	
	@ManyToOne
	 @JoinColumn(name = "audioid")
	 @JsonManagedReference
	 private Audiodescription Audioid;

	 @ManyToOne
	 @JoinColumn(name = "tagid")
	 @JsonManagedReference
	private Tag Tagid;

	public long getAudioTags_id() {
		return AudioTags_id;
	}

	public void setAudioTags_id(long audioTags_id) {
		AudioTags_id = audioTags_id;
	}

	public Audiodescription getAudioid() {
		return Audioid;
	}

	public void setAudioid(Audiodescription audioid) {
		Audioid = audioid;
	}

	public Tag getTagid() {
		return Tagid;
	}

	public void setTagid(Tag tagid) {
		Tagid = tagid;
	}

	@Override
	public String toString() {
		return "AudioTags [AudioTags_id=" + AudioTags_id + ", Audioid=" + Audioid + ", Tagid=" + Tagid + "]";
	}

	
	
	

}
