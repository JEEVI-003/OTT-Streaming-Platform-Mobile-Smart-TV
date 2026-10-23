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
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.VsmartEngine.MediaJungle.Container.VideoContainerController;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.model.PlanDetails;
import com.VsmartEngine.MediaJungle.notification.service.NotificationService;
import com.VsmartEngine.MediaJungle.repository.AddUserRepository;
import com.VsmartEngine.MediaJungle.repository.PlanDetailsRepository;
import com.VsmartEngine.MediaJungle.userregister.JwtUtil;


@RestController
@RequestMapping("/api/v2")
@CrossOrigin(origins = "*")
public class PlanDetailsController {
	
	@Autowired
	private PlanDetailsRepository planrepository;
	
	@Autowired
	private NotificationService notificationservice;
	
	@Autowired
	private JwtUtil jwtUtil; // Autowire JwtUtil
	
	
	
	@Autowired
	private PlanFeatureMergeController PlanFeatureMergeController;
	
	
	@Autowired
	private AddUserRepository adduserrepository;
	
	
	private static final Logger logger = LoggerFactory.getLogger(PlanDetailsController.class);


	public ResponseEntity<?> planDetails(@RequestParam("planname")String planname,
			@RequestParam("amount") double amount,
			@RequestParam("validity") int validity,
			@RequestHeader("Authorization") String token){
		 try {
		        if (!jwtUtil.validateToken(token)) {
		            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token");
		        }

		        String email = jwtUtil.getUsernameFromToken(token);
		        Optional<AddUser> opUser = adduserrepository.findByUsername(email);

		        if (opUser.isPresent()) {
		            AddUser user = opUser.get();
		            String username = user.getUsername();
		             PlanDetails pay = new PlanDetails();
		             pay.setPlanname(planname);
		             pay.setAmount(amount);
		             pay.setValidity(validity);
		             PlanDetails details = planrepository.save(pay);	
		             System.out.println("Idlfsjdfjsafasjdflkasjdfklasjfk");
		             System.out.println(details.getId());
		             Long planId = details.getId();
			            String Name = details.getPlanname();
			            String heading = Name + " New Plan Added!";
			            // Create notification with optional file (thumbnail)
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
	

    public ResponseEntity<List<PlanDetails>> getAllPlanDetails() {
        List<PlanDetails> getPlan = planrepository.findAll();
        return new ResponseEntity<>(getPlan, HttpStatus.OK);
    }
    @PostMapping("/plans")
    public ResponseEntity<PlanDetails> getPlanById(@PathVariable Long id) {
        Optional<PlanDetails> planOptional = planrepository.findById(id);
        
        if (planOptional.isPresent()) {
            return ResponseEntity.ok(planOptional.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }


    public ResponseEntity<?> deletePlan(@PathVariable Long planId, @RequestHeader("Authorization") String token) {
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        try {
            if (!jwtUtil.validateToken(token)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid token"));
            }

            String email = jwtUtil.getUsernameFromToken(token);
            Optional<AddUser> optionalUser = adduserrepository.findByUsername(email);

            if (optionalUser.isPresent()) {
                AddUser user = optionalUser.get();
                String username = user.getUsername();

                Optional<PlanDetails> optionalPlan = planrepository.findById(planId);
                if (optionalPlan.isEmpty()) {
                    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "Plan not found"));
                }

                // Delete the plan
                planrepository.deleteById(planId);

                // Create notification
                String name = optionalPlan.get().getPlanname();
                String heading = name + " Plan Deleted!";
                Long notifyId = notificationservice.createNotification(username, email, heading);

                if (notifyId != null) {
                    // Notify all admins
                    Set<String> notiUserSet = new HashSet<>();
                    List<AddUser> adminUsers = adduserrepository.findAll();
                    for (AddUser admin : adminUsers) {
                        notiUserSet.add(admin.getEmail());
                    }
                    notificationservice.CommoncreateNotificationAdmin(notifyId, new ArrayList<>(notiUserSet));
                }

                return ResponseEntity.noContent().build(); // 204 No Content
            } else {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "User not authorized"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", "Internal server error"));
        }
    }
    public ResponseEntity<String> editplans(@PathVariable Long planId, @RequestBody PlanDetails updatedPlanDetails,@RequestHeader("Authorization") String token) {
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
            PlanDetails existingplan = planrepository.findById(planId)
                    .orElseThrow(() -> new RuntimeException("Plan not found"));
            
            String plan = existingplan.getPlanname();

            // Apply partial updates to the existing plan data
            if (updatedPlanDetails.getPlanname() != null) {
                existingplan.setPlanname(updatedPlanDetails.getPlanname());
            }

            if (updatedPlanDetails.getAmount() != 0) {
                existingplan.setAmount(updatedPlanDetails.getAmount());
            }

            if (updatedPlanDetails.getValidity() != 0) {
                existingplan.setValidity(updatedPlanDetails.getValidity());
            }
            
            String newplan = existingplan.getPlanname();
            


            planrepository.save(existingplan);
            
            String heading = newplan + " plan updated ";
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

            return new ResponseEntity<>("Plan details updated successfully", HttpStatus.OK);
        } catch (RuntimeException e) {
        	logger.error("", e);
            return new ResponseEntity<>("Plan not found", HttpStatus.NOT_FOUND);
        } catch (Exception e) {
        	logger.error("", e);
            return new ResponseEntity<>("Error updating plan details", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

	}
	

	


