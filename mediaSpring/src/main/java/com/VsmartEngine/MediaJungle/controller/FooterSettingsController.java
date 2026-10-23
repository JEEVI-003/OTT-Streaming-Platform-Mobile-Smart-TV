package com.VsmartEngine.MediaJungle.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.VsmartEngine.MediaJungle.model.FooterSettings;
import com.VsmartEngine.MediaJungle.repository.FooterSettingsRepository;

@RestController
@RequestMapping("/api/v2/footer-settings")
@CrossOrigin(origins = "*")
public class FooterSettingsController {

    @Autowired
    private FooterSettingsRepository repository;

    private static final Logger logger = LoggerFactory.getLogger(FooterSettingsController.class);

    @PostMapping("/submit")
    public ResponseEntity<?> submitFooterSettings(
        @RequestParam("aboutUsHeaderScript") String aboutUsHeaderScript,
        @RequestParam("aboutUsBodyScript") String aboutUsBodyScript,
        @RequestParam("featureBox1HeaderScript") String featureBox1HeaderScript,
        @RequestParam("featureBox1BodyScript") String featureBox1BodyScript,
        @RequestParam("featureBox2HeaderScript") String featureBox2HeaderScript,
        @RequestParam("featureBox2BodyScript") String featureBox2BodyScript,
        // FIX: required = false — image is optional; don't crash when user doesn't upload one
        @RequestParam(value = "aboutUsImage", required = false) MultipartFile aboutUsImage,
        @RequestParam("contactUsEmail") String contactUsEmail,
        @RequestParam("contactUsBodyScript") String contactUsBodyScript,
        @RequestParam("callUsPhoneNumber") String callUsPhoneNumber,
        @RequestParam("callUsBodyScript") String callUsBodyScript,
        @RequestParam("locationMapUrl") String locationMapUrl,
        @RequestParam("locationAddress") String locationAddress,
        // FIX: required = false — same reason
        @RequestParam(value = "contactUsImage", required = false) MultipartFile contactUsImage,
        @RequestParam("appUrlPlaystore") String appUrlPlaystore,
        @RequestParam("appUrlAppStore") String appUrlAppStore,
        @RequestParam("copyrightInfo") String copyrightInfo
    ) {
        try {
            FooterSettings footerSettings = new FooterSettings();
            footerSettings.setAboutUsHeaderScript(aboutUsHeaderScript);
            footerSettings.setAboutUsBodyScript(aboutUsBodyScript);
            footerSettings.setFeatureBox1HeaderScript(featureBox1HeaderScript);
            footerSettings.setFeatureBox1BodyScript(featureBox1BodyScript);
            footerSettings.setFeatureBox2HeaderScript(featureBox2HeaderScript);
            footerSettings.setFeatureBox2BodyScript(featureBox2BodyScript);
            footerSettings.setAboutUsImage(extractImageBytes(aboutUsImage));
            footerSettings.setContactUsEmail(contactUsEmail);
            footerSettings.setContactUsBodyScript(contactUsBodyScript);
            footerSettings.setCallUsPhoneNumber(callUsPhoneNumber);
            footerSettings.setCallUsBodyScript(callUsBodyScript);
            footerSettings.setLocationMapUrl(locationMapUrl);
            footerSettings.setLocationAddress(locationAddress);
            footerSettings.setContactUsImage(extractImageBytes(contactUsImage));
            footerSettings.setAppUrlPlaystore(appUrlPlaystore);
            footerSettings.setAppUrlAppStore(appUrlAppStore);
            footerSettings.setCopyrightInfo(copyrightInfo);

            repository.save(footerSettings);

            return ResponseEntity.ok("Form submitted successfully!");
        } catch (Exception e) {
            logger.error("Error submitting footer settings", e);
            return ResponseEntity.status(500).body("Error submitting the form: " + e.getMessage());
        }
    }

