package com.VsmartEngine.MediaJungle.MailVerification;

import java.time.LocalDateTime;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.repository.AddUserRepository;
import com.VsmartEngine.MediaJungle.userregister.UserRegister;
import com.VsmartEngine.MediaJungle.userregister.UserRegisterRepository;

@RestController
public class VerificationController {
	
	@Autowired
    private EmailService emailService;

    @Autowired
    private UserRegisterRepository userregisterrepository;
    
    @Autowired
	private AddUserRepository adduserrepository;
    
    private final ConcurrentHashMap<String, String> verificationCodeStore = new ConcurrentHashMap<>();
    
    private static final Logger logger = LoggerFactory.getLogger(VerificationController.class);
     
    public ResponseEntity<String> sendCodewhileRegister(@RequestParam String email) {
        try {        
            // Check if the email is already registered
            Optional<UserRegister> existingUser = userregisterrepository.findByEmail(email);
            if (existingUser.isPresent()) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body("Email is already registered.");
            }

            // Step 1: Generate a new verification code
            String code = UUID.randomUUID().toString().substring(0, 6);

            // Step 2: Save the code in the in-memory store
            verificationCodeStore.put(email, code);

            // Step 3: Send the verification code via email
            boolean isEmailSent = emailService.sendEmail(email, "Your Verification Code", "Verification Code: " + code);

            // Step 4: Check if the email was sent successfully
            if (isEmailSent) {
                // Return success response
                return ResponseEntity.status(HttpStatus.CREATED)
                        .body("Verification code created and sent successfully.");
            } else {
                // If email fails to send, return 400 Bad Request
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("Failed to send verification code. Please try again.");
            }
        } catch (Exception e) {
            // Log the exception
            System.err.println("Error occurred: " + e.getMessage());
            logger.error("", e);
            // Return a generic error response
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("An error occurred while processing your request. Please try again later.");
        }
    }
      
    public ResponseEntity<String> sendCode(@RequestParam String email) {
        try {        
            // Check if the email is already registered
            Optional<UserRegister> existingUser = userregisterrepository.findByEmail(email);
            if (!existingUser.isPresent()) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body("Email is not exists.");
            }

            // Step 1: Generate a new verification code
            String code = UUID.randomUUID().toString().substring(0, 6);

            // Step 2: Save the code in the in-memory store
            verificationCodeStore.put(email, code);

            // Step 3: Send the verification code via email
            boolean isEmailSent = emailService.sendEmail(email, "Your Verification Code", "Verification Code: " + code);

            // Step 4: Check if the email was sent successfully
            if (isEmailSent) {
                // Return success response
                return ResponseEntity.status(HttpStatus.CREATED)
                        .body("Verification code created and sent successfully.");
            } else {
                // If email fails to send, return 400 Bad Request
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("Failed to send verification code. Please try again.");
            }
        } catch (Exception e) {
            // Log the exception
            System.err.println("Error occurred: " + e.getMessage());
            logger.error("", e);
            // Return a generic error response
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("An error occurred while processing your request. Please try again later.");
        }
    }


    public ResponseEntity<String> verifyCode(@RequestParam String email, @RequestParam String code) {
        try {
            // Check if the email exists in the in-memory store
            if (verificationCodeStore.containsKey(email)) {
                String storedCode = verificationCodeStore.get(email);
                // Validate the code
                if (storedCode.equals(code)) {
                    // Code matches; remove it after successful verification
                    verificationCodeStore.remove(email);
                    return ResponseEntity.ok("{\"message\": \"Verification successful.\"}");
                } else {
                    // Code mismatch
                    return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("{\"message\": \"Invalid Verification Code \"}");
                }
            } else {
                // No code associated with the provided email
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("{\"message\": \"No verification code found for this email.\"}");
            }
        } catch (Exception e) {
            // Log the exception
            System.err.println("Error during verification: " + e.getMessage());
            logger.error("", e);
            // Return generic server error
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("{\"message\": \"An error occurred during verification. Please try again later.\"}"+ e.getMessage());
        }
    }
}
