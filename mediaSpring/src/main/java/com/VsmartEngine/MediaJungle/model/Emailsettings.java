package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
@Entity
@Table(name="email_settings")
public class Emailsettings {
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;
	
	@Column (name="mail_driver")
	private String mail_driver;
	
	@Column (name="mail_usernam")
	private String mail_username;
	
	@Column (name="mail_password")
	private String mail_password;
	
	@Column (name="mail_host")
	private String mail_host;
	
	@Column (name="mail_port")
	private String mail_port;
	
	@Column (name="mail_encryption")
	private String mail_encryption;

	public Emailsettings(long id, String mail_driver, String mail_username, String mail_password, String mail_host,
			String mail_port, String mail_encryption) {
		super();
		this.id = id;
		this.mail_driver = mail_driver;
		this.mail_username = mail_username;
		this.mail_password = mail_password;
		this.mail_host = mail_host;
		this.mail_port = mail_port;
		this.mail_encryption = mail_encryption;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getMail_driver() {
		return mail_driver;
	}

	public void setMail_driver(String mail_driver) {
		this.mail_driver = mail_driver;
	}

	public String getMail_username() {
		return mail_username;
	}

	public void setMail_username(String mail_username) {
		this.mail_username = mail_username;
	}

	public String getMail_password() {
		return mail_password;
	}

	public void setMail_password(String mail_password) {
		this.mail_password = mail_password;
	}

	public String getMail_host() {
		return mail_host;
	}

	public void setMail_host(String mail_host) {
		this.mail_host = mail_host;
	}

	public String getMail_port() {
		return mail_port;
	}

	public void setMail_port(String mail_port) {
		this.mail_port = mail_port;
	}

	public String getMail_encryption() {
		return mail_encryption;
	}

	public void setMail_encryption(String mail_encryption) {
		this.mail_encryption = mail_encryption;
	}

}
