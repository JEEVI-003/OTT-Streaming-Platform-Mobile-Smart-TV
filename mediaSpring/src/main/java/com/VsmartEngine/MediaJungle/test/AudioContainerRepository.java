package com.VsmartEngine.MediaJungle.test;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AudioContainerRepository extends JpaRepository<AudioContainer,Long>{
	
}
