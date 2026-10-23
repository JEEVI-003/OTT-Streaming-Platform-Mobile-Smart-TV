package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table
public class MailSetting {
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;
	
	private String mailhostname;
	private int mailportname;
	private String emailid;
	private String password;
	public MailSetting() {
		super();
		// TODO Auto-generated constructor stub
	}
	public MailSetting(long id, String mailhostname, int mailportname, String emailid, String password) {
		super();
		this.id = id;
		this.mailhostname = mailhostname;
		this.mailportname = mailportname;
		this.emailid = emailid;
		this.password = password;
	}
	public long getId() {
		return id;
	}
	public void setId(long id) {
		this.id = id;
	}
	public String getMailhostname() {
		return mailhostname;
	}
	public void setMailhostname(String mailhostname) {
		this.mailhostname = mailhostname;
	}
	public int getMailportname() {
		return mailportname;
	}
	public void setMailportname(int mailportname) {
		this.mailportname = mailportname;
	}
	public String getEmailid() {
		return emailid;
	}
	public void setEmailid(String emailid) {
		this.emailid = emailid;
	}
	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}
	
	

}
