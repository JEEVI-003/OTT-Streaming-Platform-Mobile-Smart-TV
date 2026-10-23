package com.VsmartEngine.MediaJungle.model;

import java.util.List;

public class AudioContainersDetailsDTO {
	private String category_name;
	private List<Audiodescription> Audiolist;

	public String getCategory_name() {
		return category_name;
	}

	public void setCategory_name(String category_name) {
		this.category_name = category_name;
	}

	public List<Audiodescription> getAudiolist() {
		return Audiolist;
	}

	public void setAudiolist(List<Audiodescription> audiolist) {
		Audiolist = audiolist;
	}

	@Override
	public String toString() {
		return "AudioContainersDetailsDTO [category_name=" + category_name + ", Audiolist=" + Audiolist + "]";
	}

	public AudioContainersDetailsDTO(String category_name, List<Audiodescription> audiolist) {
		super();
		this.category_name = category_name;
		Audiolist = audiolist;
	}

}
