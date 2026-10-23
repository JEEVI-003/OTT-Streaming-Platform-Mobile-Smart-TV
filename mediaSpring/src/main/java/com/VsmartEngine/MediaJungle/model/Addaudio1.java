package com.VsmartEngine.MediaJungle.model;

import org.springframework.web.multipart.MultipartFile;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Lob;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

@Entity
@Table
public class Addaudio1 {
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;
	
	@ManyToOne
	@JoinColumn(name = "category_id")
	private AddNewCategories category;
	
	private String songname ;
	
	private String musicdirector;
	
	@Transient
	private MultipartFile audioFile;
	
	private String  fileName;
	
	@Lob
	@Column(name="thumbnail" ,length=1000000)
	private byte[] thumbnail;
	
	private boolean paid;

//	@ManyToMany(mappedBy = "favoriteAudios")
//	@JsonBackReference
//	private Set<UserRegister> users = new HashSet<>();;
	
	public Addaudio1() {
		super();
		// TODO Auto-generated constructor stub
	}

	
	


	public Addaudio1(long id, AddNewCategories category, String songname, String musicdirector, MultipartFile audioFile,
		String fileName, byte[] thumbnail, boolean paid) {
	super();
	this.id = id;
	this.category = category;
	this.songname = songname;
	this.musicdirector = musicdirector;
	this.audioFile = audioFile;
	this.fileName = fileName;
	this.thumbnail = thumbnail;
	this.paid = paid;
}





	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public AddNewCategories getCategory() {
		return category;
	}

	public void setCategory(AddNewCategories category) {
		this.category = category;
	}

	public String getSongname() {
		return songname;
	}

	public void setSongname(String songname) {
		this.songname = songname;
	}

	public String getMusicdirector() {
		return musicdirector;
	}

	public void setMusicdirector(String musicdirector) {
		this.musicdirector = musicdirector;
	}

	public MultipartFile getAudioFile() {
		return audioFile;
	}

	public void setAudioFile(MultipartFile audioFile) {
		this.audioFile = audioFile;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public byte[] getThumbnail() {
		return thumbnail;
	}

	public void setThumbnail(byte[] thumbnail) {
		this.thumbnail = thumbnail;
	}

	public boolean isPaid() {
		return paid;
	}

	public void setPaid(boolean paid) {
		this.paid = paid;
	}


	

	

	
}	