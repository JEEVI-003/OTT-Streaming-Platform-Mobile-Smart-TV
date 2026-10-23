package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
@Entity
@Table(name="companysiteurl")
public class Companysiteurl {
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;
	
	@Column (name ="facebooklink")
	private String facebook_link;
	
	@Column (name ="linkedin_link")
	private String linkedin_link;
	
	@Column (name ="twitter_link")
	private String twitter_link;
	
	@Column (name ="google_plus_link")
	private String google_plus_link;
	
	@Column (name ="pinterest_link")
	private String pinterest_link;

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getFacebook_link() {
		return facebook_link;
	}

	public void setFacebook_link(String facebook_link) {
		this.facebook_link = facebook_link;
	}

	public String getLinkedin_link() {
		return linkedin_link;
	}

	public void setLinkedin_link(String linkedin_link) {
		this.linkedin_link = linkedin_link;
	}

	public String getTwitter_link() {
		return twitter_link;
	}

	public void setTwitter_link(String twitter_link) {
		this.twitter_link = twitter_link;
	}

	public String getGoogle_plus_link() {
		return google_plus_link;
	}

	public void setGoogle_plus_link(String google_plus_link) {
		this.google_plus_link = google_plus_link;
	}

	public String getPinterest_link() {
		return pinterest_link;
	}

	public void setPinterest_link(String pinterest_link) {
		this.pinterest_link = pinterest_link;
	}

	public Companysiteurl(long id, String facebook_link, String linkedin_link, String twitter_link,
			String google_plus_link, String pinterest_link) {
		super();
		this.id = id;
		this.facebook_link = facebook_link;
		this.linkedin_link = linkedin_link;
		this.twitter_link = twitter_link;
		this.google_plus_link = google_plus_link;
		this.pinterest_link = pinterest_link;
	}
	
	
}
