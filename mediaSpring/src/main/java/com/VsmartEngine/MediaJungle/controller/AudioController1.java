package com.VsmartEngine.MediaJungle.controller;

import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import com.VsmartEngine.MediaJungle.compresser.ImageUtils;
import com.VsmartEngine.MediaJungle.fileservice.AudioFileService;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.model.Addaudio1;
import com.VsmartEngine.MediaJungle.model.Audioimages;
import com.VsmartEngine.MediaJungle.notification.service.NotificationService;
import com.VsmartEngine.MediaJungle.repository.AddAudioRepository;
import com.VsmartEngine.MediaJungle.repository.AddAudiodescription;
import com.VsmartEngine.MediaJungle.repository.AddNewCategoriesRepository;
import com.VsmartEngine.MediaJungle.repository.AddUserRepository;
import com.VsmartEngine.MediaJungle.repository.Audioimage;
import com.VsmartEngine.MediaJungle.service.AudioService;
import com.VsmartEngine.MediaJungle.userregister.JwtUtil;
import com.VsmartEngine.MediaJungle.userregister.UserRegisterRepository;
import jakarta.servlet.http.HttpServletRequest;

@Controller
public class AudioController1 {

    @Autowired
    private AddAudiodescription audio;

    @Autowired
    private Audioimage audioI;

    @Autowired
    private AudioService audioservice;

    @Autowired
    private AddAudioRepository audiorepository;

    @Autowired
    private NotificationService notificationservice;

    @Autowired
    private AddNewCategoriesRepository addnewcategoriesrepository;

    @Autowired
    private AudioFileService fileService;

    @Autowired private JwtUtil jwtUtil;
    @Autowired private AddUserRepository adduserrepository;
    @Autowired private UserRegisterRepository userregisterrepository;

    // Injected from application.properties — used to resolve filenames to full paths at runtime
    @Value("${upload.audio.directory}")
    private String audioUploadDirectory;

    private static final String filename = "Audio/data.xml";
    private static final Logger logger = LoggerFactory.getLogger(AudioController1.class);


