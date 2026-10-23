package com.VsmartEngine.MediaJungle.Banner;

import java.util.Collections;
import java.util.Comparator;
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
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.model.AudioMovieNameBanner;
import com.VsmartEngine.MediaJungle.model.Audiodescription;
import com.VsmartEngine.MediaJungle.model.MovieName;
import com.VsmartEngine.MediaJungle.repository.AddAudiodescription;
import com.VsmartEngine.MediaJungle.repository.AudioMovieNameBannerRepository;
import com.VsmartEngine.MediaJungle.repository.MovieNameRepository;
import com.VsmartEngine.MediaJungle.userregister.UserRegister;
import com.VsmartEngine.MediaJungle.userregister.UserRegisterRepository;

@CrossOrigin()
@RestController
@RequestMapping("/api/v2/")
public class AudioBannerController {
	
	@Autowired
	private AudiobannerRepository audiobannerrepository;
	
	@Autowired
	private AddAudiodescription audio;
	
	@Autowired
	private AudioMovieNameBannerRepository audiomovienamebannerrepository;
	
	@Autowired
	private MovieNameRepository MovieNameRepository;
	
	@Autowired
    private UserRegisterRepository userregisterrepository;
	
	private static final Logger logger = LoggerFactory.getLogger(AudioBannerController.class);

	@PostMapping("/createaudiobanner")
	public ResponseEntity<?> createAudioBanner(@RequestBody List<AudioBanner> audioBannerRequest) {
		try {
	        for (int i = 0; i < audioBannerRequest.size(); i++) {
	            AudioBanner container = audioBannerRequest.get(i);
	            Long id = container.getId();  // Use the wrapper class 'Long' to allow null values
	            
	            if (id == null || id == 0) {  // Handle null or new records (id == 0)
	                System.out.println("Creating new container. Id: " + id);
	                audiobannerrepository.save(container);  // Save new container
	            } else {
	                // Update existing container
	                Optional<AudioBanner> containerData = audiobannerrepository.findById(id);
	                
	                if (containerData.isPresent()) {
	                    AudioBanner edit = containerData.get();
	                    edit.setMovienameID(container.getMovienameID());
	                    audiobannerrepository.save(edit);  // Save updated container
	                } else {
	                    return ResponseEntity.status(HttpStatus.NOT_FOUND)
	                                         .body("banner with id " + id + " not found");
	                }
	            }
	        }
	        return ResponseEntity.ok().build();
	    } catch (Exception e) {
	        e.printStackTrace();  // Print the stack trace for debugging
	        logger.error("", e);
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
	                             .body("An error occurred while processing the banner: " + e.getMessage());
	    }
	}
	
	@GetMapping("/getallaudiobanner")
	public ResponseEntity<List<AudioBanner>> getAllAudioBanner() {
	    try {
	        // Fetch all video banners from the database
	        List<AudioBanner> audioBanners = audiobannerrepository.findAll();

	        // Sort the list by id
	        audioBanners.sort(Comparator.comparing(AudioBanner::getId)); // Assuming getId() returns the id

	        // Return the sorted list of video banners
	        return ResponseEntity.ok(audioBanners);
	        
	    } catch (Exception e) {
	        // Log the exception if needed
	        e.printStackTrace(); // Optional: Print the stack trace for debugging
	        logger.error("", e);
	        // Return an error response
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
	                             .body(null); // You might want to return a specific message here
	    }
	}


        @DeleteMapping("/deleteaudiobanner/{id}")
	   	public ResponseEntity<?> Deleteaudiobanner(@PathVariable("id") long id) {
	   		
	    	audiobannerrepository.deleteById(id);
	    	return ResponseEntity.ok().build();
	   	}
       
        
//        @GetMapping("/getaudiodetails/{movie_name}")
//        public ResponseEntity<?> getaudiodetailsbyId(@PathVariable("movie_name") long movie_name){
//        	List<Audiodescription> optionaladddescription = audio.findMovie_nameById(movie_name); 
//        	
//        	
//        	 if (!optionaladddescription.isEmpty()) {
//        	        return ResponseEntity.ok(optionaladddescription); // Return the list if found
//        	    } else {
//        	        return ResponseEntity.status(HttpStatus.NOT_FOUND)
//        	                             .body("No audio details found for movie name: " + movie_name);
//        	    }
//        	
//        }
        
        
        @GetMapping("/getaudiodetails/{movie_name}/{userid}")
        public ResponseEntity<?> getAudioDetailsByMovieName(
                @PathVariable("movie_name") long movie_name, 
                @PathVariable("userid") long userid) {
            // Fetch audio descriptions by movie name
            List<Audiodescription> audioDescriptions = audio.findMovie_nameById(movie_name);
            
            // Check if the list is empty
            if (audioDescriptions.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body("No audio details found for movie name: " + movie_name);
            }

            // Fetch the movie name using the movie ID
            Optional<MovieName> optionalMovieName = MovieNameRepository.findById(movie_name);
            if (optionalMovieName.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body("No movie details found for movie ID: " + movie_name);
            }
            String movieName = optionalMovieName.get().getMovie_name(); // Extract the movie name

            // Fetch user details to get favorite audio IDs
            Optional<UserRegister> optionalUser = userregisterrepository.findById(userid);
            final Set<Long> favoriteAudioIdsSet = optionalUser.map(UserRegister::getFavoriteAudioIds)
                                                              .orElse(Collections.emptySet()); // Default empty set if user not found

            // Map Audiodescription to AudioBannerDTO and set the movie name
            List<AudioBannerDTO> audioBannerDTOList = audioDescriptions.stream().map(desc -> {
                AudioBannerDTO dto = new AudioBannerDTO();
                dto.setMoviename(movieName); // Set the fetched movie name
                dto.setId(desc.getId());
                dto.setAudio_title(desc.getAudio_title());
                dto.setLike(favoriteAudioIdsSet.contains(desc.getId())); // Check if the ID is in favorites
                dto.setAudio_file_name(desc.getAudio_file_name());
                dto.setAudio_Duration(desc.getAudio_Duration());
                return dto;
            }).toList();

            // Return the DTO list as the response
            return ResponseEntity.ok(audioBannerDTOList);
        }

}
