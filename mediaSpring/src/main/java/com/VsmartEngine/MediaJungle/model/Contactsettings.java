package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;


@Entity
@Table(name="contact_setting")
public class Contactsettings {

	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;

    @Column(name = "contact_email")
    private String contact_email;
    
    @Column(name = "contact_mobile")
    private String contact_mobile;

    @Column(name = "contact_address")
    private String contact_address;
    
    @Column(name = "copyright_content")
    private String copyright_content;

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getContact_email() {
		return contact_email;
	}

	public void setContact_email(String contact_email) {
		this.contact_email = contact_email;
	}


	public String getContact_mobile() {
		return contact_mobile;
	}

	public void setContact_mobile(String contact_mobile) {
		this.contact_mobile = contact_mobile;
	}

	public String getContact_address() {
		return contact_address;
	}

	public void setContact_address(String contact_address) {
		this.contact_address = contact_address;
	}

	public String getCopyright_content() {
		return copyright_content;
	}

	public void setCopyright_content(String copyright_content) {
		this.copyright_content = copyright_content;
	}

	public Contactsettings(long id, String contact_email, String contact_mobile, String contact_address,
			String copyright_content) {
		super();
		this.id = id;
		this.contact_email = contact_email;
		this.contact_mobile = contact_mobile;
		this.contact_address = contact_address;
		this.copyright_content = copyright_content;
	}

	public Contactsettings() {
		super();
		// TODO Auto-generated constructor stub
	}

    
    
}
