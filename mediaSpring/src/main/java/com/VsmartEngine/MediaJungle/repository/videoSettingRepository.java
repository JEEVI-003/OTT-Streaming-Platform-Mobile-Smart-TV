package com.VsmartEngine.MediaJungle.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.Videosettings;

@Repository
public interface videoSettingRepository extends JpaRepository<Videosettings, Long> {

}


