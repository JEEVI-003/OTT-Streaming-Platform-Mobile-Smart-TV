package com.VsmartEngine.MediaJungle.notification;

import java.time.LocalDate;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;

@Entity
@Table
public class NotificationDetails {
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private Long notifyId;
	
	private Long notifyTypeId;
	
	private String heading;
	
	@Column(columnDefinition = "Varchar(10000)")
	private String Description;
	
	private LocalDate CreatedDate;
	
	@Column(columnDefinition = "Varchar(100)")
	private String CreatedBy; //email
	
	private String username;
	
	private String link;
	
	private String detail;
	
    @Lob
    @Column(length=1000000)
    private byte[] notimage;
    
	private Boolean isActive;

	public NotificationDetails() {
		super();
		// TODO Auto-generated constructor stub
	}

	public NotificationDetails(Long notifyId, Long notifyTypeId, String heading, String description,
			LocalDate createdDate, String createdBy, String username, String link, String detail,byte[] notimage, Boolean isActive) {
		super();
		this.notifyId = notifyId;
		this.notifyTypeId = notifyTypeId;
		this.heading = heading;
		Description = description;
		CreatedDate = createdDate;
		CreatedBy = createdBy;
		this.username = username;
		this.link = link;
		this.detail = detail;
		this.notimage = notimage;
		this.isActive = isActive;
	}

	public Long getNotifyId() {
		return notifyId;
	}

	public void setNotifyId(Long notifyId) {
		this.notifyId = notifyId;
	}

	public Long getNotifyTypeId() {
		return notifyTypeId;
	}

	public void setNotifyTypeId(Long notifyTypeId) {
		this.notifyTypeId = notifyTypeId;
	}

	public String getHeading() {
		return heading;
	}

	public void setHeading(String heading) {
		this.heading = heading;
	}

	public String getDescription() {
		return Description;
	}

	public void setDescription(String description) {
		Description = description;
	}

	public LocalDate getCreatedDate() {
		return CreatedDate;
	}

	public void setCreatedDate(LocalDate createdDate) {
		CreatedDate = createdDate;
	}

	public String getCreatedBy() {
		return CreatedBy;
	}

	public void setCreatedBy(String createdBy) {
		CreatedBy = createdBy;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getLink() {
		return link;
	}

	public void setLink(String link) {
		this.link = link;
	}

	public byte[] getNotimage() {
		return notimage;
	}

	public void setNotimage(byte[] notimage) {
		this.notimage = notimage;
	}

	public Boolean getIsActive() {
		return isActive;
	}

	public void setIsActive(Boolean isActive) {
		this.isActive = isActive;
	}

	public String getDetail() {
		return detail;
	}

	public void setDetail(String detail) {
		this.detail = detail;
	}
	

}
