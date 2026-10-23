package com.VsmartEngine.MediaJungle.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.Audiodescription;
import com.VsmartEngine.MediaJungle.video.VideoImage;

@Repository
public interface AddAudiodescription extends JpaRepository<Audiodescription, Long>{
	
	@Query("SELECT u FROM Audiodescription u WHERE u.movie_name = ?1")
	List<Audiodescription> findMovie_nameById(long id);

}