package com.VsmartEngine.MediaJungle.controller;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;

import com.VsmartEngine.MediaJungle.Container.VideoContainerController;
import com.VsmartEngine.MediaJungle.model.AddLanguage;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.notification.service.NotificationService;
import com.VsmartEngine.MediaJungle.repository.AddLanguageRepository;
import com.VsmartEngine.MediaJungle.repository.AddUserRepository;
import com.VsmartEngine.MediaJungle.userregister.JwtUtil;


@Controller
public class LanguageController {
	
	@Autowired
	private AddLanguageRepository addlanguagerepository;
	
	@Autowired
    private NotificationService notificationservice;
	
	@Autowired
	private JwtUtil jwtUtil; // Autowire JwtUtil
	
	@Autowired
	private AddUserRepository adduserrepository;
	
	private static final Logger logger = LoggerFactory.getLogger(LanguageController.class);


	public ResponseEntity<String> createEmployee(@RequestHeader("Authorization") String token,@RequestBody AddLanguage data) {
		try {
	        if (!jwtUtil.validateToken(token)) {
	            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token");
	        }

	        String email = jwtUtil.getUsernameFromToken(token);
	        System.out.println("email: " + email);
	        Optional<AddUser> opUser = adduserrepository.findByUsername(email);

	        if (opUser.isPresent()) {
	            AddUser user = opUser.get();
	            String username = user.getUsername();
		         AddLanguage lang = addlanguagerepository.save(data);
		         Long  langId = lang.getId();
		            String langName = lang.getLanguage(); // Adjust as needed
		            String heading = langName +" New Language Added!";

		            // Create notification
		            Long notifyId = notificationservice.createNotification(username, email, heading);
		            if (notifyId != null) {
		                Set<String> notiUserSet = new HashSet<>();
		                // Fetch all admins from AddUser table
		                List<AddUser> adminUsers = adduserrepository.findAll();
		                for (AddUser admin : adminUsers) {
		                    notiUserSet.add(admin.getEmail());
		                }
		                notificationservice.CommoncreateNotificationAdmin(notifyId, new ArrayList<>(notiUserSet));
		            }

		            return ResponseEntity.status(HttpStatus.CREATED).body("success");
		        } else {
		            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
		        }
		    } catch (Exception e) {
		    	logger.error("", e);
		        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred: " + e.getMessage());
		    }
		}
	
	

	public ResponseEntity<List<AddLanguage>> getAllLanguage() {
	    List<AddLanguage> categories = addlanguagerepository.findAll();
	    return new ResponseEntity<>(categories, HttpStatus.OK);
	}
	

	public ResponseEntity<AddLanguage> getTagById(@PathVariable Long languageId) {
	    Optional<AddLanguage> langOptional = addlanguagerepository.findById(languageId);
	    if (langOptional.isPresent()) {
	    	AddLanguage lang = langOptional.get();
	        return new ResponseEntity<>(lang, HttpStatus.OK);
	    } else {
	        return ResponseEntity.notFound().build();
	    }
	    
	}
	

    public ResponseEntity<?> deleteLanguage(@PathVariable Long categoryId,@RequestHeader("Authorization") String token) {
		 try {
		        // Validate JWT token
		        if (!jwtUtil.validateToken(token)) {
		            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid token"));
		        }

		        // Extract username from token
		        String email = jwtUtil.getUsernameFromToken(token);
		        System.out.println("email: " + email);
		        Optional<AddUser> optionalUser = adduserrepository.findByUsername(email);

		        if (optionalUser.isPresent()) {
		            AddUser user = optionalUser.get();
		            String username = user.getUsername();
		            Optional<AddLanguage> optionallanguage = addlanguagerepository.findById(categoryId);
		            if (optionallanguage.isEmpty()) {
		                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "Category not found"));
		            }
		            AddLanguage language = optionallanguage.get();
		            String name = language.getLanguage();
            // Assuming you have a method to delete a category by ID in your repository
        	addlanguagerepository.deleteById(categoryId);
        	// Create notification if category is deleted
            String heading = name + " Language Deleted!";
            Long notifyId = notificationservice.createNotification(username, email, heading);
            if (notifyId != null) {
                Set<String> notiUserSet = new HashSet<>();
                // Fetch all admins from AddUser table
                List<AddUser> adminUsers = adduserrepository.findAll();
                for (AddUser admin : adminUsers) {
                    notiUserSet.add(admin.getEmail());
                }
                notificationservice.CommoncreateNotificationAdmin(notifyId, new ArrayList<>(notiUserSet));
            }
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "User not authorized"));
        }
    } catch (Exception e) {
    	logger.error("", e);
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
	

	public ResponseEntity<String> editLanguage(@PathVariable Long languageId,@RequestBody AddLanguage editlanguage,@RequestHeader("Authorization") String token) {
		try {
	        // Validate JWT token
	        if (!jwtUtil.validateToken(token)) {
	            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token");
	        }

	        // Extract email from token
	        String email = jwtUtil.getUsernameFromToken(token);
	        System.out.println("email: " + email);

	        // Fetch user details from repository
	        Optional<AddUser> opUser = adduserrepository.findByUsername(email);
	        if (!opUser.isPresent()) {
	            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
	        }

	        AddUser user = opUser.get();
	        String username = user.getUsername();

		        // Retrieve existing user data from the repository
		        AddLanguage existingLanguage = addlanguagerepository.findById(languageId)
		                .orElseThrow(() -> new RuntimeException("Category not found"));
		        String language = existingLanguage.getLanguage();

		        // Apply partial updates to the existing user data
		        if ( editlanguage.getLanguage() != null) {
		        	existingLanguage.setLanguage(editlanguage.getLanguage());
		        }
		        String newlanguage = existingLanguage.getLanguage();
		     // Save the updated user data back to the repository
		        AddLanguage details = addlanguagerepository.save(existingLanguage);
		     // Create notification for the user who updated the setting
	 	        String heading = language +" category upadted to " + newlanguage;
	 	        Long notifyId = notificationservice.createNotification(username, email, heading);
	             if (notifyId != null) {
	                 Set<String> notiUserSet = new HashSet<>();
	                 // Fetch all admins from AddUser table
	                 List<AddUser> adminUsers = adduserrepository.findAll();
	                 for (AddUser admin : adminUsers) {
	                     notiUserSet.add(admin.getEmail());
	                 }
	                 notificationservice.CommoncreateNotificationAdmin(notifyId, new ArrayList<>(notiUserSet));
	             }

		        return new ResponseEntity<>("Language details updated successfully", HttpStatus.OK);
		   }
		   catch (Exception e) {
			   logger.error("", e);
		        return new ResponseEntity<>("Error updating Language details", HttpStatus.INTERNAL_SERVER_ERROR);
		    }
	}
	


}
