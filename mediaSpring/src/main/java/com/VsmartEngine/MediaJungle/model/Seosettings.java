package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;


@Entity
@Table(name="seo_setting")
public class Seosettings {
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;

    @Column(name = "meta_title")
    private String meta_title;
    
    @Column(name = "meta_author")
    private String meta_author;

    @Column(name = "meta_keywords")
    private String meta_keywords;
    
    @Column(name = "meta_description")
    private String meta_description;

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getMeta_title() {
		return meta_title;
	}

	public void setMeta_title(String meta_title) {
		this.meta_title = meta_title;
	}

	public String getMeta_author() {
		return meta_author;
	}

	public void setMeta_author(String meta_author) {
		this.meta_author = meta_author;
	}

	public String getMeta_keywords() {
		return meta_keywords;
	}

	public void setMeta_keywords(String meta_keywords) {
		this.meta_keywords = meta_keywords;
	}

	public String getMeta_description() {
		return meta_description;
	}

	public void setMeta_description(String meta_description) {
		this.meta_description = meta_description;
	}

	public Seosettings(long id, String meta_title, String meta_author, String meta_keywords, String meta_description) {
		super();
		this.id = id;
		this.meta_title = meta_title;
		this.meta_author = meta_author;
		this.meta_keywords = meta_keywords;
		this.meta_description = meta_description;
	}
    
    

}
