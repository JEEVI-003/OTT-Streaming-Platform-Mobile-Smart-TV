package com.VsmartEngine.MediaJungle.fileservice;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class AudioFileService {

    @Value("${upload.audio.directory}")
    private String audioUploadDirectory;

    private static final Logger logger = LoggerFactory.getLogger(AudioFileService.class);

    /**
     * Saves a new audio file and returns only the unique filename (not the full path).
     * The filename stored in DB is then resolved at runtime using upload.audio.directory.
     */
    public String saveAudioFile(MultipartFile audioFile) throws IOException {
        String uniqueFileName = System.currentTimeMillis() + "_" + audioFile.getOriginalFilename();

        File dir = new File(audioUploadDirectory);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        Path filePath = Paths.get(audioUploadDirectory).resolve(uniqueFileName);
        Files.copy(audioFile.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        // Return ONLY the filename — never return the full absolute path
        return uniqueFileName;
    }

    public String savFile(MultipartFile audioFile) throws IOException {
        String uniqueFileName = audioFile.getOriginalFilename();
        System.out.println("audioFile.getOriginalFilename(): " + uniqueFileName);

        Path filePath = Paths.get(audioUploadDirectory).resolve(uniqueFileName);
        Files.copy(audioFile.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        return uniqueFileName;
    }

    public boolean deleteAudioFile(String fileName) {
        // fileName should be just the filename (e.g. "1234_song.mp3"), not an absolute path
        Path filePath = Paths.get(audioUploadDirectory).resolve(fileName);

        System.out.println("Deleting file: " + filePath.toAbsolutePath());
        try {
            boolean deleted = Files.deleteIfExists(filePath);
            if (deleted) {
                System.out.println("File deleted successfully");
            } else {
                System.out.println("File does not exist or deletion failed");
            }
            return deleted;
        } catch (IOException e) {
            e.printStackTrace();
            logger.error("Error deleting audio file: " + fileName, e);
            return false;
        }
    }

    /**
     * Updates an audio file. existingFileName must be just the filename (not a full path).
     * Returns only the new unique filename.
     */
    public String updateAudioFile(String existingFileName, MultipartFile newAudioFile) throws IOException {
        String uniqueFileName = System.currentTimeMillis() + "_" + newAudioFile.getOriginalFilename();

        Path existingFilePath = Paths.get(audioUploadDirectory).resolve(existingFileName);
        Path newFilePath = Paths.get(audioUploadDirectory).resolve(uniqueFileName);

        System.out.println("Existing file path: " + existingFilePath.toAbsolutePath());
        System.out.println("New file path: " + newFilePath.toAbsolutePath());

        if (Files.exists(existingFilePath)) {
            Files.copy(newAudioFile.getInputStream(), newFilePath, StandardCopyOption.REPLACE_EXISTING);
            Files.deleteIfExists(existingFilePath);
            // Return ONLY the new filename
            return uniqueFileName;
        } else {
            throw new FileNotFoundException("Existing audio file not found: " + existingFileName);
        }
    }
}