package com.VsmartEngine.MediaJungle.File;

import java.io.File;
import java.io.FileInputStream;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.VsmartEngine.MediaJungle.LogManagement;

@RestController
@RequestMapping("/api/v2")
public class XmlController {

    private final XmlFileService xmlFileService;

    private static final Logger logger = LoggerFactory.getLogger(XmlFileService.class);
    
    public XmlController(XmlFileService xmlFileService) {
        this.xmlFileService = xmlFileService;
    }
    
    @GetMapping("/download")
    public ResponseEntity<InputStreamResource> downloadXml() {
        String fileName = "data.xml";
        Path tempDir = Paths.get(System.getProperty("java.io.tmpdir"));
        String filePath = tempDir.resolve(fileName).toString();

        try {
            // Parameters for XML file
            String trainer = "100";
            String student = "100";
            String validity = "30";
            String course = "100";
            String type = "FREE";
            String companyName = "Meganar Technologies";
            String productName = "LearnHub";
            String storageSize = "100";
            String version = "4.0";

            // Generate XML file
            xmlFileService.createXmlFile(filePath, trainer, student, validity, course, type, companyName, storageSize, productName, version);

            File file = new File(filePath);
            if (!file.exists()) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
            }

            InputStreamResource resource = new InputStreamResource(new FileInputStream(file));

            HttpHeaders headers = new HttpHeaders();
            headers.setContentDispositionFormData("attachment", fileName);
            headers.setContentType(MediaType.APPLICATION_XML);

            // Serve the file as a response
            return ResponseEntity.ok()
                    .headers(headers)
                    .contentLength(file.length())
                    .body(resource);
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            return ResponseEntity.internalServerError().build();
        }
    }

}
