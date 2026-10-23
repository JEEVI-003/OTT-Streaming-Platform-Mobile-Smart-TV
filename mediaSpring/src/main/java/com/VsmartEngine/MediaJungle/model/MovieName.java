package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table
public class MovieName {
	
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private long id;
	
	@Column(name="movie_name" )
	private String Movie_name;

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getMovie_name() {
		return Movie_name;
	}

	public void setMovie_name(String movie_name) {
		Movie_name = movie_name;
	}

	@Override
	public String toString() {
		return "MovieName [id=" + id + ", Movie_name=" + Movie_name + "]";
	}

	
	
}
