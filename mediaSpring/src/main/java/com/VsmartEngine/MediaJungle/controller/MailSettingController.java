package com.VsmartEngine.MediaJungle.controller;

import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.VsmartEngine.MediaJungle.Container.VideoContainerController;
import com.VsmartEngine.MediaJungle.model.MailSetting;
import com.VsmartEngine.MediaJungle.repository.MailsettingRepository;

@RestController
public class MailSettingController {
	
	@Autowired
	public MailsettingRepository mailsettingrepository;
	
	private static final Logger logger = LoggerFactory.getLogger(MailSettingController.class);

	public ResponseEntity<String> addOrUpdateMail(
	        @RequestParam(value = "mailhostname", required = false) String mailhostname,
	        @RequestParam(value = "mailportname", required = false) Integer mailportname,
	        @RequestParam(value = "emailid", required = false) String emailid,
	        @RequestParam(value = "password", required = false) String password) {
	    try {
	        // Check if a row exists
	        Optional<MailSetting> existingConfig = mailsettingrepository.findFirstByOrderByIdAsc();

	        MailSetting mailconfig;
	        if (existingConfig.isPresent()) {
	            // Partial update (editing existing record)
	            mailconfig = existingConfig.get();

	            if (mailhostname != null) {
	                mailconfig.setMailhostname(mailhostname);
	            }
	            if (mailportname != null) {
	                if (mailportname <= 0) {
	                    return new ResponseEntity<>("Mail port name must be a positive number", HttpStatus.BAD_REQUEST);
	                }
	                mailconfig.setMailportname(mailportname);
	            }
	            if (emailid != null) {
	                mailconfig.setEmailid(emailid);
	            }
	            if (password != null) {
	                mailconfig.setPassword(password);
	            }
	        } else {
	            // Create a new row (all fields required)
	            if (mailhostname == null || mailhostname.isEmpty() ||
	                mailportname == null || mailportname <= 0 ||
	                emailid == null || emailid.isEmpty() ||
	                password == null || password.isEmpty()) {
	                return new ResponseEntity<>("All fields are required for the first configuration", HttpStatus.BAD_REQUEST);
	            }

	            mailconfig = new MailSetting();
	            mailconfig.setMailhostname(mailhostname);
	            mailconfig.setMailportname(mailportname);
	            mailconfig.setEmailid(emailid);
	            mailconfig.setPassword(password);
	        }

	        // Save the configuration
	        mailsettingrepository.save(mailconfig);

	        // Return success response
	        return new ResponseEntity<>("Mail configuration added/updated successfully", HttpStatus.OK);
	    } catch (Exception e) {
	        // Log error (use a logger like SLF4J in production)
	        e.printStackTrace();
	        logger.error("", e);
	        return new ResponseEntity<>("An error occurred while adding/updating mail configuration", HttpStatus.INTERNAL_SERVER_ERROR);
	    }
	}

    public ResponseEntity<?> getMailConfiguration() {
        try {
            Optional<MailSetting> mailConfig = mailsettingrepository.findFirstByOrderByIdAsc();

            if (mailConfig.isPresent()) {
                return new ResponseEntity<>(mailConfig.get(), HttpStatus.OK);
            } else {
                return new ResponseEntity<>("No mail configuration found", HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            // Log error
            e.printStackTrace();
            logger.error("", e);
            return new ResponseEntity<>("An error occurred while retrieving mail configuration", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
	

}
