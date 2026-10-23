package com.VsmartEngine.MediaJungle.notification.controller;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.compresser.ImageUtils;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.notification.NotificationDetails;
import com.VsmartEngine.MediaJungle.notification.repository.NotificationAdminRepository;
import com.VsmartEngine.MediaJungle.notification.repository.NotificationDetailsRepository;
import com.VsmartEngine.MediaJungle.notification.repository.NotificationUserRepository;
import com.VsmartEngine.MediaJungle.notification.service.NotificationService;
import com.VsmartEngine.MediaJungle.repository.AddUserRepository;
import com.VsmartEngine.MediaJungle.userregister.JwtUtil;
import com.VsmartEngine.MediaJungle.userregister.UserRegister;
import com.VsmartEngine.MediaJungle.userregister.UserRegisterRepository;

@Controller
public class NotificationController {
	
	@Autowired
	private NotificationDetailsRepository notificationdetails;
	
	@Autowired
	private NotificationUserRepository notificationuser;
	
	@Autowired
	private NotificationAdminRepository notificationadmin;
	
	@Autowired
	private UserRegisterRepository userregisterrepository;
	 
	@Autowired
	private AddUserRepository adduserrepository;
	
	 @Autowired
	 private JwtUtil jwtUtil;
	 
	 @Autowired
	 private NotificationService notificationservice;
	 
	 private static final Logger logger = LoggerFactory.getLogger(NotificationController.class);

	 
	 public ResponseEntity<?>GetAllNotification(@RequestHeader("Authorization") String token){
			try {

		         if (!jwtUtil.validateToken(token)) {
		             return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
		         }
		         String email=jwtUtil.getUsernameFromToken(token);
		         Optional<AddUser> opmuser= adduserrepository.findByUsername(email);
		         if(opmuser.isPresent()) {
		        	 AddUser user=opmuser.get();
		        	 LocalDate today=LocalDate.now();
		        	 List<Long> ids=notificationadmin.findNotificationIdsByadminId(user.getId(),today);

	              	 List<Object> notimap = new ArrayList<>();
		        	 for(Long id:ids) {
		        		 
		        		Optional<NotificationDetails> opnotidetails=notificationdetails.findById(id);
		        		 if (opnotidetails.isPresent()) {
		        			 NotificationDetails notidetails=opnotidetails.get();
		        			 if(notidetails.getNotimage() !=null) {
		        			 try {
		        				 byte[] images = ImageUtils.decompressImage(notidetails.getNotimage()); 
		        				 notidetails.setNotimage(images);
		        	            } catch (Exception e) {
		        	                e.printStackTrace();
		        	                logger.error("", e);
		        	            }
		        			 }
		        			 notimap.add(notidetails);
				            }
		        		 
		        		 
		        	 }
		        	 return ResponseEntity.ok(notimap);
		         }else {
		        	 return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
		         }
		         
			}catch (Exception e) {
				logger.error("", e);
		        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred");
	        }
		}
	 
	 
	 public ResponseEntity<?>GetuserNotification(@RequestHeader("Authorization") String token){
			try {

		         if (!jwtUtil.validateToken(token)) {
		             return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
		         }
		         String email=jwtUtil.getUsernameFromToken(token);
		         Optional<UserRegister> opmuser= userregisterrepository.findByEmail(email);
		         if(opmuser.isPresent()) {
		        	 UserRegister user=opmuser.get();
		        	 LocalDate today=LocalDate.now();
		        	 List<Long> ids=notificationuser.findNotificationIdsByUserId(user.getId(),today);

	              	 List<Object> notimap = new ArrayList<>();
		        	 for(Long id:ids) {
		        		 
		        		Optional<NotificationDetails> opnotidetails=notificationdetails.findById(id);
		        		 if (opnotidetails.isPresent()) {
		        			 NotificationDetails notidetails=opnotidetails.get();
		        			 if(notidetails.getNotimage() !=null) {
		        			 try {
		        				 byte[] images = ImageUtils.decompressImage(notidetails.getNotimage()); 
		        				 notidetails.setNotimage(images);
		        	            } catch (Exception e) {
		        	                e.printStackTrace();
		        	                logger.error("", e);
		        	            }
		        			 }
		        			 notimap.add(notidetails);
				            }
		        		 
		        		 
		        	 }
		        	 return ResponseEntity.ok(notimap);
		         }else {
		        	 return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
		         }
		         
			}catch (Exception e) {
				logger.error("", e);
		        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred");
	        }
		}

	 

	 
	    public ResponseEntity<?> markAllAsRead(@RequestHeader("Authorization") String token) {
	        try {
	            if (!jwtUtil.validateToken(token)) {
	                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
	            }
	            String email = jwtUtil.getUsernameFromToken(token);
	            Optional<AddUser> opUser = adduserrepository.findByUsername(email);
	            if (opUser.isPresent()) {
	                AddUser user = opUser.get();
	                notificationservice.markAllAsRead(user.getId());
	                return ResponseEntity.ok("All notifications marked as read");
	            } else {
	                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
	            }
	        } catch (Exception e) {
	        	logger.error("", e);
	            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred");
	        }
	    }
	 
	 

