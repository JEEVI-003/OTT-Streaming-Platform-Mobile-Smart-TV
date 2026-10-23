package com.VsmartEngine.MediaJungle.userregister;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;

import com.VsmartEngine.MediaJungle.model.PaymentUser;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Lob;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table
public class UserRegister {
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;
	
	@Column(name="username")
	private String username;
	
	@Column(unique = true)
	private String email;
	
	@Column(name="password")
	private String password;
	
	@Column(name="mobnum")
	private  String mobnum;
	
	@Column(name="date")
	private LocalDate date ;
	
	@Lob
	@Column(name="profile" ,length=1000000)
	private byte[] profile;
	
	@ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "user_favorite_audios", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "audio_id")
    private Set<Long> favoriteAudioIds = new HashSet<>();
	
	@ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "user_favorite_videos", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "video_id")
    private Set<Long> favoriteVideosIds = new HashSet<>();
	
	@ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "watch_later_videos", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "video_id")
    private Set<Long> watchlaterIds = new HashSet<>();
	
	@OneToOne
	@JoinColumn(name = "Payment_details")
	private PaymentUser paymentId;
	
	public UserRegister() {
		super();
	}

	public UserRegister(long id, String username, String email, String password,
			String mobnum, LocalDate date, byte[] profile, Set<Long> favoriteAudioIds,
			Set<Long> favoriteVideosIds, Set<Long> watchlaterIds, PaymentUser paymentId) {
		super();
		this.id = id;
		this.username = username;
		this.email = email;
		this.password = password;
		this.mobnum = mobnum;
		this.date = date;
		this.profile = profile;
		this.favoriteAudioIds = favoriteAudioIds;
		this.favoriteVideosIds = favoriteVideosIds;
		this.watchlaterIds = watchlaterIds;
		this.paymentId = paymentId;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getMobnum() {
		return mobnum;
	}

	public void setMobnum(String mobnum) {
		this.mobnum = mobnum;
	}

	public LocalDate getDate() {
		return date;
	}

	public void setDate(LocalDate date) {
		this.date = date;
	}

	public byte[] getProfile() {
		return profile;
	}

	public void setProfile(byte[] profile) {
		this.profile = profile;
	}

	public Set<Long> getFavoriteAudioIds() {
		return favoriteAudioIds;
	}

	public void setFavoriteAudioIds(Set<Long> favoriteAudioIds) {
		this.favoriteAudioIds = favoriteAudioIds;
	}

	public Set<Long> getFavoriteVideosIds() {
		return favoriteVideosIds;
	}

	public void setFavoriteVideosIds(Set<Long> favoriteVideosIds) {
		this.favoriteVideosIds = favoriteVideosIds;
	}

	public PaymentUser getPaymentId() {
		return paymentId;
	}

	public void setPaymentId(PaymentUser paymentId) {
		this.paymentId = paymentId;
	}

	public Set<Long> getWatchlaterIds() {
		return watchlaterIds;
	}

	public void setWatchlaterIds(Set<Long> watchlaterIds) {
		this.watchlaterIds = watchlaterIds;
	}
}
