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
import com.VsmartEngine.MediaJungle.model.AddCertificate;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.notification.service.NotificationService;
import com.VsmartEngine.MediaJungle.repository.AddUserRepository;
import com.VsmartEngine.MediaJungle.repository.CertificateRepository;
import com.VsmartEngine.MediaJungle.userregister.JwtUtil;


@Controller
public class CertificateController {
	
	@Autowired
	private CertificateRepository certificaterepository ;
	
	@Autowired
    private NotificationService notificationservice;
	
	@Autowired
	private JwtUtil jwtUtil; // Autowire JwtUtil
	
	@Autowired
	private AddUserRepository adduserrepository;
	
	private static final Logger logger = LoggerFactory.getLogger(CertificateController.class);

	
	public ResponseEntity<String> createEmployee(@RequestHeader("Authorization") String token,@RequestBody AddCertificate data) {
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
	            
		        AddCertificate savecertificate = certificaterepository.save(data);
		     // Assuming you need to create a notification for a new category
	            Long certificateId = savecertificate.getId();
	            String certificateName = savecertificate.getCertificate(); // Adjust as needed
	            String heading = certificateName+ " New Certificate Added!";

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


	

	public ResponseEntity<List<AddCertificate>> getAllCertificate() {
	    List<AddCertificate> certificate = certificaterepository.findAll();
	    return new ResponseEntity<>(certificate, HttpStatus.OK);
	}
	

	public ResponseEntity<AddCertificate> getTagById(@PathVariable Long certificateId) {
	    Optional<AddCertificate> certOptional = certificaterepository.findById(certificateId);
	    if (certOptional.isPresent()) {
	    	AddCertificate cert = certOptional.get();
	        return new ResponseEntity<>(cert, HttpStatus.OK);
	    } else {
	        return ResponseEntity.notFound().build();
	    }    
	}
	

    public ResponseEntity<?> deleteCategory(@PathVariable Long certificateId,@RequestHeader("Authorization") String token) {
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
                
	            // Fetch category details before deletion
	            Optional<AddCertificate> optionalCertificate = certificaterepository.findById(certificateId);
	            if (optionalCertificate.isEmpty()) {
	                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "Category not found"));
	            }
	            AddCertificate certificate = optionalCertificate.get();
	            String name = certificate.getCertificate();
            // Assuming you have a method to delete a category by ID in your repository
        	certificaterepository.deleteById(certificateId);
        	// Create notification if category is deleted
            String heading = name + " Certificate Deleted!";
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

	

	public ResponseEntity<String> editCategories(@PathVariable Long certificateId, @RequestBody AddCertificate editCertificate,@RequestHeader("Authorization") String token) {
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
		        AddCertificate existingCertificate = certificaterepository.findById(certificateId)
		                .orElseThrow(() -> new RuntimeException("Certificate not found"));
		        String certificate = existingCertificate.getCertificate();

		        // Apply partial updates to the existing user data
		        if (editCertificate.getCertificate() != null) {
		        	existingCertificate.setCertificate(editCertificate.getCertificate());
		        }
		        
		        if(editCertificate.getDescription() != null) {
		        	existingCertificate.setDescription(editCertificate.getDescription());
		        }
		        
		        if(editCertificate.getIssuedby() != null) {
		        	existingCertificate.setIssuedby(editCertificate.getIssuedby());
		        }
		        
		        String newcertficate = existingCertificate.getCertificate();
		     // Save the updated user data back to the repository
		        certificaterepository.save(existingCertificate);

		        String heading = certificate +" certificate upadted to " + newcertficate;
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
		        return new ResponseEntity<>("Certificate details updated successfully", HttpStatus.OK);
		   }
		   catch (Exception e) {
			   logger.error("", e);
		        return new ResponseEntity<>("Error updating Certificate details", HttpStatus.INTERNAL_SERVER_ERROR);
		    }
	}
		   
}
