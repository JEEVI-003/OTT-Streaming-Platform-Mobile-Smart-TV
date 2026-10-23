package com.VsmartEngine.MediaJungle.File;

import jakarta.xml.bind.annotation.XmlElement;
import jakarta.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "root1")
public class Root {

	private Data data;

	@XmlElement(name = "data")
	public Data getData() {
		return data;
	}

	public void setData(Data data) {
		this.data = data;
	}
}