    public ResponseEntity<Addaudio1> uploadAudio(@RequestParam("category") Long categoryId,
                                                 @RequestParam("audioFile") MultipartFile audioFile,
                                                 @RequestParam("thumbnail") MultipartFile thumbnail,
                                                 @RequestParam(value = "paid", required = false) boolean paid,
                                                 @RequestHeader("Authorization") String token) {
        try {
            if (!jwtUtil.validateToken(token)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }

            String email = jwtUtil.getUsernameFromToken(token);
            Optional<AddUser> opUser = adduserrepository.findByUsername(email);

            if (opUser.isPresent()) {
                AddUser user = opUser.get();
                String username = user.getUsername();

                Addaudio1 savedAudio = audioservice.saveAudioWithFile(audioFile, thumbnail, categoryId, paid);

                String heading = "New Audio Added!";
                Long notifyId = notificationservice.createNotification(username, email, heading, Optional.ofNullable(thumbnail));
                if (notifyId != null) {
                    Set<String> notiUserSet = new HashSet<>();
                    List<AddUser> adminUsers = adduserrepository.findAll();
                    for (AddUser admin : adminUsers) {
                        notiUserSet.add(admin.getEmail());
                    }
                    notificationservice.CommoncreateNotificationAdmin(notifyId, new ArrayList<>(notiUserSet));
                }

                return ResponseEntity.ok().body(savedAudio);
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
        } catch (IOException e) {
            e.printStackTrace();
            logger.error("Upload audio failed", e);
            return ResponseEntity.badRequest().build();
        }
    }


    /**
     * Streams an audio file by filename.
     * The 'filename' path variable contains only the stored filename (e.g. "1234_song.mp3").
     * The full path is resolved here using the configured upload directory.
     */
    public ResponseEntity<Resource> getAudioFile(String filename, HttpServletRequest request) {
        if (filename == null || filename.isBlank()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }

        // Always resolve the file relative to the configured upload directory.
        // This prevents the "NoResourceFoundException" caused by storing absolute paths in DB.
        Path filePath = Paths.get(audioUploadDirectory).resolve(filename).normalize();
        System.out.println("Resolved audio file path: " + filePath.toAbsolutePath());

        try {
            if (!Files.exists(filePath) || !Files.isRegularFile(filePath)) {
                System.out.println("Audio file not found: " + filePath.toAbsolutePath());
                return ResponseEntity.notFound().build();
            }

            Resource resource = new UrlResource(filePath.toUri());
            if (!resource.exists() || !resource.isReadable()) {
                return ResponseEntity.notFound().build();
            }

            HttpHeaders headers = new HttpHeaders();
            String mimeType = Files.probeContentType(filePath);
            if (mimeType == null) {
                mimeType = MediaType.APPLICATION_OCTET_STREAM_VALUE;
            }
            headers.add(HttpHeaders.CONTENT_TYPE, mimeType);
            headers.add(HttpHeaders.CONTENT_DISPOSITION, "inline");

            final long INITIAL_CHUNK_SIZE = 2 * 1024 * 1024; // 2 MB
            long fileSize = Files.size(filePath);
            String rangeHeader = request.getHeader(HttpHeaders.RANGE);

            long rangeStart;
            long rangeEnd;

            if (rangeHeader != null) {
                String[] ranges = rangeHeader.replace("bytes=", "").split("-");
                rangeStart = Long.parseLong(ranges[0]);
                rangeEnd = ranges.length > 1 && !ranges[1].isBlank()
                        ? Long.parseLong(ranges[1])
                        : fileSize - 1;
            } else {
                rangeStart = 0;
                rangeEnd = Math.min(INITIAL_CHUNK_SIZE - 1, fileSize - 1);
            }

            long contentLength = rangeEnd - rangeStart + 1;
            System.out.println("Range: " + rangeStart + "-" + rangeEnd + ", Length: " + contentLength);

            try (RandomAccessFile file = new RandomAccessFile(filePath.toFile(), "r")) {
                file.seek(rangeStart);
                byte[] buffer = new byte[(int) contentLength];
                file.readFully(buffer);

                ByteArrayResource byteArrayResource = new ByteArrayResource(buffer);
                headers.add(HttpHeaders.CONTENT_RANGE,
                        String.format("bytes %d-%d/%d", rangeStart, rangeEnd, fileSize));

                return ResponseEntity.status(HttpStatus.PARTIAL_CONTENT)
                        .headers(headers)
                        .contentLength(contentLength)
                        .body(byteArrayResource);
            }

        } catch (Exception e) {
            e.printStackTrace();
            logger.error("Error streaming audio file: " + filename, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }


    public ResponseEntity<Addaudio1> getAudioById(@PathVariable Long id) {
        try {
            Addaudio1 audio = audioservice.getAudioById(id);
            if (audio != null) {
                return ResponseEntity.ok().body(audio);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            return ResponseEntity.badRequest().build();
        }
    }


    public ResponseEntity<Resource> getAudioFile(String id) throws IOException {
        Path audioFilePath = Paths.get(audioUploadDirectory).resolve(id).normalize();

        if (Files.exists(audioFilePath) && Files.isRegularFile(audioFilePath)) {
            Resource resource = new UrlResource(audioFilePath.toUri());
            if (resource.exists() && resource.isReadable()) {
                return ResponseEntity.ok()
                        .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_OCTET_STREAM_VALUE)
                        .body(resource);
            }
        }
        return ResponseEntity.notFound().build();
    }


    public ResponseEntity<List<String>> listAudioFiles() throws IOException {
        Path audioFolder = Paths.get(audioUploadDirectory);

        if (Files.exists(audioFolder) && Files.isDirectory(audioFolder)) {
            try (DirectoryStream<Path> directoryStream = Files.newDirectoryStream(audioFolder)) {
                List<String> audioFiles = new ArrayList<>();
                for (Path path : directoryStream) {
                    if (Files.isRegularFile(path)) {
                        audioFiles.add(path.getFileName().toString());
                    }
                }
                return ResponseEntity.ok(audioFiles);
            }
        } else {
            return ResponseEntity.notFound().build();
        }
    }


    public ResponseEntity<List<Addaudio1>> getAllUser() {
        List<Addaudio1> getUser = audiorepository.findAll();
        return new ResponseEntity<>(getUser, HttpStatus.OK);
    }


    public ResponseEntity<Addaudio1> getAudioDetail(@PathVariable Long id) {
        try {
            Optional<Addaudio1> audioDetail = audiorepository.findById(id);
            if (audioDetail.isPresent()) {
                return new ResponseEntity<>(audioDetail.get(), HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            logger.error("", e);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }


    public ResponseEntity<String> getAudioFilename(@PathVariable Long id) {
        try {
            String fname = audioservice.getAudioFilename(id);
            return ResponseEntity.ok().body(fname);
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }


    public ResponseEntity<List<byte[]>> getAllThumbnail() {
        List<Addaudio1> getAudio = audiorepository.findAll();
        for (Addaudio1 audio : getAudio) {
            byte[] images = ImageUtils.decompressImage(audio.getThumbnail());
            audio.setThumbnail(images);
        }
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(getAudio.stream().map(Addaudio1::getThumbnail).collect(Collectors.toList()));
    }


    public ResponseEntity<List<String>> getThumbnailsById(@PathVariable Long id) {
        try {
            Optional<Addaudio1> audioOptional = audiorepository.findById(id);
            if (audioOptional.isPresent()) {
                Addaudio1 audio = audioOptional.get();
                byte[] thumbnailData = ImageUtils.decompressImage(audio.getThumbnail());
                String base64Thumbnail = Base64.getEncoder().encodeToString(thumbnailData);
                return ResponseEntity.ok(Collections.singletonList(base64Thumbnail));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }


    // NEW AUDIO THUMBNAIL API
    public ResponseEntity<?> getaudioThumbnailsById(@PathVariable Long id) {
        try {
            Optional<Audioimages> audioThumbnail = audioI.findById(id);

            if (audioThumbnail.isPresent()) {
                Audioimages audioImage = audioThumbnail.get();
                byte[] thumbnailData = ImageUtils.decompressImage(audioImage.getAudio_thumbnail());
                String base64Thumbnail = Base64.getEncoder().encodeToString(thumbnailData);
                return ResponseEntity.ok(Collections.singletonMap("thumbnail", base64Thumbnail));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }


    // NEW AUDIO BANNER API
    public ResponseEntity<List<String>> getaudiobannerById(@PathVariable Long id) {
        try {
            Optional<Audioimages> audioThumbnail = audioI.findById(id);

            if (audioThumbnail.isPresent()) {
                Audioimages audioImage = audioThumbnail.get();
                byte[] thumbnailData = ImageUtils.decompressImage(audioImage.getBannerthumbnail());
                String base64Thumbnail = Base64.getEncoder().encodeToString(thumbnailData);
                return ResponseEntity.ok(Collections.singletonList(base64Thumbnail));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }


    public ResponseEntity<Map<String, String>> deleteAudioById(@PathVariable Long id,
                                                               @RequestHeader("Authorization") String token) {
        try {
            if (!jwtUtil.validateToken(token)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid token"));
            }

            String email = jwtUtil.getUsernameFromToken(token);
            Optional<AddUser> optionalUser = adduserrepository.findByUsername(email);

            if (optionalUser.isPresent()) {
                AddUser user = optionalUser.get();
                String username = user.getUsername();

                Optional<Addaudio1> optionalAudio = audiorepository.findById(id);
                if (optionalAudio.isEmpty()) {
                    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "Audio not found"));
                }

                Addaudio1 audioEntity = optionalAudio.get();
                byte[] image = audioEntity.getThumbnail();

                boolean deleted = audioservice.deleteAudioById(id);
                if (!deleted) {
                    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "Audio deletion failed"));
                }

                String heading = "Audio Deleted!";
                Long notifyId = notificationservice.createNotification(username, email, heading, image);
                if (notifyId != null) {
                    Set<String> notiUserSet = new HashSet<>();
                    List<AddUser> adminUsers = adduserrepository.findAll();
                    for (AddUser admin : adminUsers) {
                        notiUserSet.add(admin.getEmail());
                    }
                    notificationservice.CommoncreateNotificationAdmin(notifyId, new ArrayList<>(notiUserSet));
                }

                return ResponseEntity.ok(Map.of("message", "Audio deleted successfully"));
            } else {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("error", "User not authorized"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", "An error occurred"));
        }
    }


    public ResponseEntity<?> updateAudio(
            @PathVariable Long audioId,
            @RequestParam(value = "audioFile", required = false) MultipartFile audioFile,
            @RequestParam(value = "thumbnail", required = false) MultipartFile thumbnail,
            @RequestParam(value = "category", required = false) Long categoryId,
            @RequestHeader("Authorization") String token) {
        try {
            if (!jwtUtil.validateToken(token)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token");
            }

            String email = jwtUtil.getUsernameFromToken(token);
            Optional<AddUser> opUser = adduserrepository.findByUsername(email);
            if (!opUser.isPresent()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
            }

            AddUser user = opUser.get();
            String username = user.getUsername();

            if (!audioservice.existsById(audioId)) {
                return ResponseEntity.notFound().build();
            }

            Addaudio1 updatedAudio = audioservice.updateAudioWithFile(audioId, audioFile, thumbnail, categoryId);
            byte[] image = updatedAudio.getThumbnail();

            String heading = "Audio details Updated!";
            Long notifyId = notificationservice.createNotification(username, email, heading, image);
            if (notifyId != null) {
                Set<String> notiUserSet = new HashSet<>();
                List<AddUser> adminUsers = adduserrepository.findAll();
                for (AddUser admin : adminUsers) {
                    notiUserSet.add(admin.getEmail());
                }
                notificationservice.CommoncreateNotificationAdmin(notifyId, new ArrayList<>(notiUserSet));
            }

            return ResponseEntity.ok().body(updatedAudio);
        } catch (IOException e) {
            e.printStackTrace();
            logger.error("", e);
            return ResponseEntity.badRequest().build();
        }
    }
}