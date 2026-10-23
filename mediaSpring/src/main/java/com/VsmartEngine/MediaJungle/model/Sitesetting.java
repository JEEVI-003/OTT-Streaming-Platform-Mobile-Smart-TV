package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;

@Entity
@Table(name="site_setting")
public class Sitesetting {
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;

    @Column(name = "sitename")
    private String sitename;
    
    @Column(name = "appurl")
    private String appurl;

    @Column(name = "tagName")
    private String tagName;
    
	@Lob
	@Column(name="icon" ,length=1000000)
    private byte[] icon;
    
	@Lob
	@Column(name="logo" ,length=1000000)
    private byte[] logo;

	public Sitesetting() {
		super();
		// TODO Auto-generated constructor stub
	}

	public Sitesetting(long id, String sitename, String appurl, String tagName, byte[] icon, byte[] logo) {
		super();
		this.id = id;
		this.sitename = sitename;
		this.appurl = appurl;
		this.tagName = tagName;
		this.icon = icon;
		this.logo = logo;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getSitename() {
		return sitename;
	}

	public void setSitename(String sitename) {
		this.sitename = sitename;
	}

	public String getAppurl() {
		return appurl;
	}

	public void setAppurl(String appurl) {
		this.appurl = appurl;
	}

	public String getTagName() {
		return tagName;
	}

	public void setTagName(String tagName) {
		this.tagName = tagName;
	}

	public byte[] getIcon() {
		return icon;
	}

	public void setIcon(byte[] icon) {
		this.icon = icon;
	}

	public byte[] getLogo() {
		return logo;
	}

	public void setLogo(byte[] logo) {
		this.logo = logo;
	} 
	
	



    
   
}
	
