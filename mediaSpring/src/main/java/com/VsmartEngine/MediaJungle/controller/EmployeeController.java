package com.VsmartEngine.MediaJungle.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.VsmartEngine.MediaJungle.Container.VideoContainerController;
import com.VsmartEngine.MediaJungle.compresser.ImageUtils;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.model.Companysiteurl;
import com.VsmartEngine.MediaJungle.model.Contactsettings;
import com.VsmartEngine.MediaJungle.model.Emailsettings;
import com.VsmartEngine.MediaJungle.model.Mobilesettings;
import com.VsmartEngine.MediaJungle.model.Othersettings;
import com.VsmartEngine.MediaJungle.model.Seosettings;
import com.VsmartEngine.MediaJungle.model.Sitesetting;
import com.VsmartEngine.MediaJungle.model.SocialSettings;
import com.VsmartEngine.MediaJungle.model.Videosettings;
import com.VsmartEngine.MediaJungle.notification.service.NotificationService;
import com.VsmartEngine.MediaJungle.repository.AddUserRepository;
import com.VsmartEngine.MediaJungle.repository.CompanysiteurlRepository;
import com.VsmartEngine.MediaJungle.repository.ContactsettingsRepository;
import com.VsmartEngine.MediaJungle.repository.EmailsettingRepository;
import com.VsmartEngine.MediaJungle.repository.MobilesettingRepository;
import com.VsmartEngine.MediaJungle.repository.OthersettingRepository;
import com.VsmartEngine.MediaJungle.repository.PaymentsettingRepository;
import com.VsmartEngine.MediaJungle.repository.SeosettingsRepository;
import com.VsmartEngine.MediaJungle.repository.SocialSettingsRepository;
import com.VsmartEngine.MediaJungle.repository.siteSettingRepository;
import com.VsmartEngine.MediaJungle.repository.videoSettingRepository;
import com.VsmartEngine.MediaJungle.userregister.JwtUtil;
import com.VsmartEngine.MediaJungle.video.VideoImage;


@Controller
public class EmployeeController {

	@Autowired
	private siteSettingRepository siteSetting ;
	@Autowired
	private videoSettingRepository videosetting;
	@Autowired
	private SocialSettingsRepository socialsetting;
	@Autowired
	private CompanysiteurlRepository companysiteurl;
	@Autowired
	private EmailsettingRepository emailsetting;
	@Autowired
	private MobilesettingRepository mobilesetting;
	@Autowired
	private PaymentsettingRepository paymentsetting;
	@Autowired
	private OthersettingRepository othersetting;
	@Autowired
	private ContactsettingsRepository contactsetting;
	@Autowired
	private SeosettingsRepository seosetting;
	@Autowired
    private NotificationService notificationservice;
	
	@Autowired
	private JwtUtil jwtUtil; // Autowire JwtUtil
	
	@Autowired
	private AddUserRepository adduserrepository;
	
	private static final Logger logger = LoggerFactory.getLogger(EmployeeController.class);

	
//	@GetMapping("/employees")
//	public List<sample> getAllEmployees() {
//		return employeeRepository.findAll();
//	}
	
	
//	--------------------Othersettings -----------------------------
	
//	@PostMapping("/Othersettings")
//	public Othersettings createEmployee(@RequestBody Othersettings data) {
//		return othersetting.save(data);
//	}

	public ResponseEntity<?> addothersetting(@RequestHeader("Authorization") String token,@RequestParam("appstore") String appstore,
			@RequestParam("playstore") String playstore){
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
		        Othersettings other = new Othersettings() ;
		        other.setAppstore(appstore);
		        other.setPlaystore(playstore);
		        Othersettings details = othersetting.save(other);
		        // Assuming you need to create a notification for a new category
	            Long Id = details.getId();
	            String heading = "Othersetting Added!";

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
	

	public ResponseEntity<List<Othersettings>> getOthersettings() {
	    List<Othersettings> othersettingss = othersetting.findAll();
	    return new ResponseEntity<>(othersettingss, HttpStatus.OK);
	}
	

	public ResponseEntity<String> editothersetting(@PathVariable Long id, @RequestBody Othersettings updatedothersetting,
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

	        // Retrieve existing Othersettings from the repository
	        Othersettings existingsetting = othersetting.findById(id)
	                .orElseThrow(() -> new RuntimeException("Setting not found"));

	        // Apply partial updates to the existing Othersettings
	        if (updatedothersetting.getAppstore() != null) {
	            existingsetting.setAppstore(updatedothersetting.getAppstore());
	        }
	        if (updatedothersetting.getPlaystore() != null) {
	            existingsetting.setPlaystore(updatedothersetting.getPlaystore());
	        }

	        // Save updated Othersettings
	        Othersettings details = othersetting.save(existingsetting);

	        // Create notification for the user who updated the setting
	        String heading = "Othersetting Updated!";
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
         // Return success response
            return ResponseEntity.ok("Updated successfully");

        } catch (RuntimeException e) {
            // Handle not found exception
        	logger.error("", e);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Setting not found");

        } catch (Exception e) {
            // Handle other exceptions
        	logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error when updating");
        }
    }


//	--------------------working

