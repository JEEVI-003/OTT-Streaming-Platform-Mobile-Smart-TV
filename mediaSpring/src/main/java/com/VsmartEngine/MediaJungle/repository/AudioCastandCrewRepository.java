package com.VsmartEngine.MediaJungle.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.AudioCastAndCrew;

@Repository
public interface AudioCastandCrewRepository extends JpaRepository<AudioCastAndCrew,Long>{
	
////	 List<AudioCastAndCrew> findByVideoDescriptionId(Long videoId);
////	 @Query("SELECT castandcrew_id  FROM AudioCastAndCrew a WHERE audio_id.id = :audio_id")
////	   Optional<String> findByCastandCrew_Id(@Param("audio_id") long audio_id);
//	
//	  @Query("SELECT castandcrew_id  FROM AudioCastAndCrew a WHERE audio_id = :audioId")
//	    List<CastandCrewDTO> findByAudio_Id(@Param("audioId") long audioId);


}
