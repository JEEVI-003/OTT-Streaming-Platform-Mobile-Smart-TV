package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table
public class AddUser {
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;
	
	@Column(name="username")
	private String Username;
	
	@Column(unique = true)
	private String email;
	
	@Column(name="role")
	private String role;
	
	@Column(name="mobnum")
	private  String mobnum;
	
	@Column(name="compname")
	private String compname;
	
	@Column(name="pincode")
	private String pincode;
	
	@Column(name="country")
	private String country;
	
	@Column(name="password")
	private String password;
	
	@Column(name="confirm_Password")
	private String confirmPassword;
	
	@Column(name="address")
	private String address;

	public AddUser() {
		super();
	}

	public AddUser(long id, String username, String email, String role, String mobnum, String compname, String pincode,
			String country, String password, String confirmPassword, String address) {
		super();
		this.id = id;
		Username = username;
		this.email = email;
		this.role = role;
		this.mobnum = mobnum;
		this.compname = compname;
		this.pincode = pincode;
		this.country = country;
		this.password = password;
		this.confirmPassword = confirmPassword;
		this.address = address;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getUsername() {
		return Username;
	}

	public void setUsername(String username) {
		Username = username;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getMobnum() {
		return mobnum;
	}

	public void setMobnum(String mobnum) {
		this.mobnum = mobnum;
	}

	public String getCompname() {
		return compname;
	}

	public void setCompname(String compname) {
		this.compname = compname;
	}

	public String getPincode() {
		return pincode;
	}

	public void setPincode(String pincode) {
		this.pincode = pincode;
	}

	public String getCountry() {
		return country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getConfirmPassword() {
		return confirmPassword;
	}

	public void setConfirmPassword(String confirmPassword) {
		this.confirmPassword = confirmPassword;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}	
}
