package com.VsmartEngine.MediaJungle.video;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Random;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

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
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.compresser.ImageUtils;
import com.VsmartEngine.MediaJungle.ffmpeg.FFmpegService;
import com.VsmartEngine.MediaJungle.model.AddAd;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.model.CastAndCrewModalDTO;
import com.VsmartEngine.MediaJungle.model.CastandCrew;
import com.VsmartEngine.MediaJungle.model.FileModel;
import com.VsmartEngine.MediaJungle.notification.service.NotificationService;
import com.VsmartEngine.MediaJungle.repository.AddAdRepository;
import com.VsmartEngine.MediaJungle.repository.AddNewCategoriesRepository;
import com.VsmartEngine.MediaJungle.repository.AddUserRepository;
import com.VsmartEngine.MediaJungle.repository.CastandcrewRepository;
import com.VsmartEngine.MediaJungle.service.FileService;
import com.VsmartEngine.MediaJungle.service.FileStorageService;
import com.VsmartEngine.MediaJungle.userregister.JwtUtil;
import com.VsmartEngine.MediaJungle.userregister.UserRegister;
import com.VsmartEngine.MediaJungle.userregister.UserRegisterRepository;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.transaction.Transactional;

@Controller
public class VideoController {

    @Value("${project.video}")
    private String path;

    @Value("${project.videotrailer}")
    private String trailervideoPath;

    @Value("${file.upload-dir}")
    private String uploadDir;

    @Autowired private VideoService videoService;
    @Autowired private FileStorageService fileStorageService;
    @Autowired private FFmpegService ffmpegservice;
    @Autowired private FileService fileSevice;
    @Autowired private VideoImageRepository videoimagerepository;
    @Autowired private VideoRepository videoRepository;
    @Autowired private AddVideoDescriptionRepository videodescriptionRepository;
    @Autowired private NotificationService notificationservice;
    @Autowired private JwtUtil jwtUtil;
    @Autowired private AddUserRepository adduserrepository;
    @Autowired private UserRegisterRepository userregisterrepository;
    @Autowired private AddVideoDescriptionRepository videodescription;
    @Autowired private CastandcrewRepository castandcrewrepository;
    @Autowired private AddNewCategoriesRepository addnewcategoriesrepository;
    @Autowired private AddAdRepository adRepository;

    private static final Logger logger = LoggerFactory.getLogger(VideoController.class);

