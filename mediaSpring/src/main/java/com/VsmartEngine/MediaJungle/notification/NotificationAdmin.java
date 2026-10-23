package com.VsmartEngine.MediaJungle.notification;

import java.time.LocalDate;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table
public class NotificationAdmin {
	
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private Long id;
    private Long adminid;
    private Long notificationId;
	private Boolean is_read;
	private Boolean Is_Active;
	private LocalDate datetonotify;
	public NotificationAdmin() {
		super();
		// TODO Auto-generated constructor stub
	}
	public NotificationAdmin(Long id, Long adminid, Long notificationId, Boolean is_read, Boolean is_Active,
			LocalDate datetonotify) {
		super();
		this.id = id;
		this.adminid = adminid;
		this.notificationId = notificationId;
		this.is_read = is_read;
		Is_Active = is_Active;
		this.datetonotify = datetonotify;
	}
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public Long getAdminid() {
		return adminid;
	}
	public void setAdminid(Long adminid) {
		this.adminid = adminid;
	}
	public Long getNotificationId() {
		return notificationId;
	}
	public void setNotificationId(Long notificationId) {
		this.notificationId = notificationId;
	}
	public Boolean getIs_read() {
		return is_read;
	}
	public void setIs_read(Boolean is_read) {
		this.is_read = is_read;
	}
	public Boolean getIs_Active() {
		return Is_Active;
	}
	public void setIs_Active(Boolean is_Active) {
		Is_Active = is_Active;
	}
	public LocalDate getDatetonotify() {
		return datetonotify;
	}
	public void setDatetonotify(LocalDate datetonotify) {
		this.datetonotify = datetonotify;
	}
	
	

}
