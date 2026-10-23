package com.VsmartEngine.MediaJungle.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Configuration
public class FileStorageService {

    @Value("${file.upload-dir}")
    private String uploadDir;

    // Store the file on disk
    public String storeFile(MultipartFile file) throws IOException {
        Path filePath = Paths.get(uploadDir + File.separator + file.getOriginalFilename());
        Files.createDirectories(filePath.getParent());
        // Get the original file name
        String originalFilename = file.getOriginalFilename();
        Files.write(filePath, file.getBytes());
//        return filePath.toString();
        return originalFilename;
    }

    public Resource getFile(String filename) throws IOException {
        // Safely resolve the file path
        Path filePath = Paths.get(uploadDir).resolve(filename).normalize();
        
        // Check if the file exists and is readable
        if (!Files.exists(filePath) || !Files.isReadable(filePath)) {
            throw new FileNotFoundException("File not found or not readable: " + filename);
        }

        // Create and return the UrlResource
        Resource resource = new UrlResource(filePath.toUri());
        if (!resource.exists() || !resource.isReadable()) {
            throw new IOException("Resource could not be accessed: " + filename);
        }
        return resource;
    }
}
