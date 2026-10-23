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
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;

import com.VsmartEngine.MediaJungle.Container.VideoContainerController;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.model.PlanFeatures;
import com.VsmartEngine.MediaJungle.notification.service.NotificationService;
import com.VsmartEngine.MediaJungle.repository.AddUserRepository;
import com.VsmartEngine.MediaJungle.repository.PlanFeatureMergeRepository;
import com.VsmartEngine.MediaJungle.repository.PlanFeaturesRepository;
import com.VsmartEngine.MediaJungle.userregister.JwtUtil;

@CrossOrigin(origins = "*")
@Controller
public class FeatureController {

	@Autowired
	private PlanFeaturesRepository planfeaturesrepository;
	
	@Autowired
	private PlanFeatureMergeRepository planfeaturemergerepository;
	@Autowired
    private NotificationService notificationservice;
	
	@Autowired
	private JwtUtil jwtUtil;
	
	@Autowired
	private AddUserRepository adduserrepository;
	
	private static final Logger logger = LoggerFactory.getLogger(FeatureController.class);

	
	public ResponseEntity<?> addPlanFeature(@RequestParam("feature") String feature,
	        @RequestHeader("Authorization") String token) {
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

	        // Create a new PlanDescription object
	        PlanFeatures features = new PlanFeatures();
	        features.setFeature(features);

	        // Save the PlanDescription in the repository
	        PlanFeatures savedPlanFeature = planfeaturesrepository.save(features);

	        // Optionally, you can create a notification or perform other actions here
	        
	        return ResponseEntity.ok(savedPlanFeature);
	    } catch (Exception e) {
	    	logger.error("", e);
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error adding plan description.");
	    }
	}
	

	public ResponseEntity<String> createFeature(@RequestHeader("Authorization") String token, @RequestBody PlanFeatures data) {
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

	            // Save the new feature
	            PlanFeatures savedFeature = planfeaturesrepository.save(data);

	            // Assuming you need to create a notification for a new feature
	            Long featureId = savedFeature.getId();
	            String featureName = savedFeature.getFeatures(); // Adjust as needed
	            String heading = featureName +": New Feature Added!";

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


	

	public ResponseEntity<List<PlanFeatures>> getAllFeatures() {
	    List<PlanFeatures> features = planfeaturesrepository.findAll();
	    return new ResponseEntity<>(features, HttpStatus.OK);
	}
	

	public ResponseEntity<PlanFeatures> getFeatureById(@PathVariable Long categoryId) {
	    Optional<PlanFeatures> featureOptional = planfeaturesrepository.findById(categoryId);
	    if (featureOptional.isPresent()) {
	        PlanFeatures feature = featureOptional.get();
	        return new ResponseEntity<>(feature, HttpStatus.OK);
	    } else {
	        return ResponseEntity.notFound().build();
	    }
	}
	

	public ResponseEntity<?> deleteFeature(@PathVariable Long featureId, @RequestHeader("Authorization") String token) {
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

	            // Fetch feature details before deletion
	            Optional<PlanFeatures> optionalFeature = planfeaturesrepository.findById(featureId);
	            if (optionalFeature.isEmpty()) {
	                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "Feature not found"));
	            }
	           PlanFeatures feature = optionalFeature.get();
	            String name = feature.getFeatures();

	            // Delete the feature by ID
	            planfeaturesrepository.deleteById(featureId);

	            // Create notification if feature is deleted
	            String heading = name + " Feature Deleted!";
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

	

	public ResponseEntity<String> editFeatures(@PathVariable Long categoryId, @RequestBody PlanFeatures editFeature,@RequestHeader("Authorization") String token) {
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
		        PlanFeatures existingFeature = planfeaturesrepository.findById(categoryId)
		                .orElseThrow(() -> new RuntimeException("Feature not found"));
		        
		        String feature =  existingFeature.getFeatures();

		        // Apply partial updates to the existing user data
		        if (editFeature.getFeatures() != null) {
		        	existingFeature.setFeatures(editFeature.getFeatures());
		        }
		        String newfeature = existingFeature.getFeatures();
		     // Save the updated user data back to the repository
		        PlanFeatures details = planfeaturesrepository.save(existingFeature);
		        // Create notification for the user who updated the setting
	 	        String heading = feature +" feature upadted to " + newfeature;
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


		        return new ResponseEntity<>("Feature details updated successfully", HttpStatus.OK);
		   }
		   catch (Exception e) {
			   logger.error("", e);
		        return new ResponseEntity<>("Error updating Feature details", HttpStatus.INTERNAL_SERVER_ERROR);
		    }
	}
		   

}
