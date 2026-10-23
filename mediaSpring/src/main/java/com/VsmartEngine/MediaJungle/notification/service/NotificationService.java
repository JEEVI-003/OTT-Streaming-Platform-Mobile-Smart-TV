package com.VsmartEngine.MediaJungle.notification.service;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.compresser.ImageUtils;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.notification.NotificationAdmin;
import com.VsmartEngine.MediaJungle.notification.NotificationDetails;
import com.VsmartEngine.MediaJungle.notification.NotificationUser;
import com.VsmartEngine.MediaJungle.notification.repository.NotificationAdminRepository;
import com.VsmartEngine.MediaJungle.notification.repository.NotificationDetailsRepository;
import com.VsmartEngine.MediaJungle.notification.repository.NotificationUserRepository;
import com.VsmartEngine.MediaJungle.repository.AddUserRepository;
import com.VsmartEngine.MediaJungle.userregister.UserRegister;
import com.VsmartEngine.MediaJungle.userregister.UserRegisterRepository;

import jakarta.transaction.Transactional;

@Service
public class NotificationService {
	
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
	
	
	@Transactional
    public void markAllAsRead(Long adminId) {
		notificationadmin.markAllAsRead(adminId);
    }
	
	@Transactional
    public void markAllAsReaduser(Long userId) {
		notificationuser.markAllAsReaduser(userId);
    }
	
//Create Notification with Multipart
	private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);
	
    public Long  createNotification(String username, String createdBy,String heading ,Optional<MultipartFile> file) {
        
        NotificationDetails Details= new NotificationDetails();
        Details.setHeading(heading);
//        Details.setLink(link);
        if (file.isPresent()) { // Check if file is present (for approach 2)
            try {
                Details.setNotimage(ImageUtils.compressImage(file.get().getBytes()));; 
            } catch (IOException e) {
                e.printStackTrace();
                logger.error("", e);
            }
        }
        
        Details.setUsername(username);
        Details.setCreatedBy(createdBy);
        Details.setCreatedDate(LocalDate.now());
        Details.setIsActive(true);
//        Details.setDescription(description);
        NotificationDetails savedNotiDetails= notificationdetails.save(Details);
        return (savedNotiDetails.getNotifyId());
    }
    
    
 public Long  createNotification(String username, String createdBy,String heading ,String description,String Link,String detail,Optional<MultipartFile> file) {
        
        NotificationDetails Details= new NotificationDetails();
        Details.setHeading(heading);
        Details.setLink(Link);
        if (file.isPresent()) { // Check if file is present (for approach 2)
            try {
                Details.setNotimage(ImageUtils.compressImage(file.get().getBytes()));; 
            } catch (IOException e) {
                e.printStackTrace();
                logger.error("", e);
            }
        }
        
        Details.setUsername(username);
        Details.setCreatedBy(createdBy);
        Details.setCreatedDate(LocalDate.now());
        Details.setIsActive(true);
        Details.setDescription(description);
        Details.setDetail(detail);
        NotificationDetails savedNotiDetails= notificationdetails.save(Details);
        return (savedNotiDetails.getNotifyId());
    }
    
    
    
  //Create Notification with byte image
    public Long  createNotification(String username, String createdBy,String heading ,byte[] file) {
        
        NotificationDetails notiDetails= new NotificationDetails();
        notiDetails.setHeading(heading);
//        notiDetails.setLink(link);
      
        notiDetails.setNotimage(file);
        
        notiDetails.setUsername(username);
        notiDetails.setCreatedBy(createdBy);
        notiDetails.setCreatedDate(LocalDate.now());
        notiDetails.setIsActive(true);
//        notiDetails.setDescription(description);
        NotificationDetails savedNotiDetails= notificationdetails.save(notiDetails);
        return (savedNotiDetails.getNotifyId());
    }
    
    
    
  //create notification without pic   
    public Long  createNotification(String username, String createdBy,String heading ) {
    	
        NotificationDetails notiDetails= new NotificationDetails();
        notiDetails.setHeading(heading);
//        notiDetails.setLink(link); 
        notiDetails.setUsername(username);
        notiDetails.setCreatedBy(createdBy);
        notiDetails.setCreatedDate(LocalDate.now());
        notiDetails.setIsActive(true);
//        notiDetails.setDescription(description);
        NotificationDetails savedNotiDetails= notificationdetails.save(notiDetails);
        return (savedNotiDetails.getNotifyId());
    }
    
    
  //create notification without pic   
    public Long  createNotification(String username, String createdBy,String heading ,String detail) {
    	
        NotificationDetails notiDetails= new NotificationDetails();
        notiDetails.setHeading(heading);
//        notiDetails.setLink(link); 
        notiDetails.setUsername(username);
        notiDetails.setCreatedBy(createdBy);
        notiDetails.setCreatedDate(LocalDate.now());
        notiDetails.setIsActive(true);
        notiDetails.setDescription(detail);
        NotificationDetails savedNotiDetails= notificationdetails.save(notiDetails);
        return (savedNotiDetails.getNotifyId());
    }
	
    
    
    public Boolean LicenceExpitedNotification(Long notificationId ,LocalDate datetonotify) {
    	 List<AddUser> listofadmins = adduserrepository.findAll();
		for(AddUser admin :listofadmins) {
			 NotificationAdmin notificationAdmin = new NotificationAdmin();
			 notificationAdmin.setAdminid(admin.getId());
			 notificationAdmin.setNotificationId(notificationId);
			 notificationAdmin.setIs_read(false);
			 notificationAdmin.setIs_Active(true);
			 notificationAdmin.setDatetonotify(datetonotify);
			 notificationadmin.save(notificationAdmin);
		}
    	return(true);
    }
    