    // =========================================================================
    // UPLOAD VIDEO  (OPTIMISED)
    // ─────────────────────────────────────────────────────────────────────────
    // KEY CHANGES vs old version:
    //  1. FFmpeg DASH is now fired ASYNCHRONOUSLY via ffmpegservice.generateDASHAsync().
    //     The HTTP request returns in ~seconds instead of blocking for minutes.
    //  2. VideoDescription is saved BEFORE FFmpeg starts; dashStatus starts as
    //     "PROCESSING" and is updated to "READY" / "FAILED" by FFmpegService when done.
    //  3. Thumbnail compression is unchanged – images are small so no latency issue.
    // =========================================================================
    public ResponseEntity<?> uploadVideoDescription(
            @RequestParam("videoTitle") String videoTitle,
            @RequestParam("mainVideoDuration") String mainVideoDuration,
            @RequestParam("trailerDuration") String trailerDuration,
            @RequestParam("rating") String rating,
            @RequestParam("language") String language,
            @RequestParam("certificateNumber") String certificateNumber,
            @RequestParam("videoAccessType") boolean videoAccessType,
            @RequestParam("description") String description,
            @RequestParam("productionCompany") String productionCompany,
            @RequestParam("certificateName") String certificateName,
            @RequestParam("castandcrewlist") List<Long> castandcrewlist,
            @RequestParam("taglist") List<Long> taglist,
            @RequestParam("categorylist") List<Long> categorylist,
            @RequestParam("videoThumbnail") MultipartFile videoThumbnail,
            @RequestParam("trailerThumbnail") MultipartFile trailerThumbnail,
            @RequestParam("userBanner") MultipartFile userBanner,
            @RequestParam("video") MultipartFile video,
            @RequestParam("trailervideo") MultipartFile trailervideo,
            @RequestParam("advertisementTimings") List<String> advertisementTimings,
            @RequestHeader("Authorization") String token) {

        try {
            if (!jwtUtil.validateToken(token)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
            String email = jwtUtil.getUsernameFromToken(token);
            Optional<AddUser> opUser = adduserrepository.findByUsername(email);

            if (!opUser.isPresent()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }

            AddUser user = opUser.get();
            String username = user.getUsername();

            // ── 1. Create unique folder for this video's files ────────────────
            String hashValue = UUID.randomUUID().toString().replace("-", "");
            Path videoFolder = Paths.get(path, hashValue);
            Path dashFolder  = videoFolder.resolve("dash");
            Files.createDirectories(videoFolder);
            Files.createDirectories(dashFolder);

            // ── 2. Save main video and trailer to disk ────────────────────────
            //    Files.copy() streams directly; no full in-memory buffering.
            FileModel upload = fileSevice.uploadVideo(videoFolder.toString(), video);
            String videoname = upload.getVideoFileName();

            FileModel uploadTrailer = fileSevice.uploadTrailerVideo(trailervideoPath, trailervideo);
            String trailervideoname = uploadTrailer.getVideotrailerfilename();

            // ── 3. Persist VideoDescription with dashStatus = "PROCESSING" ────
            VideoDescription newVideo = new VideoDescription();
            newVideo.setVideoTitle(videoTitle);
            newVideo.setMainVideoDuration(mainVideoDuration);
            newVideo.setTrailerDuration(trailerDuration);
            newVideo.setVideoAccessType(videoAccessType);
            newVideo.setTaglist(taglist);
            newVideo.setRating(rating);
            newVideo.setProductionCompany(productionCompany);
            newVideo.setDescription(description);
            newVideo.setCertificateNumber(certificateNumber);
            newVideo.setCertificateName(certificateName);
            newVideo.setCategorylist(categorylist);
            newVideo.setCastandcrewlist(castandcrewlist);
            newVideo.setVidofilename(videoname);
            newVideo.setVideotrailerfilename(trailervideoname);
            newVideo.setFoldername(videoFolder.toString());
            newVideo.setDate(LocalDate.now());
            newVideo.setAdvertisementTimings(advertisementTimings);
            newVideo.setLanguage(language);
            newVideo.setDashStatus("PROCESSING");   // <── will flip to READY/FAILED async

            VideoDescription savedDescription = videodescriptionRepository.save(newVideo);
            long videoId = savedDescription.getId();

            // ── 4. Save compressed thumbnails ─────────────────────────────────
            VideoImage videoImage = new VideoImage();
            videoImage.setVideoId(videoId);
            videoImage.setVideoThumbnail(ImageUtils.compressImage(videoThumbnail.getBytes()));
            videoImage.setTrailerThumbnail(ImageUtils.compressImage(trailerThumbnail.getBytes()));
            videoImage.setUserBanner(ImageUtils.compressImage(userBanner.getBytes()));
            videoimagerepository.save(videoImage);

            // ── 5. Fire-and-forget DASH encoding ──────────────────────────────
            //    Returns immediately; FFmpegService updates dashStatus when done.
            ffmpegservice.generateDASHAsync(
                    videoFolder.resolve(videoname).toString(),
                    dashFolder.toString(),
                    videoId);

            // ── 6. Send notifications ──────────────────────────────────────────
            String heading = savedDescription.getVideoTitle() + " New Video Added!";
            String link    = "/MoviesPage";
            String detail  = "Sit back, watch, and enjoy this movie.";
            Long notifyId = notificationservice.createNotification(
                    username, email, heading, description, link, detail,
                    Optional.ofNullable(userBanner));

            if (notifyId != null) {
                Set<String> notiUserSet = new HashSet<>();
                adduserrepository.findAll().forEach(a -> notiUserSet.add(a.getEmail()));
                notificationservice.CommoncreateNotificationAdmin(notifyId, new ArrayList<>(notiUserSet));
                userregisterrepository.findAll().forEach(u -> notiUserSet.add(u.getEmail()));
                notificationservice.CommoncreateNotificationUser(notifyId, new ArrayList<>(notiUserSet));
            }

            // ── 7. Return immediately with saved data ──────────────────────────
            Map<String, Object> response = new HashMap<>();
            response.put("videoDescription", savedDescription);
            response.put("videoImage", videoImage);
            // dashStatus = "PROCESSING" — frontend can poll /api/v2/dashstatus/{id}
            return ResponseEntity.ok().body(response);

        } catch (IOException e) {
            logger.error("uploadVideoDescription failed", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    // =========================================================================
    // DASH STATUS CHECK  (new endpoint — frontend polls this after upload)
    // GET /api/v2/dashstatus/{videoId}
    // Returns: { "dashStatus": "PROCESSING" | "READY" | "FAILED" }
    // =========================================================================
    public ResponseEntity<Map<String, String>> getDashStatus(@PathVariable Long videoId) {
        return videodescriptionRepository.findById(videoId)
                .map(v -> {
                    Map<String, String> res = new HashMap<>();
                    res.put("dashStatus", v.getDashStatus());
                    return ResponseEntity.ok(res);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // =========================================================================
    // GET ALL VIDEOS
    // =========================================================================
    public ResponseEntity<List<VideoDescription>> getAllVideo() {
        List<VideoDescription> getUser = videodescription.findAll();
        return new ResponseEntity<>(getUser, HttpStatus.OK);
    }

    // =========================================================================
    // GET VIDEO DETAIL BY ID
    // =========================================================================
    public ResponseEntity<VideoDescription> getVideoDetailById(@PathVariable Long id) {
        try {
            Optional<VideoDescription> videoDetail = videodescriptionRepository.findById(id);
            if (videoDetail.isPresent()) {
                return new ResponseEntity<>(videoDetail.get(), HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            logger.error("", e);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    // =========================================================================
    // GET ADVERTISEMENT TIMINGS
    // =========================================================================
    public ResponseEntity<List<Integer>> getVideoAdvertisementTiming(@PathVariable Long id) {
        try {
            Optional<VideoDescription> videoDetail = videodescriptionRepository.findById(id);
            if (videoDetail.isPresent()) {
                List<Integer> adTimingsInSeconds = videoDetail.get().getAdvertisementTimings()
                        .stream()
                        .map(this::convertToSeconds)
                        .collect(Collectors.toList());
                return new ResponseEntity<>(adTimingsInSeconds, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            logger.error("", e);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    private int convertToSeconds(String time) {
        String[] parts = time.split(":");
        return Integer.parseInt(parts[0]) * 3600
             + Integer.parseInt(parts[1]) * 60
             + Integer.parseInt(parts[2]);
    }

    // =========================================================================
    // STREAM MAIN VIDEO  (byte-range / partial content)
    // =========================================================================
    public ResponseEntity<?> getVideo(@PathVariable Long id, HttpServletRequest request) {
        try {
            Optional<VideoDescription> optionalLesson = videodescriptionRepository.findById(id);
            if (!optionalLesson.isPresent()) {
                return ResponseEntity.notFound().build();
            }
            String filename = optionalLesson.get().getVidofilename();
            String folder   = optionalLesson.get().getFoldername();

            if (filename != null) {
                Path filePath = Paths.get(folder, filename);
                try {
                    if (filePath.toFile().exists() && filePath.toFile().isFile()) {
                        Resource resource = new UrlResource(filePath.toUri());
                        if (resource.exists() && resource.isReadable()) {
                            HttpHeaders headers = new HttpHeaders();
                            String mimeType = Files.probeContentType(filePath);
                            if (mimeType == null) mimeType = MediaType.APPLICATION_OCTET_STREAM_VALUE;
                            headers.add(HttpHeaders.CONTENT_TYPE, mimeType);
                            headers.add(HttpHeaders.CONTENT_DISPOSITION, "inline");

                            final long CHUNK = 5 * 1024 * 1024L;
                            long fileSize   = Files.size(filePath);
                            String rangeHdr = request.getHeader(HttpHeaders.RANGE);

                            long rangeStart, rangeEnd;
                            if (rangeHdr != null) {
                                String[] ranges = rangeHdr.replace("bytes=", "").split("-");
                                rangeStart = Long.parseLong(ranges[0]);
                                rangeEnd   = ranges.length > 1 ? Long.parseLong(ranges[1]) : fileSize - 1;
                            } else {
                                rangeStart = 0;
                                rangeEnd   = Math.min(CHUNK - 1, fileSize - 1);
                            }
                            long contentLength = rangeEnd - rangeStart + 1;

                            try (RandomAccessFile file = new RandomAccessFile(filePath.toFile(), "r")) {
                                file.seek(rangeStart);
                                byte[] buffer = new byte[(int) contentLength];
                                file.readFully(buffer);
                                headers.add(HttpHeaders.CONTENT_RANGE,
                                        String.format("bytes %d-%d/%d", rangeStart, rangeEnd, fileSize));
                                return ResponseEntity.status(HttpStatus.PARTIAL_CONTENT)
                                        .headers(headers)
                                        .contentLength(contentLength)
                                        .body(new ByteArrayResource(buffer));
                            }
                        }
                    }
                } catch (Exception e) {
                    logger.error("", e);
                }
                return ResponseEntity.notFound().build();
            } else {
                return ResponseEntity.ok(filename);
            }
        } catch (Exception e) {
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // =========================================================================
    // STREAM TRAILER VIDEO
    // =========================================================================
    public ResponseEntity<?> getVideotrailer(@PathVariable Long id, HttpServletRequest request) {
        try {
            Optional<VideoDescription> optionalLesson = videodescriptionRepository.findById(id);
            if (!optionalLesson.isPresent()) return ResponseEntity.notFound().build();

            String filename = optionalLesson.get().getVideotrailerfilename();
            if (filename != null) {
                Path filePath = Paths.get(trailervideoPath, filename);
                if (Files.exists(filePath) && Files.isRegularFile(filePath)) {
                    Resource resource = new UrlResource(filePath.toUri());
                    if (resource.exists() && resource.isReadable()) {
                        HttpHeaders headers = new HttpHeaders();
                        String mimeType = Files.probeContentType(filePath);
                        if (mimeType == null) mimeType = MediaType.APPLICATION_OCTET_STREAM_VALUE;
                        headers.add(HttpHeaders.CONTENT_TYPE, mimeType);
                        headers.add(HttpHeaders.CONTENT_DISPOSITION, "inline");

                        final long CHUNK  = 5 * 1024 * 1024L;
                        long fileSize     = Files.size(filePath);
                        String rangeHdr   = request.getHeader(HttpHeaders.RANGE);

                        long rangeStart = 0, rangeEnd = Math.min(CHUNK - 1, fileSize - 1);
                        if (rangeHdr != null) {
                            String[] ranges = rangeHdr.replace("bytes=", "").split("-");
                            rangeStart = Long.parseLong(ranges[0]);
                            rangeEnd   = ranges.length > 1 ? Long.parseLong(ranges[1]) : fileSize - 1;
                        }
                        long contentLength = rangeEnd - rangeStart + 1;

                        try (RandomAccessFile file = new RandomAccessFile(filePath.toFile(), "r")) {
                            file.seek(rangeStart);
                            byte[] buffer = new byte[(int) contentLength];
                            file.readFully(buffer);
                            headers.add(HttpHeaders.CONTENT_RANGE,
                                    String.format("bytes %d-%d/%d", rangeStart, rangeEnd, fileSize));
                            return ResponseEntity.status(HttpStatus.PARTIAL_CONTENT)
                                    .headers(headers)
                                    .contentLength(contentLength)
                                    .body(new ByteArrayResource(buffer));
                        }
                    }
                }
                return ResponseEntity.notFound().build();
            } else {
                return ResponseEntity.ok("Filename is null.");
            }
        } catch (Exception e) {
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // =========================================================================
    // SERVE DASH SEGMENT FILE
    // =========================================================================
    public ResponseEntity<Resource> getVideoSegment(@PathVariable Long id, @PathVariable String filename) {
        try {
            Optional<VideoDescription> optionalVideo = videodescriptionRepository.findById(id);
            if (!optionalVideo.isPresent()) return ResponseEntity.notFound().build();

            String folderPath = optionalVideo.get().getFoldername();
            Path dashFolder   = Paths.get(folderPath, "dash");
            Path segmentPath  = dashFolder.resolve(filename).normalize();

            if (!segmentPath.startsWith(dashFolder)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }
            if (!Files.exists(segmentPath)) return ResponseEntity.notFound().build();

            Resource resource = new UrlResource(segmentPath.toUri());
            String mimeType   = Files.probeContentType(segmentPath);
            if (mimeType == null) mimeType = MediaType.APPLICATION_OCTET_STREAM_VALUE;

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_TYPE, mimeType)
                    .body(resource);
        } catch (Exception e) {
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // =========================================================================
    // UPDATE VIDEO DESCRIPTION
    // =========================================================================
    public ResponseEntity<?> updateVideoDescription(
            @PathVariable("videoId") Long videoId,
            @RequestParam(value = "videoTitle",          required = false) String videoTitle,
            @RequestParam(value = "mainVideoDuration",   required = false) String mainVideoDuration,
            @RequestParam(value = "trailerDuration",     required = false) String trailerDuration,
            @RequestParam(value = "rating",              required = false) String rating,
            @RequestParam(value = "language",            required = false) String language,
            @RequestParam(value = "certificateNumber",   required = false) String certificateNumber,
            @RequestParam(value = "videoAccessType",     required = false) Boolean videoAccessType,
            @RequestParam(value = "description",         required = false) String description,
            @RequestParam(value = "productionCompany",   required = false) String productionCompany,
            @RequestParam(value = "certificateName",     required = false) String certificateName,
            @RequestParam(value = "castandcrewlist",     required = false) List<Long> castandcrewlist,
            @RequestParam(value = "taglist",             required = false) List<Long> taglist,
            @RequestParam(value = "categorylist",        required = false) List<Long> categorylist,
            @RequestParam(value = "videoThumbnail",      required = false) MultipartFile videoThumbnail,
            @RequestParam(value = "trailerThumbnail",    required = false) MultipartFile trailerThumbnail,
            @RequestParam(value = "userBanner",          required = false) MultipartFile userBanner,
            @RequestParam(value = "video",               required = false) MultipartFile video,
            @RequestParam(value = "trailervideo",        required = false) MultipartFile trailervideo,
            @RequestParam(value = "advertisementTimings",required = false) List<String> advertisementTimings,
            @RequestHeader("Authorization") String token) {

        try {
            if (!jwtUtil.validateToken(token)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
            String email = jwtUtil.getUsernameFromToken(token);
            Optional<AddUser> opUser = adduserrepository.findByUsername(email);
            if (!opUser.isPresent()) return ResponseEntity.status(HttpStatus.NOT_FOUND).build();

            Optional<VideoDescription> optionalVideoDescription = videodescriptionRepository.findById(videoId);
            if (!optionalVideoDescription.isPresent()) return ResponseEntity.status(HttpStatus.NOT_FOUND).build();

            VideoDescription videoDescription = optionalVideoDescription.get();

            // Handle video file update
            if (video != null) {
                String existing = videoDescription.getVidofilename();
                if (existing != null) fileSevice.deleteVideoFile(existing);
                FileModel upload = fileSevice.uploadVideo(path, video);
                videoDescription.setVidofilename(upload.getVideoFileName());
            }
            // Handle trailer video file update
            if (trailervideo != null) {
                String existing = videoDescription.getVideotrailerfilename();
                if (existing != null) fileSevice.deletetrailerFile(existing);
                FileModel uploadTrailer = fileSevice.uploadTrailerVideo(trailervideoPath, trailervideo);
                videoDescription.setVideotrailerfilename(uploadTrailer.getVideotrailerfilename());
            }

            if (videoTitle       != null) videoDescription.setVideoTitle(videoTitle);
            if (mainVideoDuration!= null) videoDescription.setMainVideoDuration(mainVideoDuration);
            if (trailerDuration  != null) videoDescription.setTrailerDuration(trailerDuration);
            if (rating           != null) videoDescription.setRating(rating);
            if (language         != null) videoDescription.setLanguage(language);
            if (certificateNumber!= null) videoDescription.setCertificateNumber(certificateNumber);
            if (videoAccessType  != null) videoDescription.setVideoAccessType(videoAccessType);
            if (description      != null) videoDescription.setDescription(description);
            if (productionCompany!= null) videoDescription.setProductionCompany(productionCompany);
            if (certificateName  != null) videoDescription.setCertificateName(certificateName);
            if (castandcrewlist  != null) videoDescription.setCastandcrewlist(castandcrewlist);
            if (taglist          != null) videoDescription.setTaglist(taglist);
            if (categorylist     != null) videoDescription.setCategorylist(categorylist);
            if (advertisementTimings != null) videoDescription.setAdvertisementTimings(advertisementTimings);

            VideoDescription updated = videodescriptionRepository.save(videoDescription);

            Optional<VideoImage> optionalVideoImage = videoimagerepository.findVideoById(videoId);
            VideoImage videoImage = optionalVideoImage.orElseGet(() -> {
                VideoImage vi = new VideoImage();
                vi.setVideoId(videoId);
                return vi;
            });

            try {
                if (videoThumbnail  != null) videoImage.setVideoThumbnail(ImageUtils.compressImage(videoThumbnail.getBytes()));
                if (trailerThumbnail!= null) videoImage.setTrailerThumbnail(ImageUtils.compressImage(trailerThumbnail.getBytes()));
                if (userBanner      != null) videoImage.setUserBanner(ImageUtils.compressImage(userBanner.getBytes()));
            } catch (IOException e) {
                logger.error("Image compression failed during update", e);
            }
            videoimagerepository.save(videoImage);

            Map<String, Object> response = new HashMap<>();
            response.put("videoDescription", updated);
            response.put("videoImage", videoImage);
            return ResponseEntity.ok().body(response);

        } catch (IOException e) {
            logger.error("updateVideoDescription failed", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    // =========================================================================
    // DELETE VIDEO BY ID
    // =========================================================================
    public ResponseEntity<?> deleteVideoDescription(
            @PathVariable("videoId") Long videoId,
            @RequestHeader("Authorization") String token) {
        try {
            if (!jwtUtil.validateToken(token)) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            String email = jwtUtil.getUsernameFromToken(token);
            Optional<AddUser> opUser = adduserrepository.findByUsername(email);
            if (!opUser.isPresent()) return ResponseEntity.status(HttpStatus.NOT_FOUND).build();

            Optional<VideoDescription> optionalVideoDescription = videodescriptionRepository.findById(videoId);
            if (!optionalVideoDescription.isPresent()) return ResponseEntity.status(HttpStatus.NOT_FOUND).build();

            VideoDescription videoDescription = optionalVideoDescription.get();
            String videoFileName   = videoDescription.getVidofilename();
            String trailerFileName = videoDescription.getVideotrailerfilename();
            if (videoFileName   != null) fileSevice.deleteVideoFile(videoFileName);
            if (trailerFileName != null) fileSevice.deletetrailerFile(trailerFileName);

            videodescriptionRepository.deleteById(videoId);
            videoimagerepository.deleteByVideoId(videoId);
            return ResponseEntity.ok().build();

        } catch (IOException e) {
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    // =========================================================================
    // DELETE MULTIPLE VIDEOS
    // =========================================================================
    public ResponseEntity<?> deleteMultiplevideos(
            @RequestHeader("Authorization") String token,
            @RequestBody List<Long> videoIds) {
        try {
            if (!jwtUtil.validateToken(token)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body("{\"message\": \"Invalid or expired token.\"}");
            }
            String email = jwtUtil.getUsernameFromToken(token);
            Optional<AddUser> opUser = adduserrepository.findByUsername(email);
            if (!opUser.isPresent()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body("{\"message\": \"User not authorized.\"}");
            }

            List<Long> notFoundVideoIds = new ArrayList<>();
            List<Long> deletedVideoIds  = new ArrayList<>();

            for (Long videoId : videoIds) {
                Optional<VideoDescription> opt = videodescriptionRepository.findById(videoId);
                if (opt.isPresent()) {
                    VideoDescription vd = opt.get();
                    try {
                        if (vd.getVidofilename()         != null) fileSevice.deleteVideoFile(vd.getVidofilename());
                        if (vd.getVideotrailerfilename() != null) fileSevice.deletetrailerFile(vd.getVideotrailerfilename());
                    } catch (IOException e) {
                        logger.error("", e);
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body("{\"message\": \"Error deleting file for video ID " + videoId + ".\"}");
                    }
                    videodescriptionRepository.deleteById(videoId);
                    videoimagerepository.deleteByVideoId(videoId);
                    deletedVideoIds.add(videoId);
                } else {
                    notFoundVideoIds.add(videoId);
                }
            }

            if (!notFoundVideoIds.isEmpty()) {
                return ResponseEntity.status(HttpStatus.PARTIAL_CONTENT)
                        .body("{\"message\": \"Some videos not found.\", \"deletedVideoIds\": "
                                + deletedVideoIds + ", \"notFoundVideoIds\": " + notFoundVideoIds + "}");
            }
            return ResponseEntity.ok("{\"message\": \"Videos deleted successfully.\", \"deletedVideoIds\": " + deletedVideoIds + "}");

        } catch (Exception e) {
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("{\"message\": \"An error occurred while deleting videos.\"}");
        }
    }

    // =========================================================================
    // GET VIDEO IDS BY CATEGORY
    // =========================================================================
    public List<Long> getVideoImagesByCategory(@RequestParam Long categoryId) {
        List<VideoDescription> videos = videodescriptionRepository.findAll();
        List<Long> videoIds = new ArrayList<>();
        for (VideoDescription video : videos) {
            if (video.getCategorylist().contains(categoryId)) {
                videoIds.add(video.getId());
            }
        }
        return videoIds;
    }

    // =========================================================================
    // GET VIDEO SCREEN DETAILS
    // =========================================================================
    public ResponseEntity<VideoScreenDTO> getVideoScreenDetails(Long videoId, Long categoryId) {
        if (videoId == null || categoryId == null) {
            return ResponseEntity.badRequest().build();
        }
        Optional<VideoDescription> videoOpt = videodescriptionRepository.findById(videoId);
        if (!videoOpt.isPresent()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);

        VideoDescription video = videoOpt.get();
        List<CastAndCrewModalDTO> castAndCrewDetails = new ArrayList<>();
        for (Long castId : video.getCastandcrewlist()) {
            castandcrewrepository.findById(castId).ifPresent(cc ->
                    castAndCrewDetails.add(new CastAndCrewModalDTO(cc.getId(), cc.getName(), cc.getDescription())));
        }

        List<String> categoryValues = addnewcategoriesrepository.findcategoryByIds(video.getCategorylist());
        List<VideoDescription> matchingVideos = videodescriptionRepository.findAll()
                .stream()
                .filter(v -> v.getCategorylist().contains(categoryId))
                .collect(Collectors.toList());

        VideoScreenDTO dto = new VideoScreenDTO(
                video.getId(), video.getVideoTitle(), video.getMainVideoDuration(),
                video.isVideoAccessType(), categoryValues, castAndCrewDetails,
                video.getDescription(), matchingVideos);

        return ResponseEntity.ok(dto);
    }

    // =========================================================================
    // GET USER ACCESS
    // =========================================================================
    public ResponseEntity<?> getUserAccess(@RequestParam(value = "userId", required = false) Long userId) {
        if (userId == null) return ResponseEntity.badRequest().body("userId is required");
        Optional<UserRegister> userOpt = userregisterrepository.findById(userId);
        if (!userOpt.isPresent()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");

        UserRegister user = userOpt.get();
        if (user.getPaymentId() != null && user.getPaymentId().getExpiryDate() != null) {
            if (user.getPaymentId().getExpiryDate().isAfter(LocalDate.now())) {
                return ResponseEntity.ok("Access granted");
            }
        }
        return ResponseEntity.ok("Not Paid");
    }
}