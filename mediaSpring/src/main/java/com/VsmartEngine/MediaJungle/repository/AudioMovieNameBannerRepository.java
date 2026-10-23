package com.VsmartEngine.MediaJungle.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.AudioMovieNameBanner;
import com.VsmartEngine.MediaJungle.video.VideoImage;

@Repository
public interface AudioMovieNameBannerRepository extends JpaRepository<AudioMovieNameBanner,Long>{
	
	  Optional<AudioMovieNameBanner> findByMovieId(long movieId);
	  
	// Method to check if a movieId exists
	    @Query("SELECT b.movieId FROM AudioMovieNameBanner b WHERE b.movieId = :movieId")
	    Long findMovieIdIfExists(@Param("movieId") Long movieId);
	    
	    @Query("SELECT u FROM  AudioMovieNameBanner u WHERE u.movieId = ?1")
		Optional<AudioMovieNameBanner> findMovieById(long movieId);
}

