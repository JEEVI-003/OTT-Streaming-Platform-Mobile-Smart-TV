package com.VsmartEngine.MediaJungle.controller;

import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.VsmartEngine.MediaJungle.model.AddAd;
import com.VsmartEngine.MediaJungle.repository.AddAdRepository;
import com.VsmartEngine.MediaJungle.service.AdService;
import com.VsmartEngine.MediaJungle.service.FileStorageService;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/v2")
@CrossOrigin(origins = "*")
public class AddAdController {

    @Autowired
    private AdService adService;

    @Value("${file.upload-dir}")
    private String uploadDir;

    @Autowired
    private AddAdRepository adRepository;

    @Autowired
    private FileStorageService fileStorageService;

    private static final Logger logger = LoggerFactory.getLogger(AddAdController.class);

    // ─── Add Ad ──────────────────────────────────────────────────────────────────
    @PostMapping("/AddAds")
    public ResponseEntity<?> addAd(
            @RequestParam("adName") String adName,
            @RequestParam(value = "certificateNumber", required = false) String certificateNumber,
            @RequestParam(value = "certificateName",   required = false) String certificateName,
            @RequestParam(value = "numberOfViews",     required = false) Integer numberOfViews,
            @RequestParam(value = "rollType",          required = false) String rollType,
            @RequestParam(value = "videoFile",         required = false) MultipartFile videoFile) {
        try {
            String videoFilePath = videoFile != null ? fileStorageService.storeFile(videoFile) : null;
            AddAd ad = new AddAd();
            ad.setAdName(adName);
            ad.setCertificateNumber(certificateNumber);
            ad.setCertificateName(certificateName);
            ad.setViews(numberOfViews);
            ad.setRollType(rollType);
            ad.setVideoFilePath(videoFilePath);
            return ResponseEntity.ok(adService.saveAd(ad));
        } catch (IOException e) {
            logger.error("Error uploading ad video", e);
            return ResponseEntity.status(500).body("Error uploading video: " + e.getMessage());
        }
    }

