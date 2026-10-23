package com.VsmartEngine.MediaJungle.service;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.compresser.ImageUtils;
import com.VsmartEngine.MediaJungle.exception.AudioNotFoundException;
import com.VsmartEngine.MediaJungle.fileservice.AudioFileService;
import com.VsmartEngine.MediaJungle.model.AddNewCategories;
import com.VsmartEngine.MediaJungle.model.Addaudio1;
import com.VsmartEngine.MediaJungle.model.License;
import com.VsmartEngine.MediaJungle.repository.AddAudioRepository;
import com.VsmartEngine.MediaJungle.repository.AddNewCategoriesRepository;
import com.VsmartEngine.MediaJungle.repository.licenseRepository;

import jakarta.persistence.EntityNotFoundException;
@Service
public class AudioService {
	
	@Autowired
    private AddAudioRepository audiorepository;

    @Autowired
	private AddNewCategoriesRepository addnewcategoriesrepository;
    
    @Autowired
    private AudioFileService fileService;
   
    @Autowired
    private licenseRepository licenseRepository;
    
    private static final Logger logger = LoggerFactory.getLogger(AudioService.class);
    
    public Addaudio1 saveAudioWithFile(MultipartFile audioFile, MultipartFile thumbnail, Long categoryId ,boolean paid) throws IOException {
        // Save the audio file to the server and get the file path
        String audioFilePath = fileService.saveAudioFile(audioFile);
        byte[] thumbnailBytes =ImageUtils.compressImage(thumbnail.getBytes());
        Optional<AddNewCategories> categoryOptional = addnewcategoriesrepository.findById(categoryId);
        AddNewCategories category = categoryOptional.orElse(new AddNewCategories());
        // Create an AddAudio entity and set other fields
        Addaudio1 newaudio = new Addaudio1();
        newaudio.setCategory(category);
        newaudio.setFileName(audioFilePath);
        newaudio.setThumbnail(thumbnailBytes);
        newaudio.setPaid(paid);        
        // Save the AddAudio entity to the database
        return audiorepository.save(newaudio);
    }
    
//    ---------------------------------------------
    public  Addaudio1 saveFile(MultipartFile audioFile) throws IOException {
        // Save the audio file to the server and get the file path
         fileService.savFile(audioFile);
//        license
          
        return null ;
    }
    
    
//    ----------------------------------------
    public String getall(){
    	
    	Iterable<License> licenseIterable = licenseRepository.findAll();
    	List<License> licenseList = StreamSupport.stream(licenseIterable.spliterator(), false)
    	                                         .collect(Collectors.toList());
    	for (License license : licenseList) {
    	    System.out.println("ID: " + license.getId());
    	    System.out.println("Company Name: " + license.getCompany_name());
    	    System.out.println("Product Name: " + license.getProduct_name());
    	    System.out.println("key " + license.getKey());
    	    System.out.println("start_date: " + license.getStart_date());
    	    System.out.println("end_date: " + license.getEnd_date());
    	    LocalDate currentDate = LocalDate.now();
            java.util.Date Datecurrent = java.sql.Date.valueOf(currentDate);
    	    System.out.println(" start date :"+license.getStart_date()+" present date :"+Datecurrent+" is equal"+license.getStart_date().equals(Datecurrent));
    	    
    	    
    	    
    	    
    	    // Print other fields as needed
    	}

//    	  List<Addaudio1> allAudio = audiorepository.findAll();
    	
    	return null;
    }
    
    
    
//   -------------------------------
    public String licensedetails(String product_name, String company_name, String key, String validity) {
    	License data =new License();
        LocalDate currentDate = LocalDate.now();
        java.util.Date Datecurrent = java.sql.Date.valueOf(currentDate);
        int num = Integer.parseInt(validity);
        LocalDate futureDate = currentDate.plusDays(num);
        java.util.Date Datefuture = java.sql.Date.valueOf(futureDate);
        data.setStart_date(Datecurrent);
        
//        if(utilDatefuture.equals(utilDatecurrent))
//        {
//        	System.out.println("same");
//        }
//        else {
//        	System.out.println(utilDatefuture +" "+ utilDatecurrent);
//        }
      
        data.setEnd_date(Datefuture);
        data.setCompany_name(company_name);
        data.setKey(key);
        data.setProduct_name(product_name);
        licenseRepository.save(data);   
        this.getall();
    	
    	
    	
        return null;
    }
    public Addaudio1 getAudioById(Long id) {
        return audiorepository.findById(id).orElse(null);
    }
    