    @PostMapping("/update")
    public ResponseEntity<?> updateFooterSettings(
        @RequestParam("id") Long id,
        @RequestParam("aboutUsHeaderScript") String aboutUsHeaderScript,
        @RequestParam("aboutUsBodyScript") String aboutUsBodyScript,
        @RequestParam("featureBox1HeaderScript") String featureBox1HeaderScript,
        @RequestParam("featureBox1BodyScript") String featureBox1BodyScript,
        @RequestParam("featureBox2HeaderScript") String featureBox2HeaderScript,
        @RequestParam("featureBox2BodyScript") String featureBox2BodyScript,
        @RequestParam(value = "aboutUsImage", required = false) MultipartFile aboutUsImage,
        @RequestParam("contactUsEmail") String contactUsEmail,
        @RequestParam("contactUsBodyScript") String contactUsBodyScript,
        @RequestParam("callUsPhoneNumber") String callUsPhoneNumber,
        @RequestParam("callUsBodyScript") String callUsBodyScript,
        @RequestParam("locationMapUrl") String locationMapUrl,
        @RequestParam("locationAddress") String locationAddress,
        @RequestParam(value = "contactUsImage", required = false) MultipartFile contactUsImage,
        @RequestParam("appUrlPlaystore") String appUrlPlaystore,
        @RequestParam("appUrlAppStore") String appUrlAppStore,
        @RequestParam("copyrightInfo") String copyrightInfo
    ) {
        try {
            FooterSettings footerSettings = repository.findById(id).orElse(null);

            if (footerSettings == null) {
                return ResponseEntity.status(404).body("FooterSettings not found with id: " + id);
            }

            footerSettings.setAboutUsHeaderScript(aboutUsHeaderScript);
            footerSettings.setAboutUsBodyScript(aboutUsBodyScript);
            footerSettings.setFeatureBox1HeaderScript(featureBox1HeaderScript);
            footerSettings.setFeatureBox1BodyScript(featureBox1BodyScript);
            footerSettings.setFeatureBox2HeaderScript(featureBox2HeaderScript);
            footerSettings.setFeatureBox2BodyScript(featureBox2BodyScript);

            if (aboutUsImage != null && !aboutUsImage.isEmpty()) {
                footerSettings.setAboutUsImage(extractImageBytes(aboutUsImage));
            }

            footerSettings.setContactUsEmail(contactUsEmail);
            footerSettings.setContactUsBodyScript(contactUsBodyScript);
            footerSettings.setCallUsPhoneNumber(callUsPhoneNumber);
            footerSettings.setCallUsBodyScript(callUsBodyScript);
            footerSettings.setLocationMapUrl(locationMapUrl);
            footerSettings.setLocationAddress(locationAddress);

            if (contactUsImage != null && !contactUsImage.isEmpty()) {
                footerSettings.setContactUsImage(extractImageBytes(contactUsImage));
            }

            footerSettings.setAppUrlPlaystore(appUrlPlaystore);
            footerSettings.setAppUrlAppStore(appUrlAppStore);
            footerSettings.setCopyrightInfo(copyrightInfo);

            repository.save(footerSettings);

            return ResponseEntity.ok("FooterSettings updated successfully!");
        } catch (Exception e) {
            logger.error("Error updating footer settings", e);
            return ResponseEntity.status(500).body("Error updating the FooterSettings: " + e.getMessage());
        }
    }

    @GetMapping
    public ResponseEntity<?> getFooterSettings() {
        try {
            FooterSettings footerSettings = repository.findFirstFooterSettings();

            if (footerSettings == null) {
                // FIX: Return proper JSON so frontend can parse it without SyntaxError
                return ResponseEntity.status(404).body(null);
            }

            return ResponseEntity.ok(footerSettings);
        } catch (Exception e) {
            logger.error("Error retrieving footer settings", e);
            return ResponseEntity.status(500).body(null);
        }
    }

    private byte[] extractImageBytes(MultipartFile image) throws Exception {
        if (image != null && !image.isEmpty()) {
            System.out.println("File received: " + image.getOriginalFilename() + ", Size: " + image.getSize());
            return image.getBytes();
        }
        return null;
    }
}