    // ─── Stream ad video by specific ad ID ───────────────────────────────────────
    // ✅ NEW ENDPOINT: GET /api/v2/getadvideo/{id}
    //
    // The frontend's ad schedule stores {time, adId} per slot.
    // When the video player reaches a scheduled timestamp, it calls this endpoint
    // with the adId to fetch and play the correct ad video.
    // Supports HTTP Range requests so the browser can buffer/seek the ad properly.
    @GetMapping("/getadvideo/{id}")
    public ResponseEntity<?> getAdVideoById(
            @PathVariable Long id,
            HttpServletRequest request) {
        try {
            Optional<AddAd> optAd = adRepository.findById(id);
            if (!optAd.isPresent()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body("Ad not found with id " + id);
            }

            String filename = optAd.get().getVideoFilePath();
            if (filename == null || filename.isBlank()) {
                return ResponseEntity.ok("No video file available for this ad.");
            }

            Path filePath = Paths.get(uploadDir, filename);
            if (!filePath.toFile().exists() || !filePath.toFile().isFile()) {
                logger.warn("Ad video file not found on disk: {}", filePath);
                return ResponseEntity.notFound().build();
            }

            Resource resource = new UrlResource(filePath.toUri());
            if (!resource.exists() || !resource.isReadable()) {
                return ResponseEntity.notFound().build();
            }

            HttpHeaders headers = new HttpHeaders();
            String mimeType = Files.probeContentType(filePath);
            if (mimeType == null) mimeType = MediaType.APPLICATION_OCTET_STREAM_VALUE;
            headers.add(HttpHeaders.CONTENT_TYPE, mimeType);
            headers.add(HttpHeaders.CONTENT_DISPOSITION, "inline");
            // Allow browser to cache ad video for 1 hour to avoid re-fetching same ad
            headers.add(HttpHeaders.CACHE_CONTROL, "public, max-age=3600");

            long fileSize      = Files.size(filePath);
            String rangeHeader = request.getHeader(HttpHeaders.RANGE);

            // Default to first 5 MB when no Range header is provided
            long rangeStart = 0;
            long rangeEnd   = Math.min(5L * 1024 * 1024 - 1, fileSize - 1);

            if (rangeHeader != null) {
                String[] parts = rangeHeader.replace("bytes=", "").split("-");
                rangeStart = Long.parseLong(parts[0]);
                rangeEnd   = (parts.length > 1 && !parts[1].isBlank())
                           ? Long.parseLong(parts[1])
                           : fileSize - 1;
            }

            long contentLength = rangeEnd - rangeStart + 1;
            headers.add(HttpHeaders.CONTENT_RANGE,
                    String.format("bytes %d-%d/%d", rangeStart, rangeEnd, fileSize));

            try (RandomAccessFile raf = new RandomAccessFile(filePath.toFile(), "r")) {
                raf.seek(rangeStart);
                byte[] buffer = new byte[(int) contentLength];
                raf.readFully(buffer);
                return ResponseEntity.status(HttpStatus.PARTIAL_CONTENT)
                        .headers(headers)
                        .contentLength(contentLength)
                        .body(new ByteArrayResource(buffer));
            }

        } catch (Exception e) {
            logger.error("Error streaming ad video id={}", id, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // ─── Legacy: random ad (kept for backward compat) ────────────────────────────
    @GetMapping("/getadvideo")
    public ResponseEntity<?> getAdVideoRandom(HttpServletRequest request) {
        List<AddAd> ads = adRepository.findAll();
        if (ads.isEmpty()) return ResponseEntity.notFound().build();
        return getAdVideoById(ads.get(0).getId(), request);
    }

    // ─── Get all ads ─────────────────────────────────────────────────────────────
    @GetMapping("/GetAllAds")
    public ResponseEntity<List<AddAd>> getAllAds() {
        return ResponseEntity.ok(adService.getAllAds());
    }

    // ─── Get ad by ID ─────────────────────────────────────────────────────────────
    @GetMapping("/GetAdById/{id}")
    public ResponseEntity<AddAd> getAdById(@PathVariable Long id) {
        AddAd ad = adService.getAdById(id)
                .orElseThrow(() -> new RuntimeException("Ad not found with ID: " + id));
        return ResponseEntity.ok(ad);
    }

    // ─── Update ad ────────────────────────────────────────────────────────────────
    @PatchMapping("/editAd/{id}")
    public ResponseEntity<?> updateAd(
            @PathVariable Long id,
            @RequestParam(value = "adName",            required = false) String adName,
            @RequestParam(value = "certificateNumber", required = false) String certificateNumber,
            @RequestParam(value = "certificateName",   required = false) String certificateName,
            @RequestParam(value = "numberOfViews",     required = false) Integer numberOfViews,
            @RequestParam(value = "rollType",          required = false) String rollType,
            @RequestParam(value = "videoFile",         required = false) MultipartFile videoFile) {
        try {
            AddAd ad = adService.getAdById(id)
                    .orElseThrow(() -> new RuntimeException("Ad not found with id " + id));

            if (adName            != null) ad.setAdName(adName);
            if (certificateNumber != null) ad.setCertificateNumber(certificateNumber);
            if (certificateName   != null) ad.setCertificateName(certificateName);
            if (numberOfViews     != null) ad.setViews(numberOfViews);
            if (rollType          != null) ad.setRollType(rollType);
            if (videoFile         != null) ad.setVideoFilePath(fileStorageService.storeFile(videoFile));

            return ResponseEntity.ok(adService.updateAd(id, ad));
        } catch (RuntimeException e) {
            logger.error("Ad not found id={}", id, e);
            return ResponseEntity.status(404).body("Ad not found with id " + id);
        } catch (IOException e) {
            logger.error("Error uploading video for ad id={}", id, e);
            return ResponseEntity.status(500).body("Error uploading video: " + e.getMessage());
        }
    }

    // ─── Delete ad ────────────────────────────────────────────────────────────────
    @DeleteMapping("/deleteAd/{id}")
    public ResponseEntity<String> deleteAd(@PathVariable Long id) {
        try {
            adService.deleteAdById(id);
            return ResponseEntity.ok("Ad deleted successfully");
        } catch (RuntimeException e) {
            logger.error("Delete failed for ad id={}", id, e);
            return ResponseEntity.status(404).body(e.getMessage());
        }
    }
}