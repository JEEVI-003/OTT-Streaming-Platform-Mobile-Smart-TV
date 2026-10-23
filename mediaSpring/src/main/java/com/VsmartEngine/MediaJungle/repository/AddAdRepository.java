package com.VsmartEngine.MediaJungle.repository;

import com.VsmartEngine.MediaJungle.model.AddAd;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface AddAdRepository extends JpaRepository<AddAd, Long> {
	
	Optional<AddAd> findFirstByOrderByCreatedAtAsc();
}
