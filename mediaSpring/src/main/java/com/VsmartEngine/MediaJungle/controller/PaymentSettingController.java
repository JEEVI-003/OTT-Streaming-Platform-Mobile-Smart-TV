package com.VsmartEngine.MediaJungle.controller;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
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
import org.springframework.web.bind.annotation.RequestParam;

import com.VsmartEngine.MediaJungle.Container.VideoContainerController;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.model.Paymentsettings;
import com.VsmartEngine.MediaJungle.notification.service.NotificationService;
import com.VsmartEngine.MediaJungle.repository.AddUserRepository;
import com.VsmartEngine.MediaJungle.repository.PaymentsettingRepository;
import com.VsmartEngine.MediaJungle.userregister.JwtUtil;


@Controller
public class PaymentSettingController {
	
	@Autowired
	private PaymentsettingRepository paymentsettingrepository;
	
	@Autowired
    private NotificationService notificationservice;
	
	@Autowired
	private JwtUtil jwtUtil; // Autowire JwtUtil
	
	@Autowired
	private AddUserRepository adduserrepository;
	

	private static final Logger logger = LoggerFactory.getLogger(PaymentSettingController.class);

	public ResponseEntity<?>  Addpaymentsetting (@RequestParam("razorpay_key") String razorpay_key,
			@RequestParam("razorpay_secret_key")String razorpay_secret_key,
			@RequestHeader("Authorization") String token){
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
		Paymentsettings setting = new Paymentsettings();
		setting.setRazorpay_key(razorpay_key);
		setting.setRazorpay_secret_key(razorpay_secret_key);
		Paymentsettings details = paymentsettingrepository.save(setting);
		Long Id = details.getId();
        String heading = "Payment details  Added!";

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
        return ResponseEntity.ok(details);
	        } else {
	            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
	        }
	    } catch (Exception e) {
	    	logger.error("", e);
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred: " + e.getMessage());
	    }
	}
	

	public ResponseEntity<List<Paymentsettings>> getAllrazorpay() {
        List<Paymentsettings> getPlan = paymentsettingrepository.findAll();
        return new ResponseEntity<>(getPlan, HttpStatus.OK);
    }
	

	public ResponseEntity<String> editrazorpay(@PathVariable Long id , @RequestBody Paymentsettings updatedrazorpay,
			@RequestHeader("Authorization") String token){
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
            // Retrieve existing plan data from the repository
			Paymentsettings existingplan = paymentsettingrepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("not found"));

            // Apply partial updates to the existing plan data
            if (updatedrazorpay.getRazorpay_key() != null) {
                existingplan.setRazorpay_key(updatedrazorpay.getRazorpay_key());
            }
            
            if (updatedrazorpay.getRazorpay_secret_key()!= null) {
            	existingplan.setRazorpay_secret_key(updatedrazorpay.getRazorpay_secret_key());
            }
            
             Paymentsettings details = paymentsettingrepository.save(existingplan);
          // Create notification for the user who updated the setting
 	        String heading = "Payment details Updated!";
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

            return new ResponseEntity<>(" updated successfully", HttpStatus.OK);
        } catch (RuntimeException e) {
        	logger.error("", e);
            return new ResponseEntity<>("not found", HttpStatus.NOT_FOUND);
        } catch (Exception e) {
        	logger.error("", e);
            return new ResponseEntity<>("Error when updating", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
	
}
