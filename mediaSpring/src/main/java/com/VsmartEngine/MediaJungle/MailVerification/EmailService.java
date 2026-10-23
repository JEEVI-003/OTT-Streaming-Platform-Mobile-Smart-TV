package com.VsmartEngine.MediaJungle.MailVerification;

import java.util.Optional;
import java.util.Properties;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.stereotype.Service;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.model.MailSetting;
import com.VsmartEngine.MediaJungle.repository.MailsettingRepository;

@Service
public class EmailService {
	
	 @Autowired
	 private JavaMailSender mailSender;
	 
	 @Autowired
	 private MailsettingRepository mailsettingrepository;
	 	 
	 private static final Logger logger = LoggerFactory.getLogger(EmailService.class);
	// Send email with dynamic configuration and return success status
	 public boolean sendEmail(String to, String subject, String body) {
	     try {
	         // Retrieve mail configuration from the database
	         Optional<MailSetting> mailConfigOpt = mailsettingrepository.findFirstByOrderByIdAsc();

	         if (mailConfigOpt.isEmpty()) {
	             throw new IllegalStateException("Mail configuration not found in the database");
	         }

	         MailSetting mailConfig = mailConfigOpt.get();

	         // Configure mail sender dynamically
	         JavaMailSenderImpl mailSenderImpl = new JavaMailSenderImpl();
	         mailSenderImpl.setHost(mailConfig.getMailhostname());
	         mailSenderImpl.setPort(mailConfig.getMailportname());
	         mailSenderImpl.setUsername(mailConfig.getEmailid());
	         mailSenderImpl.setPassword(mailConfig.getPassword());

	         // Set additional mail properties
	         Properties props = mailSenderImpl.getJavaMailProperties();
	         props.put("mail.transport.protocol", "smtp");
	         props.put("mail.smtp.auth", "true");
	         props.put("mail.smtp.starttls.enable", "true");
//	         props.put("mail.debug", "true"); // Enable debug logs for development purposes

	         if (mailConfig.getMailportname() == 465) {
	             props.put("mail.smtp.ssl.enable", "true"); // Use SSL for port 465
	         }

	         // Assign configured mail sender
	         this.mailSender = mailSenderImpl;

	         // Prepare and send the email
	         long startTime = System.currentTimeMillis(); // Log start time

	         SimpleMailMessage message = new SimpleMailMessage();
	         message.setTo(to);
	         message.setSubject(subject);
	         message.setText(body);
	         message.setFrom(mailConfig.getEmailid()); // Sender email address
	         mailSender.send(message);

//	         long endTime = System.currentTimeMillis(); // Log end time
//	         System.out.println("Email sent in " + (endTime - startTime) + " ms");

	         return true; // Email sent successfully
	     } catch (Exception e) {
	         // Log the error (use proper logging in production)
	         e.printStackTrace();
	         logger.error("", e);
	         return false; // Email sending failed
	     }
	 }



}