public Boolean CommoncreateNotificationAdmin(Long notificationId, List<String> userlist) {
    for (String singleuser : userlist) {
        List<AddUser> adminUsers = adduserrepository.findAll();
        for (AddUser admin : adminUsers) {
            if (admin.getEmail().equals(singleuser)) {
                NotificationAdmin notificationAdmin = new NotificationAdmin();
                notificationAdmin.setAdminid(admin.getId());
                System.out.println(admin.getId());
                notificationAdmin.setNotificationId(notificationId);
                notificationAdmin.setIs_read(false);
                notificationAdmin.setIs_Active(true);
                notificationadmin.save(notificationAdmin);
            }
        }
        

//        List<UserRegister> regularUsers = userregisterrepository.findAll();
//        for (UserRegister regularUser : regularUsers) {
//            if (regularUser.getEmail().equals(singleuser)) {
//                NotificationUser notificationUser = new NotificationUser();
//                notificationUser.setUserid(regularUser.getId());
//                notificationUser.setNotificationId(notificationId);
//                notificationUser.setIs_read(false);
//                notificationUser.setIs_Active(true);
//                notificationuser.save(notificationUser);
//            }
        //}
    }
    return true;
}


public Boolean CommoncreateNotificationUser(Long notificationId, List<String> userlist) {
	 for (String singleuser : userlist) {
	List<UserRegister> regularUsers = userregisterrepository.findAll();
  for (UserRegister regularUser : regularUsers) {
      if (regularUser.getEmail().equals(singleuser)) {
          NotificationUser notificationUser = new NotificationUser();
          notificationUser.setUserid(regularUser.getId());
          notificationUser.setNotificationId(notificationId);
          notificationUser.setIs_read(false);
          notificationUser.setIs_Active(true);
          notificationuser.save(notificationUser);
      }
  }
}
return true;	
}

public Boolean notificationuser(Long notificationId, Long userId) {
    // Find the user by their ID
    Optional<UserRegister> userOptional = userregisterrepository.findById(userId);
    
    // Check if the user exists
    if (userOptional.isPresent()) {
        // Get the user
        UserRegister user = userOptional.get();

        // Create a new NotificationUser
        NotificationUser notificationUser = new NotificationUser();
        notificationUser.setUserid(user.getId());
        notificationUser.setNotificationId(notificationId);
        notificationUser.setIs_read(false); // Default to not read
        notificationUser.setIs_Active(true); // Default to active

        // Save the notificationUser entity
        notificationuser.save(notificationUser);

        return true;
    } else {
        // If user does not exist, return false or handle accordingly
        return false;
    }
}
	
}



    
    

    


