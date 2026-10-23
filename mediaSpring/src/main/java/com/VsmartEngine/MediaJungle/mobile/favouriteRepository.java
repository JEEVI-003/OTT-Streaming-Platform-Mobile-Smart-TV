package com.VsmartEngine.MediaJungle.mobile;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface favouriteRepository extends JpaRepository<favourite,Long>{
	
	    Optional<favourite> findByUserIdAndAudioId(Long userId, Long audioId);
	

}
