package com.VsmartEngine.MediaJungle.video;

import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.compresser.ImageUtils;

@Controller
public class VideoImageController {
	
	@Autowired
	private VideoImageRepository videoimagerepository;

	private static final Logger logger = LoggerFactory.getLogger(VideoImageController.class);
	
	public ResponseEntity<Map<String, byte[]>> getVideoImagesByVideoId(@PathVariable Long id) {
	    try {
	        // Fetching the video images from the repository
	        Optional<VideoImage> videoImageOptional = videoimagerepository.findVideoById(id);

	        if (videoImageOptional.isPresent()) {
	            VideoImage videoImage = videoImageOptional.get();

	            // Decompressing the image bytes
	            byte[] decompressedVideoThumbnail = ImageUtils.decompressImage(videoImage.getVideoThumbnail());
	            byte[] decompressedTrailerThumbnail = ImageUtils.decompressImage(videoImage.getTrailerThumbnail());
	            byte[] decompressedUserBanner = ImageUtils.decompressImage(videoImage.getUserBanner());

	            // Prepare a map to hold the decompressed image data
	            Map<String, byte[]> imageMap = new HashMap<>();
	            imageMap.put("videoThumbnail", decompressedVideoThumbnail);
	            imageMap.put("trailerThumbnail", decompressedTrailerThumbnail);
	            imageMap.put("userBanner", decompressedUserBanner);

	            // Return the map as a response
	            return ResponseEntity.ok()
	                                 .contentType(MediaType.APPLICATION_JSON)
	                                 .body(imageMap);
	        } else {
	            return ResponseEntity.notFound().build();
	        }
	    } catch (Exception e) {
	        e.printStackTrace();  // Replace with proper logging in production
	        logger.error("", e);
	        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
	    }
	}


	    
//	    public ResponseEntity<Map<String, byte[]>> getVideoThumbnail(@PathVariable long videoId) {
//	    	try {
//		        // Fetching the video images from the repository
//		        Optional<VideoImage> videoImageOptional = videoimagerepository.findVideoById(videoId);
//
//		        if (videoImageOptional.isPresent()) {
//		            VideoImage videoImage = videoImageOptional.get();
//
//		            // Decompressing the image bytes
//		            byte[] decompressedVideoThumbnail = ImageUtils.decompressImage(videoImage.getVideoThumbnail());
//		            // Prepare a map to hold the decompressed image data
//		            Map<String, byte[]> imageMap = new HashMap<>();
//		            imageMap.put("videoThumbnail", decompressedVideoThumbnail);
//
//		            // Return the map as a response
//		            return ResponseEntity.ok()
//		                                 .contentType(MediaType.APPLICATION_JSON)
//		                                 .body(imageMap);
//		        } else {
//		            return ResponseEntity.notFound().build();
//		        }
//		    } catch (Exception e) {
//		        e.printStackTrace();  // Replace with proper logging in production
//		        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
//		    }
//
//	    }

	

	public ResponseEntity<byte[]> getVideoThumbnail(@PathVariable long videoId) {
	    try {
	        // Fetch the video image from the repository
	        Optional<VideoImage> videoImageOptional = videoimagerepository.findVideoById(videoId);

	        if (videoImageOptional.isPresent()) {
	            VideoImage videoImage = videoImageOptional.get();

	            // Decompress the image bytes
	            byte[] decompressedVideoThumbnail = ImageUtils.decompressImage(videoImage.getVideoThumbnail());

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
	
	
	
	public ResponseEntity<byte[]> getVideoBanner(@PathVariable long videoId) {
	    try {
	        // Fetch the video image from the repository
	        Optional<VideoImage> videoImageOptional = videoimagerepository.findVideoById(videoId);

	        if (videoImageOptional.isPresent()) {
	            VideoImage videoImage = videoImageOptional.get();

	            // Decompress the image bytes
	            byte[] decompressedVideoThumbnail = ImageUtils.decompressImage(videoImage.getUserBanner());

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





}
