package com.VsmartEngine.MediaJungle.controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.VsmartEngine.MediaJungle.Container.VideoContainerController;
import com.VsmartEngine.MediaJungle.model.User;
import com.VsmartEngine.MediaJungle.service.UserService;
import com.VsmartEngine.MediaJungle.userregister.UserRegister;

@RestController
@RequestMapping("/api/v2/")
@CrossOrigin(origins = "*")
public class ProfileImageController {

	// Add this to the top of your controller
	@Autowired
	private UserService userService;
    // Directory where files will be saved on the server
    @Value("${upload.Profile.directory}")
    private String uploadDirectory;
    
    private static final Logger logger = LoggerFactory.getLogger(ProfileImageController.class);

   
    public ResponseEntity<?> updateUser(@PathVariable Long userId, @RequestParam("username") String username,
                                         @RequestParam("email") String email, @RequestParam("mobnum") String mobnum,
                                         @RequestParam(value = "profileImage", required = false) MultipartFile profileImage) {
        // Service method to handle the update logic
        try {
            UserRegister user = userService.updateUser(userId, username, email, mobnum, profileImage);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
        	logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Failed to update user: " + e.getMessage());
        }
    }

    public ResponseEntity<?> uploadProfileImage(@PathVariable Long userId, @RequestParam("image") MultipartFile image) {
        // Check if the file is empty
        if (image.isEmpty()) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "No file uploaded");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }

        // Optionally check file type
        String contentType = image.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Invalid file type. Only images are allowed.");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }

        try {
            // Update the profile picture
            userService.updateProfilePicture(userId, image.getBytes());

            // Construct a success response
            Map<String, String> response = new HashMap<>();
            response.put("message", "Profile picture updated successfully");

            // Return a JSON response with status 200 OK
            return ResponseEntity.ok(response);
        } 
    catch (IOException e) {
        // Log the error and send an error response in JSON format
    	logger.error("", e);
        e.printStackTrace();
        Map<String, String> errorResponse = new HashMap<>();
        errorResponse.put("error", "Failed to process image file");
        errorResponse.put("details", e.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    } catch (RuntimeException e) {
        // Handle user not found or other runtime issues
    	logger.error("", e);
        Map<String, String> errorResponse = new HashMap<>();
        errorResponse.put("error", "User not found");
        errorResponse.put("details", e.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
    } catch (Exception e) {
    	logger.error("", e);
        // Generic exception handling for unexpected errors
        Map<String, String> errorResponse = new HashMap<>();
        errorResponse.put("error", "An unexpected error occurred");
        errorResponse.put("details", e.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
    }
    
}


public ResponseEntity<byte[]> getProfileImage(@PathVariable Long userId) {
    try {
        // Retrieve the user by userId
        UserRegister user = userService.getUserById(userId);
        byte[] imageData = user.getProfile();

        // Check if image data is present
        if (imageData != null) {
            return ResponseEntity.ok()
            		 .contentType(MediaType.parseMediaType("image/jpeg")) // Adjust based on image type
                    .body(imageData);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    } catch (RuntimeException e) {
        // Handle user not found or other runtime issues
    	logger.error("", e);
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
    } catch (Exception e) {
        // Handle other unexpected errors
    	logger.error("", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
    }
}
}