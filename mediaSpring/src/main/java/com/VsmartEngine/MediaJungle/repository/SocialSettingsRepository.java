package com.VsmartEngine.MediaJungle.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.SocialSettings;

@Repository
public interface SocialSettingsRepository extends JpaRepository<SocialSettings, Long> {
}