	public ResponseEntity<?> addCompanysiteurl(@RequestBody Companysiteurl data) {
	   companysiteurl.save(data);
	   return ResponseEntity.ok("Success");
	   
	}
	

	public ResponseEntity<List<Companysiteurl>> getcompanysiteurl(){
		List<Companysiteurl> companysiteurll = companysiteurl.findAll();
		return new ResponseEntity<>(companysiteurll, HttpStatus.OK);
	}
	
//	--------------------working

	public ResponseEntity<?>  addSeosettings(@RequestBody Seosettings data) {
	 seosetting.save(data);
	 return ResponseEntity.ok("Success");
	}
	

	public ResponseEntity<List<Seosettings>> getseoSettings(){
		List<Seosettings> seosettingss = seosetting.findAll();
		return new ResponseEntity<>(seosettingss, HttpStatus.OK);
	}
	
//	--------------------working

	public ResponseEntity<?> contactsetting(@RequestHeader("Authorization") String token,@RequestParam("contact_email") String contact_email,
			@RequestParam("contact_mobile") String contact_mobile,
			@RequestParam("contact_address") String contact_address,
			@RequestParam("copyright_content") String copyright_content) {
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
		        Contactsettings contact = new Contactsettings();
		        contact.setContact_email(contact_email);
		        contact.setContact_mobile(contact_mobile);
		        contact.setContact_address(contact_address);
		        contact.setCopyright_content(copyright_content);
		        Contactsettings detail = contactsetting.save(contact);
		        Long Id = detail.getId();
	            String heading = "Contact Added!";

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
	                return ResponseEntity.ok(detail);
		        } else {
		            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
		        }
		    } catch (Exception e) {
		    	logger.error("", e);
		        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred: " + e.getMessage());
		    }
		}

	

	public ResponseEntity<List<Contactsettings>> getcontactsettings(){
		List<Contactsettings> contactsettingss = contactsetting.findAll();
		return new ResponseEntity<>(contactsettingss, HttpStatus.OK);
	}
	


public ResponseEntity<String> editcontact(@PathVariable Long id, 
        @RequestParam(required = false) String contact_email,
        @RequestParam(required = false) String contact_mobile,
        @RequestParam(required = false) String contact_address,
        @RequestParam(required = false) String copyright_content,
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

        // Retrieve existing Contactsettings from the repository
        Contactsettings existingSetting = contactsetting.findById(id)
                .orElseThrow(() -> new RuntimeException("Contact setting not found"));

        // Apply partial updates to the existing Contactsettings
        if (contact_email != null) {
            existingSetting.setContact_email(contact_email);
        }
        if (contact_mobile != null) {
            existingSetting.setContact_mobile(contact_mobile);
        }
        if (contact_address != null) {
            existingSetting.setContact_address(contact_address);
        }
        if (copyright_content != null) {
            existingSetting.setCopyright_content(copyright_content);
        }

        // Save updated Contactsettings
        Contactsettings details = contactsetting.save(existingSetting);

        // Create notification for the user who updated the setting
        String heading = "Contact Setting Updated!";
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

         // Return success response
            return ResponseEntity.ok("Contact updated successfully");

        } catch (RuntimeException e) {
            // Log the error for debugging
        	logger.error("", e);
            System.err.println("Runtime exception: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Contact setting not found");

        } catch (Exception e) {
            // Log the error for debugging
        	logger.error("", e);
            System.err.println("Exception: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error when updating contact");
        }
    }

	
	
//	--------------------working
//	@PostMapping("/Paymentsettings")
//	public Paymentsettings createEmployee(@RequestBody Paymentsettings data) {
//		return paymentsetting.save(data);
//	}
//	
//	@GetMapping("/GetpaymentSettings")
//	public ResponseEntity<List<Paymentsettings>> getpaymentsettings(){
//		List<Paymentsettings> paymentsettingss = paymentsetting.findAll();
//		return new ResponseEntity<>(paymentsettingss, HttpStatus.OK);
//	}
	
//	--------------------working

	public ResponseEntity<?> addEmailsettings(@RequestBody Emailsettings data) {

		emailsetting.save(data);
		return ResponseEntity.ok("Success");
	}
	

	public ResponseEntity<List<Emailsettings>> getemailsettings(){
		List<Emailsettings> emailsettingss = emailsetting.findAll();
		return new ResponseEntity<>(emailsettingss, HttpStatus.OK);
	}
//	--------------------working

	public ResponseEntity<?> addMobilesettings(@RequestBody Mobilesettings data) {

		mobilesetting.save(data);
		return ResponseEntity.ok("Success");
	}

	

	public ResponseEntity<List<Mobilesettings>> getmobilesettings(){
		List<Mobilesettings> mobilesettingss = mobilesetting.findAll();
		return new ResponseEntity<>(mobilesettingss, HttpStatus.OK);
	}
	
