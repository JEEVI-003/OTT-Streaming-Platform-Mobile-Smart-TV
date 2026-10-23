package com.VsmartEngine.MediaJungle.mobile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.compresser.ImageUtils;
import com.VsmartEngine.MediaJungle.model.Addaudio1;
import com.VsmartEngine.MediaJungle.model.Audiodescription;
import com.VsmartEngine.MediaJungle.repository.AddAudioRepository;
import com.VsmartEngine.MediaJungle.repository.AddAudiodescription;
import com.VsmartEngine.MediaJungle.userregister.JwtUtil;
import com.VsmartEngine.MediaJungle.userregister.TokenBlacklist;
import com.VsmartEngine.MediaJungle.userregister.UserRegister;
import com.VsmartEngine.MediaJungle.userregister.UserRegisterRepository;
import com.VsmartEngine.MediaJungle.video.AddVideoDescriptionRepository;
import com.VsmartEngine.MediaJungle.video.VideoDescription;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@CrossOrigin()
@RestController
@RequestMapping("/api/v2/")
public class MobileAppController {
	
	@Autowired
    private UserRegisterRepository userregisterrepository;
	
	@Autowired
    private JwtUtil jwtUtil; // Autowire JwtUtil

    @Autowired
    private TokenBlacklist tokenBlacklist;
    
    private static final Logger logger = LoggerFactory.getLogger(MobileAppController.class);
//	@PostMapping("/register/mobile")
//    public ResponseEntity<UserRegister> registerMobile(@RequestParam("username") String username,
//                                                       @RequestParam("email") String email,
//                                                       @RequestParam("password") String password,
//                                                       @RequestParam("mobnum") String mobnum,
//                                                       @RequestParam("confirmPassword") String confirmPassword,
//                                                       @RequestParam(value = "profile", required = false) MultipartFile profile) throws IOException {
//        if (!password.equals(confirmPassword)) {
//            return ResponseEntity.badRequest().body(null);
//        }
//
//        UserRegister newRegister = new UserRegister();
//        newRegister.setUsername(username);
//        newRegister.setEmail(email);
//        newRegister.setPassword(password);
//        newRegister.setConfirmPassword(confirmPassword);
//        newRegister.setMobnum(mobnum);
//
//        if (profile != null && !profile.isEmpty()) {
//            byte[] thumbnailBytes = ImageUtils.compressImage(profile.getBytes());
//            newRegister.setProfile(thumbnailBytes);
//        }
//
//        UserRegister savedUser = userregisterrepository.save(newRegister);
//        return ResponseEntity.ok(savedUser);
//    }
	
