package com.VsmartEngine.MediaJungle.ffmpeg;

import java.io.*;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.CompletableFuture;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import com.VsmartEngine.MediaJungle.video.AddVideoDescriptionRepository;
import com.VsmartEngine.MediaJungle.video.VideoDescription;

@Service
public class FFmpegService {

    private static final Logger logger = LoggerFactory.getLogger(FFmpegService.class);

    @Value("${ffmpeg.path}")
    private String ffmpegPath;

    @Autowired
    private AddVideoDescriptionRepository videodescriptionRepository;

    // ─────────────────────────────────────────────────────────────────────────
    // PUBLIC ASYNC entry point — called from VideoController.
    // Returns immediately; DASH encoding runs in the background thread pool.
    // Updates dashStatus to "READY" or "FAILED" when done.
    // ─────────────────────────────────────────────────────────────────────────
    @Async("dashTaskExecutor")
    public CompletableFuture<Void> generateDASHAsync(String inputFile, String outputDir, long videoId) {
        try {
            logger.info("[DASH] Starting async DASH generation for videoId={} file={}", videoId, inputFile);
            generateDASH(inputFile, outputDir);
            // Mark as READY
            videodescriptionRepository.findById(videoId).ifPresent(v -> {
                v.setDashStatus("READY");
                videodescriptionRepository.save(v);
                logger.info("[DASH] Completed for videoId={}", videoId);
            });
        } catch (Exception e) {
            logger.error("[DASH] Failed for videoId={}", videoId, e);
            // Mark as FAILED so the admin can retry / know it failed
            videodescriptionRepository.findById(videoId).ifPresent(v -> {
                v.setDashStatus("FAILED");
                videodescriptionRepository.save(v);
            });
        }
        return CompletableFuture.completedFuture(null);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Core DASH generation — encodes 480p / 720p / 1080p only (4K removed to
    // cut processing time by ~40-60 %).  Preset changed to "veryfast" for
    // better speed/quality balance vs "ultrafast".
    // ─────────────────────────────────────────────────────────────────────────
    public void generateDASH(String inputFile, String outputDir) throws IOException, InterruptedException {

        File outputFolder = new File(outputDir);
        if (!outputFolder.exists()) {
            outputFolder.mkdirs();
        }

        List<String> command = Arrays.asList(
                ffmpegPath, "-y", "-i", inputFile,

                // ── 480p (SD) ──────────────────────────────────────────────
                "-map", "0:v:0", "-b:v:0", "500k",  "-s", "854x480",
                "-c:v", "libx264", "-preset", "veryfast",
                "-g", "60", "-sc_threshold", "0", "-keyint_min", "60",

                // ── 720p (HD) ──────────────────────────────────────────────
                "-map", "0:v:0", "-b:v:1", "2500k", "-s", "1280x720",
                "-c:v", "libx264", "-preset", "veryfast",
                "-g", "60", "-sc_threshold", "0", "-keyint_min", "60",

                // ── 1080p (Full HD) ────────────────────────────────────────
                "-map", "0:v:0", "-b:v:2", "5000k", "-s", "1920x1080",
                "-c:v", "libx264", "-preset", "veryfast",
                "-g", "60", "-sc_threshold", "0", "-keyint_min", "60",

                // ── Audio ──────────────────────────────────────────────────
                "-map", "0:a:0", "-b:a", "128k", "-c:a", "aac",

                // ── DASH manifest ──────────────────────────────────────────
                "-use_timeline", "1", "-use_template", "1",
                "-adaptation_sets", "id=0,streams=v id=1,streams=a",
                "-init_seg_name",  "init_$RepresentationID$.m4s",
                "-media_seg_name", "chunk_$RepresentationID$_$Number$.m4s",
                "-seg_duration", "4",
                "-dash_segment_type", "mp4",
                "-f", "dash",
                outputDir + "/manifest.mpd"
        );

        ProcessBuilder processBuilder = new ProcessBuilder(command);
        processBuilder.redirectErrorStream(true);
        Process process = processBuilder.start();

        // Stream FFmpeg output to logger (non-blocking)
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                logger.debug("[FFmpeg] {}", line);
            }
        }

        int exitCode = process.waitFor();
        if (exitCode == 0) {
            logger.info("[DASH] Segmentation completed successfully for output={}", outputDir);
        } else {
            logger.error("[DASH] FFmpeg exited with code {} for output={}", exitCode, outputDir);
            throw new IOException("FFmpeg exited with code " + exitCode);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Parallel encode helper (kept for optional use)
    // ─────────────────────────────────────────────────────────────────────────
    public void generateDASHInParallel(String inputFile, String outputDir) throws InterruptedException {
        Thread t480 = new Thread(() -> {
            try { generateVideo(inputFile, outputDir, "480p",  "500k",  "854x480");  } catch (Exception e) { logger.error("", e); }
        });
        Thread t720 = new Thread(() -> {
            try { generateVideo(inputFile, outputDir, "720p",  "1000k", "1280x720"); } catch (Exception e) { logger.error("", e); }
        });
        Thread t1080 = new Thread(() -> {
            try { generateVideo(inputFile, outputDir, "1080p", "2000k", "1920x1080"); } catch (Exception e) { logger.error("", e); }
        });

        t480.start(); t720.start(); t1080.start();
        t480.join();  t720.join();  t1080.join();

        try { generateAudioAndManifest(inputFile, outputDir); }
        catch (IOException e) { logger.error("[DASH] Audio/Manifest generation failed", e); }
    }

    private void generateVideo(String inputFile, String outputDir,
                                String resolution, String bitrate, String size)
            throws IOException, InterruptedException {

        List<String> command = Arrays.asList(
                ffmpegPath, "-i", inputFile,
                "-map", "0:v:0", "-b:v", bitrate, "-s", size,
                "-c:v", "libx264", "-preset", "veryfast", "-threads", "4",
                "-f", "mp4", outputDir + "/video_" + resolution + ".mp4"
        );
        runProcess(command, "Video-" + resolution);
    }

    private void generateAudioAndManifest(String inputFile, String outputDir)
            throws IOException, InterruptedException {

        List<String> audioCmd = Arrays.asList(
                ffmpegPath, "-i", inputFile,
                "-map", "0:a:0", "-c:a", "copy",
                "-f", "mp4", outputDir + "/audio.mp4"
        );
        runProcess(audioCmd, "Audio-extract");

        List<String> manifestCmd = Arrays.asList(
                ffmpegPath, "-i", inputFile,
                "-use_timeline", "1", "-use_template", "1",
                "-adaptation_sets", "id=0,streams=v id=1,streams=a",
                "-f", "dash",
                "-init_seg_name",  "init_$RepresentationID$.m4s",
                "-media_seg_name", "chunk_$RepresentationID$_$Number$.m4s",
                "-seg_duration", "6",
                "-dash_segment_type", "mp4",
                outputDir + "/manifest.mpd"
        );
        runProcess(manifestCmd, "DASH-manifest");
    }

    private void runProcess(List<String> command, String label) throws IOException, InterruptedException {
        ProcessBuilder pb = new ProcessBuilder(command);
        pb.redirectErrorStream(true);
        Process p = pb.start();
        try (BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream()))) {
            String line;
            while ((line = r.readLine()) != null) { logger.debug("[{}] {}", label, line); }
        }
        int code = p.waitFor();
        if (code != 0) throw new IOException(label + " failed with exit code " + code);
        logger.info("[{}] Completed successfully", label);
    }
}