    public List<byte[]> getAllThumbnailImages() {
        List<Addaudio1> allAudio = audiorepository.findAll();

        return allAudio.stream()
                .map(audio -> audio.getThumbnail() != null ? audio.getThumbnail() : new byte[0])
                .collect(Collectors.toList());
    }
    
    
    
    public byte[] getThumbnailBytes(Long id) throws IOException {
        Addaudio1 audioEntity = audiorepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Audio not found"));

        // Assuming getThumbnail returns byte[]
        return audioEntity.getThumbnail();
    }
    
//    public boolean deleteAudioById(Long id) {
//        try {
//            // Check if the audio exists
//            if (audiorepository.existsById(id)) {
//                // Delete the audio by ID
//                audiorepository.deleteById(id);
//                return true;
//            } else {
//                return false; // Audio not found
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//            return false; // Delete operation failed
//        }
//    }
    
    
    public String getAudioFilename(Long id) {
        // Assuming AudioRepository has a method to get Audio by ID
        Optional<Addaudio1> audioOptional = audiorepository.findById(id);

        if (audioOptional.isPresent()) {
            Addaudio1 audio = audioOptional.get();
            return audio.getFileName(); // Assuming you have a method to get filename from the Audio entity
        } else {
            throw new AudioNotFoundException("Audio not found with ID: " + id);
        }
    }
    
    
    public boolean deleteAudioById(Long id) {
        try {
            // Check if the audio exists
            Optional<Addaudio1> optionalAudio = audiorepository.findById(id);

            if (optionalAudio.isPresent()) {
                Addaudio1 audio = optionalAudio.get();

                // Delete the audio file
                boolean audioFileDeleted = fileService.deleteAudioFile(audio.getFileName());

                // Delete the thumbnail file if applicable

                // Delete the audio record from the database
                audiorepository.deleteById(id);

                return audioFileDeleted;
            } else {
                return false; // Audio not found
            }
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            return false; // Delete operation failed
        }
    }
    
    public boolean existsById(Long audioId) {
        return audiorepository.existsById(audioId);
    }
    
    public Addaudio1 updateAudioWithFile(Long audioId, MultipartFile audioFile, MultipartFile thumbnail, Long categoryId) throws IOException {
        Optional<Addaudio1> optionalAudio = audiorepository.findById(audioId);

        if (optionalAudio.isPresent()) {
            Addaudio1 existingAudio = optionalAudio.get();

           // Update audio details if needed
            if (categoryId != null) {
                Optional<AddNewCategories> categoryOptional = addnewcategoriesrepository.findById(categoryId);
                AddNewCategories category = categoryOptional.orElseThrow(() -> new EntityNotFoundException("Category with ID " + categoryId + " not found"));
                existingAudio.setCategory(category);
            }
            // Update the audio file if a new file is provided
            if (audioFile != null && !audioFile.isEmpty()) {
                String existingFilename = existingAudio.getFileName();
                String audioFilePath = fileService.updateAudioFile(existingFilename, audioFile);
                existingAudio.setFileName(audioFilePath);
            }

            // Update the thumbnail if a new file is provided
            if (thumbnail != null && !thumbnail.isEmpty()) {
                byte[] thumbnailBytes = ImageUtils.compressImage(thumbnail.getBytes());
                existingAudio.setThumbnail(thumbnailBytes);
            }

            // Save the updated audio entity within a transaction
            Addaudio1 updatedAudio = audiorepository.save(existingAudio);

            return updatedAudio;
        } else {
            throw new EntityNotFoundException("Audio with ID " + audioId + " not found");
        }
    }

    

    
   
       
    
    

}
