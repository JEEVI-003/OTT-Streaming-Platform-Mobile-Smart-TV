package com.VsmartEngine.MediaJungle.userregister;

import java.time.LocalDate;

public class UserRegisterDTO {
	
	private String username;
	private LocalDate date;
	public UserRegisterDTO() {
		super();
		// TODO Auto-generated constructor stub
	}
	public UserRegisterDTO(String username, LocalDate date) {
		super();
		this.username = username;
		this.date = date;
	}
	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public LocalDate getDate() {
		return date;
	}
	public void setDate(LocalDate date) {
		this.date = date;
	}
	
	

}