	    public ResponseEntity<?> markAllAsReaduser(@RequestHeader("Authorization") String token) {
	        try {
	            if (!jwtUtil.validateToken(token)) {
	                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
	            }
	            String email = jwtUtil.getUsernameFromToken(token);
	            Optional<UserRegister> opUser = userregisterrepository.findByEmail(email);
	            if (opUser.isPresent()) {
	                UserRegister user = opUser.get();
	                notificationservice.markAllAsReaduser(user.getId());
	                return ResponseEntity.ok("All notifications marked as read");
	            } else {
	                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
	            }
	        } catch (Exception e) {
	        	logger.error("", e);
	            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred");
	        }
	    }



		public ResponseEntity<?> UreadCount(@RequestHeader("Authorization") String token) {
			try {
		         if (!jwtUtil.validateToken(token)) {
		             return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
		         }
		         String email=jwtUtil.getUsernameFromToken(token);
		         Optional<AddUser> adminuser= adduserrepository.findByUsername(email);
		         if(adminuser.isPresent()) {
		        	 AddUser user=adminuser.get();
		        	 LocalDate today=LocalDate.now();
		        	 Long count=notificationadmin.CountUnreadNotificationOftheUser(user.getId(), false,today);
		        	 return ResponseEntity.ok(count);
		         }
		         else {
		        	 return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
		         }	
		}catch (Exception e) {
			logger.error("", e);
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred");
	    }

	}
		

		public ResponseEntity<?> UreadCountuser(@RequestHeader("Authorization") String token) {
			try {

		         if (!jwtUtil.validateToken(token)) {
		             return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
		         }
		         String email=jwtUtil.getUsernameFromToken(token);
		         Optional<UserRegister> opmuser= userregisterrepository.findByEmail(email);
		         if(opmuser.isPresent()) {
		        	 UserRegister user=opmuser.get();
		        	 LocalDate today=LocalDate.now();
		        	 Long count=notificationuser.CountUnreadNotificationOftheUser(user.getId(), false,today);
		        	 return ResponseEntity.ok(count);
		         }
		         else {
		        	 return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
		         }
		         
			
		}catch (Exception e) {
			logger.error("", e);
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred");
	    }

	}
		
		@GetMapping("/clearAll")
		public ResponseEntity<?>ClearAll(@RequestHeader("Authorization") String token){
			 
			try {
				if (!jwtUtil.validateToken(token)) {
	             return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
	         }
	         String email=jwtUtil.getUsernameFromToken(token);        
	         Optional<AddUser> adminuser= adduserrepository.findByUsername(email);
	         if(adminuser.isPresent()) {
	        	 AddUser user=adminuser.get();
	        	 Long id=user.getId();
	        	 List<Long> ids=notificationadmin.findprimaryIdsByadminId(id);
	        	 for(Long singleid :ids) {
	        		 notificationadmin.deleteById(singleid);
	        	 }
	        	 return ResponseEntity.ok().build();	 
	         }
	         
	         else {
	        	 return ResponseEntity.status(HttpStatus.NOT_FOUND).build(); 
	         }
			}catch (Exception e) {
				e.printStackTrace();
				logger.error("", e);
	             return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred");
	         }
		}
		
		
		@GetMapping("/clearAlluser")
		public ResponseEntity<?>ClearAlluser(@RequestHeader("Authorization") String token){
			 
			try {
				if (!jwtUtil.validateToken(token)) {
	             return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
	         }
	         String email=jwtUtil.getUsernameFromToken(token);
	         
	         Optional<UserRegister> opmuser= userregisterrepository.findByEmail(email);
	         if(opmuser.isPresent()) {
	        	 UserRegister user=opmuser.get();
	        	 Long id=user.getId();
	        	 List<Long> ids=notificationuser.findprimaryIdsByUserId(id);
	        	 for(Long singleid :ids) {
	        		 notificationuser.deleteById(singleid);
	        	 }
	        	 return ResponseEntity.ok().build();	 
	         }
	         else {
	        	 return ResponseEntity.status(HttpStatus.NOT_FOUND).build(); 
	         }
			}catch (Exception e) {
				e.printStackTrace();
				logger.error("", e);
	             return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred");
	         }
		}


}
	