//	--------------------working

	public ResponseEntity<?> addsitesetting(@RequestParam("sitename") String sitename,
			@RequestParam("appurl") String appurl,
			@RequestParam("tagName") String tagName,
			@RequestParam("icon") MultipartFile icon,
			@RequestParam("logo") MultipartFile logo,
			@RequestHeader("Authorization") String token) throws IOException {
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
			Sitesetting setting = new Sitesetting();
			byte[] thumbnailBytes =ImageUtils.compressImage(icon.getBytes());
			byte[] thumbnailByte =ImageUtils.compressImage(logo.getBytes());
			setting.setSitename(sitename);
			setting.setAppurl(appurl);
			setting.setTagName(tagName);
			setting.setIcon(thumbnailBytes);
			setting.setLogo(thumbnailByte);
			Sitesetting details = siteSetting.save(setting);
			Long Id = details.getId();
	        String heading = "Sitesetting details  Added!";

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
	

	public ResponseEntity<List<Sitesetting>> getsitesettings(){
		List<Sitesetting> sitesettingss = siteSetting.findAll();
		 for (Sitesetting cast : sitesettingss) {
	            byte[] logo = ImageUtils.decompressImage(cast.getLogo());
	            cast.setLogo(logo);
	            byte[] icon = ImageUtils.decompressImage(cast.getIcon());
	            cast.setIcon(icon);
	        }
		return new ResponseEntity<>(sitesettingss, HttpStatus.OK);
	}
	
	
	public ResponseEntity<byte[]> getlogoThumbnail(@PathVariable long Id) {
	    try {
	        // Fetch the video image from the repository
	        Optional<Sitesetting> logoImageOptional = siteSetting.findById(Id);

	        if (logoImageOptional .isPresent()) {
	        	Sitesetting Image = logoImageOptional.get();

	            // Decompress the image bytes
	            byte[] decompressedVideoThumbnail = ImageUtils.decompressImage(Image.getLogo());

	            // Return the decompressed image data directly with the correct content type
	            return ResponseEntity.ok()
	                                 .contentType(MediaType.IMAGE_PNG) // Or use MediaType.IMAGE_PNG for PNG images
	                                 .body(decompressedVideoThumbnail);
	        } else {
	            return ResponseEntity.notFound().build();
	        }
	    } catch (Exception e) {
	        e.printStackTrace();  // Replace with proper logging in production
	        logger.error("", e);
	        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
	    }
	}
	

	    public ResponseEntity<String> editSetting(
	        @PathVariable Long id, 
	        @RequestParam(required = false) String sitename,
	        @RequestParam(required = false) String appurl,
	        @RequestParam(required = false) String tagName,
	        @RequestParam(required = false) MultipartFile icon,
	        @RequestParam(required = false) MultipartFile logo,
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
	            // Retrieve existing setting data from the repository
	            Sitesetting existingSetting = siteSetting.findById(id)
	                    .orElseThrow(() -> new RuntimeException("Setting not found"));

	            // Apply partial updates to the existing setting data
	            if (sitename != null) {
	                existingSetting.setSitename(sitename);
	            }
	            if (appurl != null) {
	                existingSetting.setAppurl(appurl);
	            }
	            if (tagName != null) {
	                existingSetting.setTagName(tagName);
	            }
	            if (icon != null && !icon.isEmpty()) {
	                byte[] thumbnailBytes = ImageUtils.compressImage(icon.getBytes());
	                existingSetting.setIcon(thumbnailBytes);
	            }
	            if (logo != null && !logo.isEmpty()) {
	                byte[] thumbnailBytes = ImageUtils.compressImage(logo.getBytes());
	                existingSetting.setLogo(thumbnailBytes);
	            }

	             Sitesetting details = siteSetting.save(existingSetting);
	          // Create notification for the user who updated the setting
	  	        String heading = "Sitesetting details Updated!";
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

	            return new ResponseEntity<>("Settings updated successfully", HttpStatus.OK);
	        } catch (RuntimeException e) {
	            // Log the error for debugging
	        	logger.error("", e);
	            System.err.println("Runtime exception: " + e.getMessage());
	            return new ResponseEntity<>("Setting not found", HttpStatus.NOT_FOUND);
	        } catch (Exception e) {
	            // Log the error for debugging
	        	logger.error("", e);
	            System.err.println("Exception: " + e.getMessage());
	            return new ResponseEntity<>("Error when updating settings", HttpStatus.INTERNAL_SERVER_ERROR);
	        }
	    }

//	--------------------working

public ResponseEntity<?> addVideosettings(@RequestBody Videosettings data) {

		videosetting.save(data);
		return ResponseEntity.ok("Success");
	}
	

	public ResponseEntity<List<Videosettings>> getvideosettings(){
		List<Videosettings> videosettingss = videosetting.findAll();
		return new ResponseEntity<>(videosettingss, HttpStatus.OK);
	}
//	--------------------working

public ResponseEntity<?> addSocialsettings(@RequestBody SocialSettings data) {

		socialsetting.save(data);
		return ResponseEntity.ok("Success");
	
}
	

	public ResponseEntity<List<SocialSettings>> getsocialsettings(){
		List<SocialSettings> socialsettingss = socialsetting.findAll();
		return new ResponseEntity<>(socialsettingss, HttpStatus.OK);
	}
	



}