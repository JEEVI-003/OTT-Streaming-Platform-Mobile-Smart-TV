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
import org.springframework.web.bind.annotation.RequestParam;

import com.VsmartEngine.MediaJungle.Container.VideoContainerController;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.model.Tag;
import com.VsmartEngine.MediaJungle.notification.service.NotificationService;
import com.VsmartEngine.MediaJungle.repository.AddUserRepository;
import com.VsmartEngine.MediaJungle.repository.TagRepository;
import com.VsmartEngine.MediaJungle.userregister.JwtUtil;


@Controller
public class TagController {
	
	@Autowired
	private TagRepository tagrepository;
	
	@Autowired
    private NotificationService notificationservice;
	
	@Autowired
	private JwtUtil jwtUtil; // Autowire JwtUtil
	
	@Autowired
	private AddUserRepository adduserrepository;

	private static final Logger logger = LoggerFactory.getLogger(TagController.class);

	public ResponseEntity<String> posttag(@RequestHeader("Authorization") String token,@RequestBody Tag data) {
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
		        Tag tag = tagrepository.save(data);
		        Long tagId = tag.getTag_id();
	            String tagName = tag.getTag(); // Adjust as needed
	            String heading = tagName + ": New Tag Added!";

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
	

	public ResponseEntity<List<Tag>> getAllTag() {
	    List<Tag> tag = tagrepository.findAll();
	    return new ResponseEntity<>(tag, HttpStatus.OK);
	}
	

	public ResponseEntity<Tag> getTagById(@PathVariable Long tagId) {
	    Optional<Tag> tagOptional = tagrepository.findById(tagId);
	    if (tagOptional.isPresent()) {
	    	Tag tag = tagOptional.get();
	        return new ResponseEntity<>(tag, HttpStatus.OK);
	    } else {
	        return ResponseEntity.notFound().build();
	    }
	}
	
		

    public ResponseEntity<?> deleteTag(@PathVariable Long tagId,@RequestHeader("Authorization") String token) {
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
		            Optional<Tag> optionaltag = tagrepository.findById(tagId);
		            if (optionaltag.isEmpty()) {
		                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "Category not found"));
		            }
		            Tag  tag = optionaltag.get();
		            String name = tag.getTag();
            // Assuming you have a method to delete a category by ID in your repository
        	tagrepository.deleteById(tagId);
        	// Create notification if category is deleted
            String heading = name + " Tag Deleted!";
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

	

	public ResponseEntity<String> editTag(@PathVariable Long tagId, @RequestBody Tag editTag,@RequestHeader("Authorization") String token) {
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
		        Tag existingTag = tagrepository.findById(tagId)
		                .orElseThrow(() -> new RuntimeException("Tag not found"));
		        
		        String tag = existingTag.getTag();

		        // Apply partial updates to the existing user data
		        if (editTag.getTag() != null) {
		        	existingTag.setTag(editTag.getTag());
		        }
		        
		        String newtag = existingTag.getTag();
		     // Save the updated user data back to the repository
		        Tag details =tagrepository.save(existingTag);
		        // Create notification for the user who updated the setting
	 	        String heading = tag +" category upadted to " + newtag;
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

		        return new ResponseEntity<>("Tag details updated successfully", HttpStatus.OK);
		   }
		   
		   catch (Exception e) {
			   logger.error("", e);
		        return new ResponseEntity<>("Error updating Tag details", HttpStatus.INTERNAL_SERVER_ERROR);
		    }
	}
		   
	
	public ResponseEntity<List<String>> gettagNamesByIds(@RequestParam List<Long> tagIds) {
	    List<String> tagNames = tagrepository.findtagByIds(tagIds);

	    if (tagNames.isEmpty()) {
	        return ResponseEntity.notFound().build();
	    } else {
	        return new ResponseEntity<>(tagNames, HttpStatus.OK);
	    }
	}


}
