package com.VsmartEngine.MediaJungle.service;

import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.model.PaymentUser;
import com.VsmartEngine.MediaJungle.repository.PaymentRepository;
import com.VsmartEngine.MediaJungle.userregister.UserRegister;
import com.VsmartEngine.MediaJungle.userregister.UserRegisterRepository;

import io.jsonwebtoken.io.IOException;
import jakarta.transaction.Transactional;

@Service
public class UserService {
	
    @Autowired
    private PaymentRepository userRepository;

    @Autowired
    private UserRegisterRepository userRegisterRepository;
    
    private static final Logger logger = LoggerFactory.getLogger(AudioService.class);
    
    public String getPlanDetailsByUserId(Long userId) {
        Optional<PaymentUser> userOptional = userRepository.findByUserId(userId);
        
        // Using Optional's isPresent() method to check and get the plan details
        return userOptional.map(PaymentUser::getSubscriptionTitle).orElse(null);
    }
    @Transactional
    public void updateProfilePicture(Long userId, byte[] profilePictureData) {
        UserRegister user = userRegisterRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.setProfile(profilePictureData);
        userRegisterRepository.save(user);
    }
    public UserRegister getUserById(Long userId) {
        return userRegisterRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
    public UserRegister updateUser(Long userId, String username, String email, String mobnum, MultipartFile profileImage) throws java.io.IOException {
        UserRegister user = getUserById(userId);
        
        // Update user details
        user.setUsername(username);
        user.setEmail(email);
        user.setMobnum(mobnum);
        
        // Handle image upload
        if (profileImage != null && !profileImage.isEmpty()) {
            try {
                byte[] imageBytes = profileImage.getBytes();
                user.setProfile(imageBytes); // Set the new profile image
            } catch (IOException e) {
            	logger.error("", e);
                throw new RuntimeException("Failed to upload image", e);
            }
        }

        return userRegisterRepository.save(user);
    }
}
