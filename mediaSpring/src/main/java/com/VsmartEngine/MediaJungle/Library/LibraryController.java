package com.VsmartEngine.MediaJungle.Library;

import java.util.ArrayList;
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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.mobile.favouriteRepository;
import com.VsmartEngine.MediaJungle.model.Audiodescription;
import com.VsmartEngine.MediaJungle.repository.AddAudioRepository;
import com.VsmartEngine.MediaJungle.repository.AddAudiodescription;
import com.VsmartEngine.MediaJungle.userregister.JwtUtil;
import com.VsmartEngine.MediaJungle.userregister.TokenBlacklist;
import com.VsmartEngine.MediaJungle.userregister.UserRegister;
import com.VsmartEngine.MediaJungle.userregister.UserRegisterRepository;
import com.VsmartEngine.MediaJungle.video.AddVideoDescriptionRepository;
import com.VsmartEngine.MediaJungle.video.VideoDescription;


@RestController

public class LibraryController {
	
//  ---------------------------------watchlater----------------------------------------------
	
	@Autowired
    private UserRegisterRepository userregisterrepository;
    
    @Autowired
   	private AddVideoDescriptionRepository videodescriptionRepository;
 
    private static final Logger logger = LoggerFactory.getLogger(LibraryController.class);
   
    public ResponseEntity<String> watchlaterVideo(@RequestBody Map<String, Long> requestData) {
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
                if (user.getWatchlaterIds().contains(videoId)) {
                    return ResponseEntity.badRequest().body("User has already added this video to watchlater");
                }

                // Add the audioId to the user's favoriteAudioIds
                user.getWatchlaterIds().add(videoId);
                userregisterrepository.save(user);

                return ResponseEntity.ok("Watchlater video added successfully");
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

   
    public ResponseEntity<String> getwatchlaterVideo(@RequestParam Long videoId, @RequestParam Long userId) {
        try {
            // Check if videoId or userId is null
            if (videoId == null || userId == null) {
                return new ResponseEntity<>("Invalid request data", HttpStatus.BAD_REQUEST);
            }

            // Retrieve the user and video data
            Optional<UserRegister> optionalUser = userregisterrepository.findById(userId);
            Optional<VideoDescription> optionalVideo = videodescriptionRepository.findById(videoId);

            // Check if user and video both exist
            if (optionalUser.isPresent() && optionalVideo.isPresent()) {
                UserRegister user = optionalUser.get();

                // Check if the videoId is already in the user's watchlaterIds
                boolean isVideoInWatchLater = user.getWatchlaterIds().contains(videoId);
                
                // Return true or false as a JSON response
                return ResponseEntity.ok(isVideoInWatchLater ? "true" : "false");
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
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error checking watch later status: " + e.getMessage());
        }
    }
    
   
    public ResponseEntity<List<WatchLaterDTO>> getVideosForWatchlater(@PathVariable Long userId) {
        Optional<UserRegister> optionalUser = userregisterrepository.findById(userId);
        if (optionalUser.isPresent()) {
            UserRegister user = optionalUser.get();
            
            // Get the set of watchlater video IDs
            Set<Long> watchlaterVideoIdsSet = user.getWatchlaterIds();
            
            // Create a list to hold WatchLaterDTO objects
            List<WatchLaterDTO> watchLaterDTOList = new ArrayList<>();
            
            // Loop through each video ID and fetch video details (ID and Title)
            for (Long videoId : watchlaterVideoIdsSet) {
                // Fetch video using repository and handle Optional
                Optional<VideoDescription> optionalVideo = videodescriptionRepository.findById(videoId);
                
                if (optionalVideo.isPresent()) {
                    VideoDescription video = optionalVideo.get();
                    
                    // Create a new WatchLaterDTO with video ID and video title
                    WatchLaterDTO watchLaterDTO = new WatchLaterDTO(video.getId(), video.getVideoTitle());
                    
                    // Add to the list
                    watchLaterDTOList.add(watchLaterDTO);
                } else {
                    // Handle the case where the video does not exist (if needed)
                    // You can choose to log or skip the missing video
                    System.out.println("Video with ID " + videoId + " not found.");
                }
            }
            
            // Return the list of WatchLaterDTO objects
            return ResponseEntity.ok(watchLaterDTOList);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    
    public ResponseEntity<String> removeWatchlater(@PathVariable Long userId, @RequestBody Map<String, Long> payload) {
        Long videoId = payload.get("videoId");

        if (videoId == null) {
            return new ResponseEntity<>("Invalid request data", HttpStatus.BAD_REQUEST);
        }

        try {
            Optional<UserRegister> optionalUser = userregisterrepository.findById(userId);
            Optional<VideoDescription> optionalVideo = videodescriptionRepository.findById(videoId);

            if (optionalUser.isPresent() && optionalVideo.isPresent()) {
                UserRegister user = optionalUser.get();

                if (user.getWatchlaterIds().remove(videoId)) {
                    userregisterrepository.save(user);
                    return ResponseEntity.ok("Video removed from watchlater successfully");
                } else {
                    return ResponseEntity.badRequest().body("Video ID not found in user's watchlater");
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
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error removing video from watchlater: " + e.getMessage());
        }
    }

    //---------------------------------------------liked songs --------------------------------------------

    @Autowired
    private favouriteRepository favouriterepository;
    
    @Autowired
    private AddAudioRepository audiorepository;
    
    @Autowired
	private AddAudiodescription audio ;
    

    public ResponseEntity<String> createOrder(@RequestBody Map<String, Long> requestData) {
        try {
            Long audioId = requestData.get("audioId");
            Long userId = requestData.get("userId");

            if (audioId == null || userId == null) {
                return new ResponseEntity<>("Invalid request data", HttpStatus.BAD_REQUEST);
            }

            Optional<UserRegister> optionalUser = userregisterrepository.findById(userId);
            Optional<Audiodescription> optionalAudio = audio.findById(audioId);

            if (optionalUser.isPresent() && optionalAudio.isPresent()) {
                UserRegister user = optionalUser.get();

                // Check if the user has already added this audioId to favorites
                if (user.getFavoriteAudioIds().contains(audioId)) {
                    return ResponseEntity.badRequest().body("User has already added this audio to favourites");
                }

                // Add the audioId to the user's favoriteAudioIds
                user.getFavoriteAudioIds().add(audioId);
                userregisterrepository.save(user);

                return ResponseEntity.ok("Favourite audio added successfully");
            } else {
            	StringBuilder errorMessage = new StringBuilder();

                if (!optionalUser.isPresent()) {
                    errorMessage.append("User with ID ").append(userId).append(" not found. ");
                }
                if (!optionalAudio.isPresent()) {
                    errorMessage.append("Audio with ID ").append(audioId).append(" not found.");
                }

                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorMessage.toString().trim());
            }
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error adding to favourites: " + e.getMessage());
        }
    }
    
    
        
    public ResponseEntity<List<LikedsongsDTO>> getAudioForUsermobile(@PathVariable Long userId) {
    	Optional<UserRegister> optionalUser = userregisterrepository.findById(userId);
        if (optionalUser.isPresent()) {
            UserRegister user = optionalUser.get();
            // Get the set of favorite audio IDs
            Set<Long> favoriteAudioIdsSet = user.getFavoriteAudioIds();
         // Create a list to hold WatchLaterDTO objects
            List<LikedsongsDTO> LikedsongDTOList = new ArrayList<>();
            
            // Loop through each video ID and fetch video details (ID and Title)
            for (Long audioId : favoriteAudioIdsSet) {
                // Fetch video using repository and handle Optional
                Optional<Audiodescription> optionalAudio = audio.findById(audioId);
                
                if (optionalAudio.isPresent()) {
                	Audiodescription audio = optionalAudio.get();
                    
                    // Create a new WatchLaterDTO with video ID and video title
                	LikedsongsDTO likedDTO = new LikedsongsDTO(audio.getId(), audio.getAudio_title());
                    
                    // Add to the list
                	LikedsongDTOList.add(likedDTO);
                } else {
                    // Handle the case where the video does not exist (if needed)
                    // You can choose to log or skip the missing video
                    System.out.println("Video with ID " + audioId + " not found.");
                }
            }
            
            // Return the list of WatchLaterDTO objects
            return ResponseEntity.ok(LikedsongDTOList);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    
    public ResponseEntity<String> removeFavoriteAudio(@PathVariable Long userId, @RequestParam Long audioId) {
        try {
            if (audioId == null) {
                return new ResponseEntity<>("Invalid request data", HttpStatus.BAD_REQUEST);
            }

            Optional<UserRegister> optionalUser = userregisterrepository.findById(userId);
            Optional<Audiodescription> optionalAudio = audio.findById(audioId);
            
            if (optionalUser.isPresent() && optionalAudio.isPresent()) {
                UserRegister user = optionalUser.get();

                // Remove the audioId from the user's favoriteAudioIds
                if (user.getFavoriteAudioIds().remove(audioId)) {
                    userregisterrepository.save(user); // Save the updated user

                    return ResponseEntity.ok("Audio removed from favorites successfully");
                } else {
                    return ResponseEntity.badRequest().body("Audio ID not found in user's favorites");
                }
            } else {
                StringBuilder errorMessage = new StringBuilder();

                if (!optionalUser.isPresent()) {
                    errorMessage.append("User with ID ").append(userId).append(" not found. ");
                }
                if (!optionalAudio.isPresent()) {
                    errorMessage.append("Audio with ID ").append(audioId).append(" not found.");
                }

                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorMessage.toString().trim());
            }
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error removing audio from favorites: " + e.getMessage());
        }
    }





}
