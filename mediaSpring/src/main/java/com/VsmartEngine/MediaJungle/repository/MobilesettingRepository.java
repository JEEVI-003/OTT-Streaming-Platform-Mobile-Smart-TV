package com.VsmartEngine.MediaJungle.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.Mobilesettings;

@Repository
public interface MobilesettingRepository extends JpaRepository<Mobilesettings, Long> {

}


