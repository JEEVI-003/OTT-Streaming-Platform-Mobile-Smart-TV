package com.VsmartEngine.MediaJungle.controller;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.VsmartEngine.MediaJungle.Container.VideoContainerController;
import com.VsmartEngine.MediaJungle.model.SocialSettings;
import com.VsmartEngine.MediaJungle.repository.SocialSettingsRepository;
import com.VsmartEngine.MediaJungle.service.SocialSettingsService;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/v2/social-settings")
public class SocialSettingsController {

    @Autowired
    private SocialSettingsService service;

    @Autowired
    private SocialSettingsRepository repository;
    private static final Logger logger = LoggerFactory.getLogger(SocialSettingsController.class);

    // Get all social settings
    @GetMapping
    public List<SocialSettings> getAllSettings() {
        return service.getSocialSettings();
    }

    // Get the first social setting
    @GetMapping("/first")
    public ResponseEntity<SocialSettings> getFirstSetting() {
        SocialSettings setting = service.getFirstSetting();
        if (setting != null) {
            return ResponseEntity.ok(setting);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Save or update a social setting
    @PostMapping
    public SocialSettings createOrUpdateSetting(@RequestBody SocialSettings setting) {
        return service.saveOrUpdate(setting);
    }
    @PutMapping("/{id}")
    public ResponseEntity<SocialSettings> updateSetting(@PathVariable Long id, @RequestBody SocialSettings setting) {
        try {
            if (repository.existsById(id)) {
                setting.setId(id);
                SocialSettings updatedSetting = repository.save(setting);
                return ResponseEntity.ok(updatedSetting);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            e.printStackTrace(); // Print stack trace for debugging
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

}
