package com.VsmartEngine.MediaJungle.service;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.model.SocialSettings;
import com.VsmartEngine.MediaJungle.repository.SocialSettingsRepository;

@Service
public class SocialSettingsService {

    @Autowired
    private SocialSettingsRepository repository;
    

    public SocialSettings saveSocialSettings(SocialSettings settings) {
        return repository.save(settings);
    }
    public List<SocialSettings> getSocialSettings() {
        return repository.findAll();
    }
    public SocialSettings updateSocialSettings(Long id, SocialSettings settings) {
        SocialSettings existingSettings = repository.findById(id).orElse(null);
        
        if (existingSettings != null) {
            existingSettings.setFbUrl(settings.getFbUrl());
            existingSettings.setLinkedinUrl(settings.getLinkedinUrl());
            existingSettings.setXUrl(settings.getXUrl());
            existingSettings.setYoutubeUrl(settings.getYoutubeUrl());
            return repository.save(existingSettings);
        }
        return null;
    }

    // Get the first social setting
    public SocialSettings getFirstSetting() {
        List<SocialSettings> settings = repository.findAll();
        return settings.isEmpty() ? null : settings.get(0);
    }
    // Update by ID
    public SocialSettings update(Long id, SocialSettings setting) {
        if (repository.existsById(id)) {
            setting.setId(id);
            return repository.save(setting);
        } else {
            return null;
        }
    }
    // Save or update a social setting
    public SocialSettings saveOrUpdate(SocialSettings setting) {
        if (setting.getId() != null) {
            Optional<SocialSettings> existingSetting = repository.findById(setting.getId());
            if (existingSetting.isPresent()) {
                // Update the existing setting
                SocialSettings updatedSetting = existingSetting.get();
                updatedSetting.setFbUrl(setting.getFbUrl());
                updatedSetting.setXUrl(setting.getXUrl());
                updatedSetting.setLinkedinUrl(setting.getLinkedinUrl());
                updatedSetting.setYoutubeUrl(setting.getYoutubeUrl());
                return repository.save(updatedSetting);
            }
        }
        // Create a new setting
        return repository.save(setting);
    }
}
