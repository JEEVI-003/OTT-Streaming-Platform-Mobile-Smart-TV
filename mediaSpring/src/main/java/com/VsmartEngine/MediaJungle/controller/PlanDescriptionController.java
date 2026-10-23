package com.VsmartEngine.MediaJungle.controller;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;

import com.VsmartEngine.MediaJungle.Container.VideoContainerController;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.model.PlanDescription;
import com.VsmartEngine.MediaJungle.repository.AddUserRepository;
import com.VsmartEngine.MediaJungle.repository.PlanDescriptionRepository;
import com.VsmartEngine.MediaJungle.userregister.JwtUtil;


@Controller
public class PlanDescriptionController {
	
	@Autowired
	private PlanDescriptionRepository plandescriptionrepository;
	
	@Autowired
	private JwtUtil jwtUtil; // Autowire JwtUtil
	
	@Autowired
	private AddUserRepository adduserrepository;
	
	private static final Logger logger = LoggerFactory.getLogger(PlanDescriptionController.class);


	public ResponseEntity<?> addPlanDescription(@RequestParam("description") String description,
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
	        PlanDescription plan = new PlanDescription();
	        plan.setDescription(description);

	        // Save the PlanDescription in the repository
	        PlanDescription savedPlanDescription = plandescriptionrepository.save(plan);

	        // Optionally, you can create a notification or perform other actions here
	        
	        return ResponseEntity.ok(savedPlanDescription);
	    } catch (Exception e) {
	    	logger.error("", e);
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error adding plan description.");
	    }
	}
	public ResponseEntity<List<PlanDescription>> getAllDescriptions() {
	    List<PlanDescription> descriptions = plandescriptionrepository.findAll();
	    System.out.println("descri____ptions");
	    System.out.println(descriptions);
	    return new ResponseEntity<>(descriptions, HttpStatus.OK);
	}

	public ResponseEntity<?> addActiveStatus(
	        @PathVariable Long id,
	        @RequestParam("active") String active,
	        @RequestHeader("Authorization") String token
	) {
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

	        // Fetch the plan description from repository
	        Optional<PlanDescription> optionalPlan = plandescriptionrepository.findById(id);
	        if (optionalPlan.isPresent()) {
	            PlanDescription plan = optionalPlan.get();
	            plan.setActive(active);

	            // Save the updated plan description
	            PlanDescription updatedPlan = plandescriptionrepository.save(plan);

	            // Optionally, you can create a notification or perform other actions here

	            return ResponseEntity.ok(updatedPlan); // Return 200 OK with the updated plan description
	        } else {
	            return ResponseEntity.notFound().build(); // Return 404 Not Found if plan with id is not found
	        }
	    } catch (Exception e) {
	    	logger.error("", e);
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error updating active status.");
	    }
	}
	

	public ResponseEntity<?> deletedescription(@PathVariable Long id, @RequestHeader("Authorization") String token) {
	    try {
	        // Validate JWT token
	        if (!jwtUtil.validateToken(token)) {
	            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid token"));
	        }

	        // Extract username from token
	        String email = jwtUtil.getUsernameFromToken(token);
	        System.out.println("email: " + email);

	        // Fetch user details from repository
	        Optional<AddUser> optionalUser = adduserrepository.findByUsername(email);
	        if (!optionalUser.isPresent()) {
	            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "User not authorized"));
	        }

	        // Delete plan description by ID
	        plandescriptionrepository.deleteById(id);

	        return ResponseEntity.noContent().build();
	    } catch (Exception e) {
	    	logger.error("", e);
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
	    }
	}


	
	
	
}
