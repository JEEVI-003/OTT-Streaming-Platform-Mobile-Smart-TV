package com.VsmartEngine.MediaJungle.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.VsmartEngine.MediaJungle.model.FooterSettings;

public interface FooterSettingsRepository extends JpaRepository<FooterSettings, Long> {
	
	@Query("SELECT fs FROM FooterSettings fs")
	FooterSettings findFirstFooterSettings();

}
