package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;

@Entity
@Table
public class AudioMovieNameBanner {
	
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Column(name = "movie_id", unique = true)
    private long movieId;

    @Lob
    @Column(name = "banner_image",length=1000000)
    private byte[] bannerImage;

	public AudioMovieNameBanner() {
		super();
		// TODO Auto-generated constructor stub
	}

	public AudioMovieNameBanner(long id, long movieId, byte[] bannerImage) {
		super();
		this.id = id;
		this.movieId = movieId;
		this.bannerImage = bannerImage;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public long getMovieId() {
		return movieId;
	}

	public void setMovieId(long movieId) {
		this.movieId = movieId;
	}

	public byte[] getBannerImage() {
		return bannerImage;
	}

	public void setBannerImage(byte[] bannerImage) {
		this.bannerImage = bannerImage;
	}
}
