package com.VsmartEngine.MediaJungle.googleLogin;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.cors.CorsConfigurationSource;

import java.util.List;

//@Configuration
public class GlobalCorsConfig {

//    @Bean
//    public CorsConfigurationSource corsConfigurationSource() {
//        CorsConfiguration configuration = new CorsConfiguration();
//        // Allow your front end's domain
//        configuration.setAllowedOrigins(List.of("http://localhost:4203"));
//        // Allow all standard HTTP methods
//        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
//        // Allow the necessary headers
//        configuration.setAllowedHeaders(List.of("Authorization", "Cache-Control", "Content-Type"));
//        // Allow credentials (cookies)
//        configuration.setAllowCredentials(true);
//        
//        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
//        // Apply this configuration to all endpoints
//        source.registerCorsConfiguration("/**", configuration);
//        return source;
//    }
}

