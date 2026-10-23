package com.VsmartEngine.MediaJungle.userregister;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
//import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.MailVerification.EmailService;
import com.VsmartEngine.MediaJungle.compresser.ImageUtils;
import com.VsmartEngine.MediaJungle.notification.service.NotificationService;

@CrossOrigin()
@RestController
@RequestMapping("/api/v2/")
public class UserRegisterController {
    
    @Autowired
    private UserRegisterRepository userregisterrepository;
    
    @Autowired
    private JwtUtil jwtUtil; // Autowire JwtUtil

    @Autowired
    private TokenBlacklist tokenBlacklist;
    
	@Autowired
    private NotificationService notificationservice;  
	
	private static final Logger logger = LoggerFactory.getLogger(UserRegisterController.class);
       
	   public ResponseEntity<?> register(
		        @RequestParam("username") String username,
		        @RequestParam("email") String email,
		        @RequestParam("password") String password,
		        @RequestParam("mobnum") String mobnum,
		        @RequestParam(value = "profile", required = false) MultipartFile profile) {
		    try {
		        // Encrypt the password and confirmPassword
		        BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
		        String encodedPassword = passwordEncoder.encode(password);
		        // Set current date
		        LocalDate parsedDate = LocalDate.now();

		        // Create a new UserRegister object
		        UserRegister newRegister = new UserRegister();
		        newRegister.setUsername(username);
		        newRegister.setEmail(email);
		        newRegister.setPassword(encodedPassword);
		        newRegister.setMobnum(mobnum);
		        newRegister.setDate(parsedDate);

		        // Handle profile image
		        if (profile != null && !profile.isEmpty()) {
		            byte[] thumbnailBytes = ImageUtils.compressImage(profile.getBytes());
		            newRegister.setProfile(thumbnailBytes);
		        }

		        // Save the user to the repository
		        UserRegister savedUser = userregisterrepository.save(newRegister);

		        return ResponseEntity.ok(savedUser);

		    } catch (Exception e) {
		        // Handle exceptions
		    	logger.error("", e);
		        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
		                .body("{\"message\": \"An error occurred while registering the user: \"}" + e.getMessage());
		    }
		}
	
	
    public ResponseEntity<List<UserRegisterDTO>> getUsersRegisteredWithinLast15Days() {
        LocalDate startDate = LocalDate.now().minusDays(15);
        List<UserRegisterDTO> users  = userregisterrepository.findUsersRegisteredWithinLast15Days(startDate);
        if (!users.isEmpty()) {
            return ResponseEntity.ok(users);
        } else {
            return ResponseEntity.noContent().build();
        }
    }

    
    public ResponseEntity<List<UserRegister>> getAllUser() {
        try {
            // Fetch all users from the repository
            List<UserRegister> getUser = userregisterrepository.findAll();
            
            // Check if the list is empty
            if (getUser.isEmpty()) {
                return new ResponseEntity(HttpStatus.NO_CONTENT); // Return 204 No Content
            }
            
            // Return the list of users with 200 OK
            return new ResponseEntity<>(getUser, HttpStatus.OK);
        } catch (Exception e) {
            // Handle exceptions and return 500 Internal Server Error
        	logger.error("", e);
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }


    public ResponseEntity<UserRegister> getUserById(@PathVariable Long id) {
        Optional<UserRegister> userOptional = userregisterrepository.findById(id);
        if (userOptional.isPresent()) {
            UserRegister user = userOptional.get();
            // Check if the profile is present (not null and not empty)
            if (user.getProfile() != null && user.getProfile().length > 0) {
                byte[] images = ImageUtils.decompressImage(user.getProfile());
                user.setProfile(images);
            }
            return ResponseEntity.ok(user);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
  
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginRequest) {
        String email = loginRequest.get("email");
        String password = loginRequest.get("password");
        BCryptPasswordEncoder passwordEncoderr = new BCryptPasswordEncoder();
        String encodedPassword = passwordEncoderr.encode(password);
        System.out.print(encodedPassword);
        Optional<UserRegister> userOptional = userregisterrepository.findByEmail(email);
        if (!userOptional.isPresent()) {
            // User with the provided email doesn't exist
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("{\"message\": \"User not found\"}");
        }
        UserRegister user = userOptional.get();
        BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
        
        if (!passwordEncoder.matches(password, user.getPassword())) {
            // Incorrect password
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("{\"message\": \"Incorrect password\"}");
        }
        // Generate JWT token
//        String role = user.getRole(); // Get user role
        String role = "USER"; // Get user role
        String jwtToken = jwtUtil.generateToken(email,role);
        Map<String, Object> responseBody = new HashMap<>();
        responseBody.put("token", jwtToken);
        responseBody.put("message", "Login successful");
        responseBody.put("name", user.getUsername());
        responseBody.put("email", user.getEmail());
        responseBody.put("userId", user.getId());
//        responseBody.put("profile", null); // Simply set image as null without loading it

        // Check if the user has an expiry date for subscription
        if (user.getPaymentId() != null && user.getPaymentId().getExpiryDate() != null) {
            LocalDate expdate = user.getPaymentId().getExpiryDate();
            LocalDate today = LocalDate.now();
            String plan = user.getPaymentId().getSubscriptionTitle();
            
            if (expdate.minusDays(1).equals(today)) {
                // Create notification and associate with user
                String heading = user.getUsername() + ", your " + plan + " subscription validity expires on " + expdate;
                try {
                    Long notifyId = notificationservice.createNotification(user.getUsername(), user.getEmail(), heading);
                    if (notifyId != null) {
                        notificationservice.notificationuser(notifyId, user.getId());
                    } else {
                        // Handle notification creation failure
                        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("{\"message\": \"Failed to create notification\"}");
                    }
                } catch (Exception e) {
                    // Handle any exceptions during notification creation
                	logger.error("", e);
                    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("{\"message\": \"Error creating notification\"}");
                }
            }
        }
        // Successful login
        return ResponseEntity.status(HttpStatus.OK).body(responseBody);
    }

    
    public ResponseEntity<String> logout(@RequestHeader("Authorization") String token) {
        // Extract the token from the Authorization header
        // Check if the token is valid (e.g., not expired)
        // Blacklist the token to invalidate it
        tokenBlacklist.blacklistToken(token);
        System.out.println("Logged out successfully");
        // Respond with a success message
        return ResponseEntity.ok().body("Logged out successfully");
    }
    
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> loginRequest) {
        try {
            // Finding the user by email
            String email = loginRequest.get("email");
            String password = loginRequest.get("password");
            Optional<UserRegister> userOptional = userregisterrepository.findByEmail(email);

            // If the user doesn't exist, return 404 Not Found
            if (!userOptional.isPresent()) {
                System.out.println("User not found: " + email);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
            }

            UserRegister user = userOptional.get();

            BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
            String encodedPassword = passwordEncoder.encode(password);

            // Update the user password
            user.setPassword(encodedPassword);

            // Save the updated user
            UserRegister savedUser = userregisterrepository.save(user);
            Long userId = savedUser.getId();
            String name = savedUser.getUsername();
            String heading = name + " successfully changed your password";

            // Create notification and associate with user
            Long notifyId = notificationservice.createNotification(name, email, heading);
            
            if (notifyId != null) {
                notificationservice.notificationuser(notifyId, userId);
            }

            return ResponseEntity.ok("Password reset successfully");

        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred");
        }
    }
    
    

    public ResponseEntity<String> updateUserr(
            @PathVariable Long userId,
            @RequestParam(value = "username", required = false) String username,
            @RequestParam(value = "email", required = false) String email,
            @RequestParam(value = "mobnum", required = false) String mobnum,
            @RequestParam(value = "password", required = false) String password,
            @RequestParam(value = "profile", required = false) MultipartFile profile) {

        try {
            // Retrieve existing user data from the repository
            Optional<UserRegister> optionalUserRegister = userregisterrepository.findById(userId);
            if (!optionalUserRegister.isPresent()) {
                return new ResponseEntity<>("User not found", HttpStatus.NOT_FOUND);
            }
            UserRegister existingUser = optionalUserRegister.get();
            // Apply partial updates to the existing user data if provided
            if (username != null) {
                existingUser.setUsername(username);
            }
            if (email != null) {
                existingUser.setEmail(email);
            }
            if (mobnum != null) {
                existingUser.setMobnum(mobnum);
            }
            BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
            if (password != null) {
            	String encodedPassword = passwordEncoder.encode(password);
	            existingUser.setPassword(encodedPassword);
	        }
	        
            if (profile != null && !profile.isEmpty()) {
                byte[] thumbnailBytes = ImageUtils.compressImage(profile.getBytes());
                existingUser.setProfile(thumbnailBytes);
            }

            // Save the updated user data back to the repository
            userregisterrepository.save(existingUser);
            return new ResponseEntity<>("User details updated successfully", HttpStatus.OK);
        } catch (IOException e) {
        	logger.error("", e);
            return new ResponseEntity<>("Error processing profile image", HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
        	logger.error("", e);
            return new ResponseEntity<>("Error updating user details", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

   

}