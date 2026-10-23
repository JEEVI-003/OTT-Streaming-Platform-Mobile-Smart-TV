package com.VsmartEngine.MediaJungle.repository;



import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.Audioimages;


@Repository
public interface Audioimage extends JpaRepository<Audioimages,Long>{
	
//	 @Query("SELECT a.bannerthumbnail  FROM Audioimages a WHERE a.audio_id = :audioId")
//	 Optional<Audioimages> findBannerThumbnailByAudioId(@Param("audioId")long audioId);
//	
//	 
//	 @Query("SELECT a.audio_thumbnail FROM Audioimages a WHERE a.audio_id = :audioId")
//	 Optional<Audioimages> findThumbnailByAudioId(long audioId);

	Optional<Audioimages> findByAudioId(Long audioid);
	
	 @Query("SELECT bannerthumbnail  FROM Audioimages a WHERE audioId = :audioId")
	    Optional<byte[]> findBannerByaudio_Id(@Param("audioId") long audioId);

}


