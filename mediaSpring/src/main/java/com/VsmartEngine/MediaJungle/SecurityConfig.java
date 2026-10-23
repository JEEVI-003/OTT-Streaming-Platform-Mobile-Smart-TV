package com.VsmartEngine.MediaJungle;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

import com.VsmartEngine.MediaJungle.googleLogin.OAuth2LoginSuccessHandler;

//@Configuration
public class SecurityConfig {
	
//	 @Autowired
//	    private OAuth2LoginSuccessHandler oAuth2LoginSuccessHandler;
//	 
//	 
//
//	 @Bean
//	    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
//	        http
//	            // Public endpoints
//	            .authorizeHttpRequests(authorize -> authorize
////	                .requestMatchers("/", "/login**", "/error").permitAll()
//	                // All other endpoints require authentication
////	                .anyRequest().authenticated()
//	            		.anyRequest().permitAll()
//	            )
//	            // OAuth2 login configuration
//	            .oauth2Login(oauth2 -> oauth2
//	                .loginPage("/oauth2/authorization/google")
//	                .successHandler(oAuth2LoginSuccessHandler)
//	            )
//	            // Enable CORS if needed
//	            .cors(Customizer.withDefaults())
//	            // Disable CSRF for simplicity (adjust for production)
//	            .csrf(csrf -> csrf.disable())
//	            // Use stateful session management (so that the user is stored in session)
//	            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED));
//
//	        return http.build();
//	    }
	}