	@GetMapping("/GetUserById/mobile/{id}")
    public ResponseEntity<UserRegister> getUserByIdmobile(@PathVariable Long id) {
        Optional<UserRegister> userOptional = userregisterrepository.findById(id);
        if (userOptional.isPresent()) {
            return ResponseEntity.ok(userOptional.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }
	
	@GetMapping("/mobile/GetThumbnailsById/{id}")
    public ResponseEntity<List<String>> getThumbnailsById(@PathVariable Long id) {
        try {
            Optional<UserRegister> profileOptional = userregisterrepository.findById(id);

            if (profileOptional.isPresent()) {
                UserRegister profile = profileOptional.get();

                // Assuming decompressImage returns the raw thumbnail data
                byte[] thumbnailData = ImageUtils.decompressImage(profile.getProfile());

                // Convert the byte array to Base64
                String base64Thumbnail = Base64.getEncoder().encodeToString(thumbnailData);

                // Return a list with a single Base64-encoded thumbnail
                return ResponseEntity.ok(Collections.singletonList(base64Thumbnail));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            e.printStackTrace(); // Log the exception for debugging
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
	
//	 @DeleteMapping("/mobile/deleteuser/{UserId}")
//	 public ResponseEntity<Void> deleteUsermobile(@PathVariable Long UserId) {
//	        try {
//	            // Assuming you have a method to delete a category by ID in your repository
//	        	userregisterrepository.deleteById(UserId);
//	            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
//	        } catch (Exception e) {
//	            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
//	        }
//	    }

    
    @PatchMapping("/UpdateUser/mobile/{userId}")
    public ResponseEntity<String> updateUser(
            @PathVariable Long userId,
            @RequestParam(value = "username", required = false) String username,
            @RequestParam(value = "email", required = false) String email,
            @RequestParam(value = "mobnum", required = false) String mobnum,
            @RequestParam(value = "password", required = false) String password,
            @RequestParam(value = "confirmPassword", required = false) String confirmPassword,
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
//            if (password != null) {
//                if (!password.equals(confirmPassword)) {
//                    return new ResponseEntity<>("Passwords do not match", HttpStatus.BAD_REQUEST);
//                }
//                // Encrypt the password before saving
//                String encryptedPassword = passwordEncoder.encode(password);
//                existingUser.setPassword(encryptedPassword);
//                existingUser.setConfirmPassword(encryptedPassword); // Assuming this is required
//            }
            BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
            if (password != null) {
            	String encodedPassword = passwordEncoder.encode(password);
	            existingUser.setPassword(encodedPassword);
	        }

//	        if (confirmPassword!= null) {
//	        	String confirmencodedPassword = passwordEncoder.encode(confirmPassword);
//	            existingUser.setConfirmPassword(confirmencodedPassword);
//	        }
//	        
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
    
        
//    @PostMapping("/mobile/forgetPassword")
//    public ResponseEntity<?> resetPasswordmobile(@RequestBody Map<String, String> loginRequest) {
//        // Finding the user by email
//    	
//    	String email = loginRequest.get("email");
//        String password = loginRequest.get("password");
//        String confirmpassword = loginRequest.get("confirmPassword");
//        Optional<UserRegister> userOptional = userregisterrepository.findByEmail(email);
//
//        // If the user doesn't exist, return 404 Not Found
//        if (!userOptional.isPresent()) {
//            System.out.println("User not found: " + email);
//            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
//        }
//
//        UserRegister user = userOptional.get();
//
//        // If passwords do not match, return 400 Bad Request
//        if (!password.equals(confirmpassword)) {
//            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Passwords do not match");
//        }
//
//        // Assuming you have a method to hash the password
//        user.setPassword(password);
//        
//        // Do not set confirmPassword in the entity, it's used only for validation
//
//        userregisterrepository.save(user);
//
//        return ResponseEntity.ok("Password reset successfully");
//    }

        
    //-------------------------favorite audio---------------------------
    
    

    
    
    //----------------------------favourite video ---------------------------------
    
    @Autowired
   	private AddVideoDescriptionRepository videodescriptionRepository;
    
    
    @PostMapping("/mobile/favourite/video")
    public ResponseEntity<String> favoriteVideo(@RequestBody Map<String, Long> requestData) {
        try {
            Long videoId = requestData.get("videoId");
            Long userId = requestData.get("userId");

            if (videoId == null || userId == null) {
                return new ResponseEntity<>("Invalid request data", HttpStatus.BAD_REQUEST);
            }

            Optional<UserRegister> optionalUser = userregisterrepository.findById(userId);
            Optional<VideoDescription> optionalVideo = videodescriptionRepository.findById(videoId);

            if (optionalUser.isPresent() && optionalVideo.isPresent()) {
                UserRegister user = optionalUser.get();

                // Check if the user has already added this audioId to favorites
                if (user.getFavoriteVideosIds().contains(videoId)) {
                    return ResponseEntity.badRequest().body("User has already added this audio to favourites");
                }

                // Add the audioId to the user's favoriteAudioIds
                user.getFavoriteVideosIds().add(videoId);
                userregisterrepository.save(user);

                return ResponseEntity.ok("Favourite video added successfully");
            } else {
            	StringBuilder errorMessage = new StringBuilder();

                if (!optionalUser.isPresent()) {
                    errorMessage.append("User with ID ").append(userId).append(" not found. ");
                }
                if (!optionalVideo.isPresent()) {
                    errorMessage.append("Video with ID ").append(videoId).append(" not found.");
                }

                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorMessage.toString().trim());
            }
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error adding to favourites: " + e.getMessage());
        }
    }
    
    

@GetMapping("/mobile/{userId}/UserVideos")
public ResponseEntity<List<Long>> getVideoForUsermobile(@PathVariable Long userId) {
    Optional<UserRegister> optionalUser = userregisterrepository.findById(userId);
    if (optionalUser.isPresent()) {
        UserRegister user = optionalUser.get();
        // Get the set of favorite audio IDs
        Set<Long> favoriteVideosIdsSet = user.getFavoriteVideosIds();
        // Convert the set to a list if needed
        List<Long> favoriteAudioIdsList = new ArrayList<>(favoriteVideosIdsSet);
        // Return the list of audio IDs
        return ResponseEntity.ok(favoriteAudioIdsList);
    } else {
        return ResponseEntity.notFound().build();
    }
}



@DeleteMapping("/mobile/{userId}/removeFavoriteVideo")
public ResponseEntity<String> removeFavoriteVideo(@PathVariable Long userId, @RequestParam Long videoId) {
    try {
        if (videoId == null) {
            return new ResponseEntity<>("Invalid request data", HttpStatus.BAD_REQUEST);
        }

        Optional<UserRegister> optionalUser = userregisterrepository.findById(userId);
        Optional<VideoDescription> optionalVideo = videodescriptionRepository.findById(videoId);
        
        if (optionalUser.isPresent() && optionalVideo.isPresent()) {
            UserRegister user = optionalUser.get();

            // Remove the videoId from the user's favoriteVideosIds
            if (user.getFavoriteVideosIds().remove(videoId)) {
                userregisterrepository.save(user); // Save the updated user

                return ResponseEntity.ok("Video removed from favorites successfully");
            } else {
                return ResponseEntity.badRequest().body("Video ID not found in user's favorites");
            }
        } else {
            StringBuilder errorMessage = new StringBuilder();

            if (!optionalUser.isPresent()) {
                errorMessage.append("User with ID ").append(userId).append(" not found. ");
            }
            if (!optionalVideo.isPresent()) {
                errorMessage.append("Video with ID ").append(videoId).append(" not found.");
            }

            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorMessage.toString().trim());
        }
    } catch (Exception e) {
        e.printStackTrace();
        logger.error("", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error removing video from favorites: " + e.getMessage());
    }
}



}
