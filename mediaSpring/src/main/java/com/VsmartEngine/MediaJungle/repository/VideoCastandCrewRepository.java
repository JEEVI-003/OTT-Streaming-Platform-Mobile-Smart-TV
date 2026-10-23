package com.VsmartEngine.MediaJungle.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.VideoCastAndCrew;

@Repository
public interface VideoCastandCrewRepository extends JpaRepository<VideoCastAndCrew,Long>{
	
	 List<VideoCastAndCrew> findByVideoDescriptionId(Long videoId);

}
