package com.VsmartEngine.MediaJungle.userregister;
import java.util.Date;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;

import com.VsmartEngine.MediaJungle.LogManagement;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

@Configuration
public class JwtUtil {
	
	 @Autowired
	 private JwtConfig jwtConfig;
	 
	 public static final long JWT_EXPIRATION_MS = 86400000;
	 private static final Logger logger = LoggerFactory.getLogger(JwtUtil.class);

	    public String generateToken(String username, String role) {
	        Date now = new Date();
	        Date expiryDate = new Date(now.getTime() + JWT_EXPIRATION_MS);
	        return Jwts.builder()
	            .setSubject(username)
	            .claim("username", username)
	            .claim("role", role)
	            .setIssuedAt(now)
	            .setExpiration(expiryDate)
	            .signWith(SignatureAlgorithm.HS256, jwtConfig.getSecretKey())
	            .compact();
	    }

	    public boolean validateToken(String token) {
	        try {
	            Jwts.parser()
	                .setSigningKey(jwtConfig.getSecretKey())
	                .parseClaimsJws(token);
	            return true;
	        } catch (Exception e) {
	        	logger.error("", e);
	            return false;
	        }
	    }

	    public String getUsernameFromToken(String token) {
	        try {
	            Claims claims = Jwts.parser()
	                .setSigningKey(jwtConfig.getSecretKey())
	                .parseClaimsJws(token)
	                .getBody();
	            return claims.get("username", String.class);
	        } catch (Exception e) {
	            // Print or log the exception for debugging
	        	logger.error("", e);
	            e.printStackTrace();
	            return null;
	        }
	    }

	    public String getRoleFromToken(String token) {
	        Claims claims = getAllClaimsFromToken(token);
	        return claims.get("role", String.class); // Adjust the key based on how roles are stored in your token
	    }

	    private Claims getAllClaimsFromToken(String token) {
	        return Jwts.parser()
	                .setSigningKey(jwtConfig.getSecretKey())
	                .parseClaimsJws(token)
	                .getBody();
	    }
}
