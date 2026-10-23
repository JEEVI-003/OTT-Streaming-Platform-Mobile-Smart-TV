package com.VsmartEngine.MediaJungle.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.Sitesetting;

@Repository
public interface siteSettingRepository extends JpaRepository<Sitesetting, Long> {

}


