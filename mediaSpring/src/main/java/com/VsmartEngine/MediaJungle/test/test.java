package com.VsmartEngine.MediaJungle.test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.compresser.ImageUtils;
import com.VsmartEngine.MediaJungle.controller.CategoryController;
import com.VsmartEngine.MediaJungle.controller.VideoCastAndCrewController;
import com.VsmartEngine.MediaJungle.fileservice.AudioFileService;
import com.VsmartEngine.MediaJungle.model.AddNewCategories;
import com.VsmartEngine.MediaJungle.model.AudioCastAndCrew;
import com.VsmartEngine.MediaJungle.model.AudioMovieNameBanner;
import com.VsmartEngine.MediaJungle.model.Audiodescription;
import com.VsmartEngine.MediaJungle.model.AudiodetailsDTO;
import com.VsmartEngine.MediaJungle.model.Audioimages;
import com.VsmartEngine.MediaJungle.model.AudiolistdetailsDTO;
import com.VsmartEngine.MediaJungle.model.CastandCrew;
import com.VsmartEngine.MediaJungle.model.CastandCrewDTO;
import com.VsmartEngine.MediaJungle.model.MovieName;
import com.VsmartEngine.MediaJungle.model.Tag;
import com.VsmartEngine.MediaJungle.repository.AddAudiodescription;
import com.VsmartEngine.MediaJungle.repository.AudioCastandCrewRepository;
import com.VsmartEngine.MediaJungle.repository.AudioCategoriesRepository;
import com.VsmartEngine.MediaJungle.repository.AudioMovieNameBannerRepository;
import com.VsmartEngine.MediaJungle.repository.AudioTagRepository;
import com.VsmartEngine.MediaJungle.repository.Audioimage;
import com.VsmartEngine.MediaJungle.repository.CastandcrewRepository;
import com.VsmartEngine.MediaJungle.repository.MovieNameRepository;
import com.VsmartEngine.MediaJungle.video.VideoImage;

import jakarta.transaction.Transactional;

@CrossOrigin()
@RestController
@RequestMapping("/api/v2/")
public class test {

	@Autowired
	private AddAudiodescription audio;

	@Autowired
	private Audioimage audioI;

	@Autowired
	private VideoCastAndCrewController castandcrew;

	@Autowired
	private CategoryController Category;

	@Autowired
	private AudioFileService fileService;

	@Autowired
	private AudioTagRepository AudioTagRepository;

	@Autowired
	private AudioCategoriesRepository AudioCategoriesRepository;

	@Autowired
	private AudioCastandCrewRepository Audiocastandcrewrepository;

	@Autowired
	private CastandcrewRepository CastandcrewRepository;
	
	@Autowired
	private MovieNameRepository MovieNameRepository;
	
	@Autowired
	private AudioMovieNameBannerRepository audiomovienamebannerrepository;
	
	private static final Logger logger = LoggerFactory.getLogger(test.class);
	
//	@PostMapping("/test")
//	public ResponseEntity<?> testaudio( @RequestParam("audio_title") String audioTitle,
//		    @RequestParam("Movie_name") String movieName,
//		    @RequestParam("Audio_Duration") String audioDuration,
//		    @RequestParam("Certificate_no") String certificateNo,
//		    @RequestParam("Certificate_name") String certificateName,
//		    @RequestParam("Rating") String rating,
//		    @RequestParam("paid") boolean isPaid,
//		    @RequestParam("production_company") String productionCompany,
//		    @RequestParam("Description") String description,
//			@RequestParam(value = "thumbnail", required = false) MultipartFile audio_thumbnail,
//			@RequestParam(value = "Bannerthumbnail", required = false) MultipartFile banner_thumbnail,
//			@RequestParam("castAndCrewIds") List<Long> castAndCrewIds, @RequestParam("category") List<Long> category,
//			@RequestParam("tag") List<Long> tag, @RequestParam("audioFile") MultipartFile audioFile) {
//		try {
//			String audioFilePath = fileService.saveAudioFile(audioFile);
//			long movieId=0L;
//			String lowercasemoviename=movieName;
//			lowercasemoviename.toLowerCase();
//			Long data_id =MovieNameRepository.findIDBy_Moviename(movieName);
//			Long lowercasemovienameId =this.GetMovenameId(lowercasemoviename);
//			if((data_id != null) ? true : false) {
//				movieId=data_id;
////				System.out.println("***************************************************Exexting data");
////				System.out.println("Exexting data"+movieId);
//			}else
//			{
//				if((lowercasemovienameId != null) ? true : false) {
////					System.out.println("***************************************************Exexting data");
////					System.out.println("Exexting datachanged"+movieId);
//					movieId=lowercasemovienameId;
//					Optional<MovieName> movienames=MovieNameRepository.findById(lowercasemovienameId);
//					MovieName savemoviename=movienames.get();
//					savemoviename.setMovie_name(movieName);
//					MovieNameRepository.save(savemoviename);		
//				}else {
////					System.out.println("***************************************************Exexting data");
////					System.out.println("New data"+movieId);
//					MovieName savemoviename= new MovieName();
//					savemoviename.setMovie_name(movieName);
//					MovieNameRepository.save(savemoviename);	
//					movieId=savemoviename.getId();
//				}
//			}
//	
//	// Check if AudioMovieNameBanner entry already exists for this movieId
//    if (audiomovienamebannerrepository.findByMovieId(movieId).isEmpty() && banner_thumbnail != null) {
//        // Only add new entry if it does not already exist
//        AudioMovieNameBanner newBanner = new AudioMovieNameBanner();
//        byte[] bannerthumbnail = ImageUtils.compressImage(banner_thumbnail.getBytes());
//        newBanner.setMovieId(movieId);
//        newBanner.setBannerImage(bannerthumbnail);
//        audiomovienamebannerrepository.save(newBanner);
//    }
//			Audiodescription audiodata = new Audiodescription();
//			audiodata.setAudio_file_name(audioFilePath);
//			audiodata.setAudio_Duration(audioDuration);
//			audiodata.setAudio_title(audioTitle);
//			audiodata.setCertificate_name(certificateName);
//			audiodata.setCertificate_no(certificateNo);
//			audiodata.setDescription(description);
//			audiodata.setMovie_name(movieId);
//			audiodata.setPaid(isPaid);
//			audiodata.setProduction_company(productionCompany);
//			audiodata.setRating(rating);
//			audiodata = audio.save(audiodata);
//			AudioCastAndCrew AudioCastAndCrew = new AudioCastAndCrew();
//			;
//			AudioCastAndCrew.setAudio_id(audiodata.getId());
//			AudioCastAndCrew.setCastandcrewlist(castAndCrewIds);
//			Audiocastandcrewrepository.save(AudioCastAndCrew);
//			Category.saveCategories(audiodata.getId(), category);
//			Category.savetags(audiodata.getId(), tag);
//			byte[] audiothumbnailBytes = ImageUtils.compressImage(audio_thumbnail.getBytes());
//			byte[] bannerthumbnailBytes = ImageUtils.compressImage(banner_thumbnail.getBytes());
//
//			Audioimages cast = new Audioimages();
//			cast.setAudioId(audiodata.getId());
//			cast.setAudio_thumbnail(audiothumbnailBytes);
//			cast.setBannerthumbnail(bannerthumbnailBytes);
//			audioI.save(cast);
////			System.out.println("Audio Title: ");
//
//			return ResponseEntity.ok().build();
//		} catch (Exception e) {
//			e.printStackTrace();
//			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid data");
//		}
//	}
 
	@Transactional
	@PostMapping("/test")
	public ResponseEntity<?> testaudio(
	        @RequestParam("audio_title") String audioTitle,
	        @RequestParam("Movie_name") String movieName,
	        @RequestParam("Audio_Duration") String audioDuration,
	        @RequestParam("Certificate_no") String certificateNo,
	        @RequestParam("Certificate_name") String certificateName,
	        @RequestParam("Rating") String rating,
	        @RequestParam("paid") boolean isPaid,
	        @RequestParam("production_company") String productionCompany,
	        @RequestParam("Description") String description,
	        @RequestParam(value = "thumbnail", required = false) MultipartFile audio_thumbnail,
	        @RequestParam(value = "Bannerthumbnail", required = false) MultipartFile banner_thumbnail,
	        @RequestParam("castAndCrewIds") List<Long> castAndCrewIds,
	        @RequestParam("category") List<Long> category,
	        @RequestParam("tag") List<Long> tag,
	        @RequestParam("audioFile") MultipartFile audioFile) {
	    try {
	        String audioFilePath = fileService.saveAudioFile(audioFile);
	        long movieId = 0L;
	        String lowercasemoviename = movieName.toLowerCase();
	        Long data_id = MovieNameRepository.findIDBy_Moviename(movieName);
	        Long lowercasemovienameId = this.GetMovenameId(lowercasemoviename);

	        if (data_id != null) {
	            movieId = data_id;
	        } else {
	            if (lowercasemovienameId != null) {
	                movieId = lowercasemovienameId;
	                Optional<MovieName> movienames = MovieNameRepository.findById(lowercasemovienameId);
	                MovieName savemoviename = movienames.get();
	                savemoviename.setMovie_name(movieName);
	                MovieNameRepository.save(savemoviename);
	            } else {
	                MovieName savemoviename = new MovieName();
	                savemoviename.setMovie_name(movieName);
	                MovieNameRepository.save(savemoviename);
	                movieId = savemoviename.getId();
	            }
	        }

//	        // Check if AudioMovieNameBanner entry already exists for this movieId
//	        if (audiomovienamebannerrepository.findByMovieId(movieId).isEmpty() && banner_thumbnail != null) {
//	            // Only add new entry if it does not already exist
//	            AudioMovieNameBanner newBanner = new AudioMovieNameBanner();
//	            byte[] bannerthumbnail = ImageUtils.compressImage(banner_thumbnail.getBytes());
//	            newBanner.setMovieId(movieId);
//	            newBanner.setBannerImage(bannerthumbnail);
//	            audiomovienamebannerrepository.save(newBanner);
//	        }
	        
	     // Check if movie ID already has a banner entry
	     			Optional<AudioMovieNameBanner> existingBanner = audiomovienamebannerrepository.findByMovieId(movieId);

	     			if (existingBanner.isPresent()) {
	     			    // Update the existing banner if the movie ID already exists and a new banner image is provided
	     			    if (banner_thumbnail != null) {
	     			        AudioMovieNameBanner banner = existingBanner.get();
	     			        byte[] bannerthumbnailBytes = ImageUtils.compressImage(banner_thumbnail.getBytes());
	     			        banner.setBannerImage(bannerthumbnailBytes);
	     			        audiomovienamebannerrepository.save(banner);
	     			    }
	     			} else if (banner_thumbnail != null) {
	     			    // Add new banner entry only if it does not already exist and a new banner image is provided
	     			    AudioMovieNameBanner newBanner = new AudioMovieNameBanner();
	     			    byte[] bannerthumbnail = ImageUtils.compressImage(banner_thumbnail.getBytes());
	     			    newBanner.setMovieId(movieId);
	     			    newBanner.setBannerImage(bannerthumbnail);
	     			    audiomovienamebannerrepository.save(newBanner);
	     			}

	        // Set audio description details
	        Audiodescription audiodata = new Audiodescription();
	        audiodata.setAudio_file_name(audioFilePath);
	        audiodata.setAudio_Duration(audioDuration);
	        audiodata.setAudio_title(audioTitle);
	        audiodata.setCertificate_name(certificateName);
	        audiodata.setCertificate_no(certificateNo);
	        audiodata.setDescription(description);
	        audiodata.setMovie_name(movieId);
	        audiodata.setPaid(isPaid);
	        audiodata.setProduction_company(productionCompany);
	        audiodata.setRating(rating);
	        audiodata = audio.save(audiodata);

	        // Save cast and crew, categories, and tags
	        AudioCastAndCrew audioCastAndCrew = new AudioCastAndCrew();
	        audioCastAndCrew.setAudio_id(audiodata.getId());
	        audioCastAndCrew.setCastandcrewlist(castAndCrewIds);
	        Audiocastandcrewrepository.save(audioCastAndCrew);
	        Category.saveCategories(audiodata.getId(), category);
	        Category.savetags(audiodata.getId(), tag);

	        byte[] audiothumbnailBytes = ImageUtils.compressImage(audio_thumbnail.getBytes());
//			byte[] bannerthumbnailBytes = ImageUtils.compressImage(banner_thumbnail.getBytes());

			Audioimages cast = new Audioimages();
			cast.setAudioId(audiodata.getId());
			cast.setAudio_thumbnail(audiothumbnailBytes);
//			cast.setBannerthumbnail(bannerthumbnailBytes);
			audioI.save(cast);
//			System.out.println("Audio Title: ");

			return ResponseEntity.ok().build();
	    } catch (Exception e) {
	        e.printStackTrace();
	        logger.error("", e);
	        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid data");
	    }
	}
	
	
	
	@GetMapping("/moviename/getbanner/{moviename}")
    public ResponseEntity<?> getBannerMovieId(@PathVariable String moviename) {
        try {
            // Step 1: Get movieId by movie name
            Long movieId = MovieNameRepository.findIDBy_Moviename(moviename);

            if (movieId == null) {
                return ResponseEntity.ok("null");
            }

            // Step 2: Check if movieId exists in AudioMovieNameBanner table
            Long existingMovieId = audiomovienamebannerrepository.findMovieIdIfExists(movieId);

            // Step 3: Return movieId if it exists, else return null
            if (existingMovieId != null) {
                return ResponseEntity.ok(existingMovieId);
            } else {
                return ResponseEntity.ok("null"); // Return null if no banner is associated
            }

        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred");
        }
    }
	
	@GetMapping("/getbannerimage/{movieId}/get")
	@Transactional
	public ResponseEntity<Map<String, byte[]>> getAudioBannermoviename(@PathVariable long movieId) {
	    try {
	        // Fetch the video image from the repository
	        Optional<AudioMovieNameBanner> audioImageOptional =audiomovienamebannerrepository.findMovieById(movieId);

	        if (audioImageOptional.isPresent()) {
	        	AudioMovieNameBanner bannerImage = audioImageOptional.get();

	            // Decompress the image bytes
	            byte[] decompressedVideoThumbnail = ImageUtils.decompressImage(bannerImage.getBannerImage());
	            // Prepare a map to hold the decompressed image data
	            Map<String, byte[]> imageMap = new HashMap<>();
	            imageMap.put("userbanneraudio", decompressedVideoThumbnail);

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
	
	@GetMapping("/getimage/banner/{Id}")
	@Transactional
	public ResponseEntity<byte[]> getbannerThumbnail(@PathVariable long Id) {
		try {
	        // Fetch the video image from the repository
	        Optional<AudioMovieNameBanner> videoImageOptional = audiomovienamebannerrepository.findMovieById(Id);

	        if (videoImageOptional.isPresent()) {
	        	AudioMovieNameBanner videoImage = videoImageOptional.get();

	            // Decompress the image bytes
	            byte[] decompressedVideoThumbnail = ImageUtils.decompressImage(videoImage.getBannerImage());

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
	

	@Transactional
	@PostMapping("/update")
	public ResponseEntity<?> audioupdate(    @RequestParam(value = "audio_id", required = false) Long audioId,
		    @RequestParam("audio_title") String audioTitle,
		    @RequestParam("Movie_name") String movieName,
		    @RequestParam("Audio_Duration") String audioDuration,
		    @RequestParam("Certificate_no") String certificateNo,
		    @RequestParam("Certificate_name") String certificateName,
		    @RequestParam("Rating") String rating,
		    @RequestParam("paid") boolean isPaid,
		    @RequestParam("production_company") String productionCompany,
		    @RequestParam("Description") String description,
			@RequestParam(value = "thumbnail", required = false) MultipartFile audio_thumbnail,
			@RequestParam(value = "Bannerthumbnail", required = false) MultipartFile banner_thumbnail,
			@RequestParam("castAndCrewIds") List<Long> castAndCrewIds, @RequestParam("category") List<Long> category,
			@RequestParam("tag") List<Long> tag, @RequestParam("audio_id") Long id,
			@RequestParam(value = "audioFile", required = false) MultipartFile audioFile) {
		try {

			Optional<Audiodescription> audioList = audio.findById(audioId);
			long movieId=0L;
			String lowercasemoviename=movieName;
			lowercasemoviename.toLowerCase();
			Long data_id =MovieNameRepository.findIDBy_Moviename(movieName);
			Long lowercasemovienameId =this.GetMovenameId(lowercasemoviename);
			if((data_id != null) ? true : false) {
				movieId=data_id;
				System.out.println("***************************************************Exexting data");
				System.out.println("Exexting data"+movieId);
			}else
			{
				if((lowercasemovienameId != null) ? true : false) {
//					System.out.println("***************************************************Exexting data");
//					System.out.println("Exexting datachanged"+movieId);
					movieId=lowercasemovienameId;
					Optional<MovieName> movienames=MovieNameRepository.findById(lowercasemovienameId);
					MovieName savemoviename=movienames.get();
					System.out.println(savemoviename);
					savemoviename.setMovie_name(movieName);
					List<MovieName> movien=MovieNameRepository.findAll();
					movien.forEach(movie -> System.out.println(movie));

					MovieNameRepository.save(savemoviename);		
				}else {
//					System.out.println("***************************************************Exexting data");
//					System.out.println("New data"+movieId);
					MovieName savemoviename= new MovieName();
					savemoviename.setMovie_name(movieName);
					MovieNameRepository.save(savemoviename);	
					movieId=savemoviename.getId();
				}
			}
			Audiodescription audiodata = audioList.get();
			audiodata.setAudio_Duration(audioDuration);
			audiodata.setAudio_title(audioTitle);
			audiodata.setCertificate_name(certificateName);
			audiodata.setCertificate_no(certificateNo);
			audiodata.setDescription(description);
			audiodata.setMovie_name(movieId);
			audiodata.setPaid(isPaid);
			audiodata.setProduction_company(productionCompany);
			audiodata.setRating(rating);
			System.out.println("audioFile!=null :" + (audioFile != null));
			if (audioFile != null) {
				String audioFilePath = fileService.saveAudioFile(audioFile);
				System.out.println("audioFilePath :" + (audioFilePath));
				audiodata.setAudio_file_name(audioFilePath);
			} else if (audioFile == null) {
				audiodata.setAudio_file_name(audiodata.getAudio_file_name());
			}

			audio.save(audiodata);

			List<Tag> audioTag = AudioTagRepository.findByAudio_Id(id);
			List<Long> audioTagIds = audioTag.stream().map(Tag::getTag_id).collect(Collectors.toList());

			List<Long> newTags = tag.stream().filter(tagId -> !audioTagIds.contains(tagId))
					.collect(Collectors.toList());
//		    	 	       missingTags.forEach(System.out::println);

			List<Long> removeTags = audioTagIds.stream().filter(tagId -> !tag.contains(tagId))
					.collect(Collectors.toList());

			if (!removeTags.isEmpty()) {
				removeTags.forEach(tagId -> {
					AudioTagRepository.deletetagBytagId(tagId, id);
				});
			}

			System.out.println("!missingTags.isEmpty() :" + !newTags.isEmpty());
			if (!newTags.isEmpty()) {
				Category.savetags(id, newTags);
			}

			List<AddNewCategories> audioCategorie = AudioCategoriesRepository.findByCategorie_Id(id);
			List<Long> CategoryIds = audioCategorie.stream().map(AddNewCategories::getCategory_id) // Assuming Tag has a
																									// method getId()
																									// returning Long
					.collect(Collectors.toList());
			List<Long> missingCategory = category.stream().filter(categoryId -> !CategoryIds.contains(categoryId))
					.collect(Collectors.toList());

			List<Long> removeCategory = CategoryIds.stream().filter(categoryId -> !category.contains(categoryId))
					.collect(Collectors.toList());
			removeTags.forEach(System.out::println);

			if (!removeCategory.isEmpty()) {
				removeCategory.forEach(tagId -> {
					AudioCategoriesRepository.deletetagBycategotiesId(tagId, id);
				});
			}

			System.out.println("!missingCategory.isEmpty() :" + !missingCategory.isEmpty());
			if (!missingCategory.isEmpty()) {

				Category.saveCategories(id, missingCategory);
			}
			Optional<AudioCastAndCrew> audioCastandCrew = Audiocastandcrewrepository.findById(id);
			AudioCastAndCrew castandcrew = audioCastandCrew.get();
			castandcrew.setCastandcrewlist(castAndCrewIds);
			Audiocastandcrewrepository.save(castandcrew);

			// Fetch the audioThumbnail and BannerThumbnail details as before
			Optional<Audioimages> audioThumbnail = audioI.findById(id);
			Audioimages audioImage = audioThumbnail.get();

			// Update audio thumbnail if provided
			if (audio_thumbnail != null) {
			    byte[] audiothumbnailBytes = ImageUtils.compressImage(audio_thumbnail.getBytes());
			    audioImage.setAudio_thumbnail(audiothumbnailBytes);
			}

			// Check if movie ID already has a banner entry
			Optional<AudioMovieNameBanner> existingBanner = audiomovienamebannerrepository.findByMovieId(movieId);

			if (existingBanner.isPresent()) {
			    // Update the existing banner if the movie ID already exists and a new banner image is provided
			    if (banner_thumbnail != null) {
			        AudioMovieNameBanner banner = existingBanner.get();
			        byte[] bannerthumbnailBytes = ImageUtils.compressImage(banner_thumbnail.getBytes());
			        banner.setBannerImage(bannerthumbnailBytes);
			        audiomovienamebannerrepository.save(banner);
			    }
			} else if (banner_thumbnail != null) {
			    // Add new banner entry only if it does not already exist and a new banner image is provided
			    AudioMovieNameBanner newBanner = new AudioMovieNameBanner();
			    byte[] bannerthumbnail = ImageUtils.compressImage(banner_thumbnail.getBytes());
			    newBanner.setMovieId(movieId);
			    newBanner.setBannerImage(bannerthumbnail);
			    audiomovienamebannerrepository.save(newBanner);
			}

			// Save audio image if either banner or audio thumbnail is provided
			if (banner_thumbnail != null || audio_thumbnail != null) {
			    audioI.save(audioImage);
			}
			return ResponseEntity.ok().build();
		} catch (Exception e) {
			e.printStackTrace();
			logger.error("", e);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid data");
		}
	}
	
	

		
	
//	@PostMapping("/update")
//	public ResponseEntity<?> audioupdate(    @RequestParam(value = "audio_id", required = false) Long audioId,
//		    @RequestParam("audio_title") String audioTitle,
//		    @RequestParam("Movie_name") String movieName,
//		    @RequestParam("Audio_Duration") String audioDuration,
//		    @RequestParam("Certificate_no") String certificateNo,
//		    @RequestParam("Certificate_name") String certificateName,
//		    @RequestParam("Rating") String rating,
//		    @RequestParam("paid") boolean isPaid,
//		    @RequestParam("production_company") String productionCompany,
//		    @RequestParam("Description") String description,
//			@RequestParam(value = "thumbnail", required = false) MultipartFile audio_thumbnail,
//			@RequestParam(value = "Bannerthumbnail", required = false) MultipartFile banner_thumbnail,
//			@RequestParam("castAndCrewIds") List<Long> castAndCrewIds, @RequestParam("category") List<Long> category,
//			@RequestParam("tag") List<Long> tag, @RequestParam("audio_id") Long id,
//			@RequestParam(value = "audioFile", required = false) MultipartFile audioFile) {
//		try {
//
//			Optional<Audiodescription> audioList = audio.findById(audioId);
//			long movieId=0L;
//			String lowercasemoviename=movieName;
//			lowercasemoviename.toLowerCase();
//			Long data_id =MovieNameRepository.findIDBy_Moviename(movieName);
//			Long lowercasemovienameId =this.GetMovenameId(lowercasemoviename);
//			if((data_id != null) ? true : false) {
//				movieId=data_id;
//				System.out.println("***************************************************Exexting data");
//				System.out.println("Exexting data"+movieId);
//			}else
//			{
//				if((lowercasemovienameId != null) ? true : false) {
////					System.out.println("***************************************************Exexting data");
////					System.out.println("Exexting datachanged"+movieId);
//					movieId=lowercasemovienameId;
//					Optional<MovieName> movienames=MovieNameRepository.findById(lowercasemovienameId);
//					MovieName savemoviename=movienames.get();
//					System.out.println(savemoviename);
//					savemoviename.setMovie_name(movieName);
//					List<MovieName> movien=MovieNameRepository.findAll();
//					movien.forEach(movie -> System.out.println(movie));
//
//					MovieNameRepository.save(savemoviename);		
//				}else {
////					System.out.println("***************************************************Exexting data");
////					System.out.println("New data"+movieId);
//					MovieName savemoviename= new MovieName();
//					savemoviename.setMovie_name(movieName);
//					MovieNameRepository.save(savemoviename);	
//					movieId=savemoviename.getId();
//				}
//			}
//			Audiodescription audiodata = audioList.get();
//			audiodata.setAudio_Duration(audioDuration);
//			audiodata.setAudio_title(audioTitle);
//			audiodata.setCertificate_name(certificateName);
//			audiodata.setCertificate_no(certificateNo);
//			audiodata.setDescription(description);
//			audiodata.setMovie_name(movieId);
//			audiodata.setPaid(isPaid);
//			audiodata.setProduction_company(productionCompany);
//			audiodata.setRating(rating);
//			System.out.println("audioFile!=null :" + (audioFile != null));
//			if (audioFile != null) {
//				String audioFilePath = fileService.saveAudioFile(audioFile);
//				System.out.println("audioFilePath :" + (audioFilePath));
//				audiodata.setAudio_file_name(audioFilePath);
//			} else if (audioFile == null) {
//				audiodata.setAudio_file_name(audiodata.getAudio_file_name());
//			}
//
//			audio.save(audiodata);
//
//			List<Tag> audioTag = AudioTagRepository.findByAudio_Id(id);
//			List<Long> audioTagIds = audioTag.stream().map(Tag::getTag_id).collect(Collectors.toList());
//
//			List<Long> newTags = tag.stream().filter(tagId -> !audioTagIds.contains(tagId))
//					.collect(Collectors.toList());
////		    	 	       missingTags.forEach(System.out::println);
//
//			List<Long> removeTags = audioTagIds.stream().filter(tagId -> !tag.contains(tagId))
//					.collect(Collectors.toList());
//
//			if (!removeTags.isEmpty()) {
//				removeTags.forEach(tagId -> {
//					AudioTagRepository.deletetagBytagId(tagId, id);
//				});
//			}
//
//			System.out.println("!missingTags.isEmpty() :" + !newTags.isEmpty());
//			if (!newTags.isEmpty()) {
//				Category.savetags(id, newTags);
//			}
//
//			List<AddNewCategories> audioCategorie = AudioCategoriesRepository.findByCategorie_Id(id);
//			List<Long> CategoryIds = audioCategorie.stream().map(AddNewCategories::getCategory_id) // Assuming Tag has a
//																									// method getId()
//																									// returning Long
//					.collect(Collectors.toList());
//			List<Long> missingCategory = category.stream().filter(categoryId -> !CategoryIds.contains(categoryId))
//					.collect(Collectors.toList());
//
//			List<Long> removeCategory = CategoryIds.stream().filter(categoryId -> !category.contains(categoryId))
//					.collect(Collectors.toList());
//			removeTags.forEach(System.out::println);
//
//			if (!removeCategory.isEmpty()) {
//				removeCategory.forEach(tagId -> {
//					AudioCategoriesRepository.deletetagBycategotiesId(tagId, id);
//				});
//			}
//
//			System.out.println("!missingCategory.isEmpty() :" + !missingCategory.isEmpty());
//			if (!missingCategory.isEmpty()) {
//
//				Category.saveCategories(id, missingCategory);
//			}
//			Optional<AudioCastAndCrew> audioCastandCrew = Audiocastandcrewrepository.findById(id);
//			AudioCastAndCrew castandcrew = audioCastandCrew.get();
//			castandcrew.setCastandcrewlist(castAndCrewIds);
//			Audiocastandcrewrepository.save(castandcrew);
//
//			Optional<Audioimages> audioThumbnail = audioI.findById(id);
//
//			Audioimages audioImage = audioThumbnail.get();
//			System.out.println("audio_thumbnail != null :" + (audio_thumbnail != null));
//
//			if (audio_thumbnail != null) {
//				byte[] audiothumbnailBytes = ImageUtils.compressImage(audio_thumbnail.getBytes());
//				audioImage.setAudio_thumbnail(audiothumbnailBytes);
//			}
//			System.out.println("banner_thumbnail != null :" + (banner_thumbnail != null));
//			if (banner_thumbnail != null) {
//				byte[] bannerthumbnailBytes = ImageUtils.compressImage(banner_thumbnail.getBytes());
//				audioImage.setBannerthumbnail(bannerthumbnailBytes);
//			}
//			System.out.println("banner_thumbnail != null || audio_thumbnail != nul :"
//					+ (banner_thumbnail != null || audio_thumbnail != null));
//			if (banner_thumbnail != null || audio_thumbnail != null) {
//				audioI.save(audioImage);
//			}
//			return ResponseEntity.ok().build();
//		} catch (Exception e) {
//			e.printStackTrace();
//			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid data");
//		}
//	}
	
	
	@GetMapping("/getaudio/{id}")
	public ResponseEntity<AudiolistdetailsDTO> Audiolistdetails(@PathVariable("id") long id) {

		Optional<Audiodescription> audioList = audio.findById(id);
		List<Tag> audioTag = AudioTagRepository.findByAudio_Id(id);
		List<AddNewCategories> audioCategorie = AudioCategoriesRepository.findByCategorie_Id(id);
		Optional<AudioCastAndCrew> audioCastandCrew = Audiocastandcrewrepository.findById(id);
		List<CastandCrewDTO> castAndCrewDTOList = new ArrayList<>();
		AudioCastAndCrew castandcrew = audioCastandCrew.get();
		List<Long> castAndCrewIds = castandcrew.getCastandcrewlist();
		for (Long ids : castAndCrewIds) {
			Optional<CastandCrew> castAndCrewOptional = CastandcrewRepository.findById(ids);
			if (castAndCrewOptional.isPresent()) {
				CastandCrew castAndCrew = castAndCrewOptional.get();
				// Create a DTO or simply use an object to hold the ID and Name
				CastandCrewDTO dto = new CastandCrewDTO(castAndCrew.getId(), castAndCrew.getName());
				castAndCrewDTOList.add(dto);
			} else {
				// Handle the case where the ID does not exist in the repository
				System.out.println("No CastandCrew found with ID: " + id);
			}

		}
		castAndCrewDTOList.forEach(System.out::println);
		AudiolistdetailsDTO dto = new AudiolistdetailsDTO();
		if (audioList.isPresent()) {
			Audiodescription audio = audioList.get();
			dto.setId(audio.getId());
			dto.setAudioTitle(audio.getAudio_title());
			
			Optional<MovieName> data =MovieNameRepository.findById(audio.getMovie_name());
			MovieName moviename=data.get();
			dto.setMovie_name(moviename.getMovie_name());
			dto.setRating(audio.getRating());
			dto.setDescription(audio.getDescription());
			dto.setProduction_company(audio.getProduction_company());
			dto.setPaid(audio.getPaid());
			dto.setAudio_file_name(audio.getAudio_file_name());
			dto.setCertificate_name(audio.getCertificate_name());
			dto.setAudio_Duration(audio.getAudio_Duration());
			dto.setCertificate_no(audio.getCertificate_no());
			dto.setTag(audioTag);
			dto.setCategory(audioCategorie);
			dto.setCastandCrew(castAndCrewDTOList);
		} else {
			return ResponseEntity.notFound().build();
		}
		audioTag.forEach(System.out::println);
		return ResponseEntity.ok(dto);
	}

	@GetMapping("/getaudiodetailsdto")
	public ResponseEntity<List<AudiodetailsDTO>> getAudio() {
		List<Audiodescription> audioList = audio.findAll();
		List<AudiodetailsDTO> dtoList = audioList.stream().map(a -> {
			List<AddNewCategories> audioCategorie = AudioCategoriesRepository.findByCategorie_Id(a.getId());
			audioCategorie.forEach(System.out::println);
			String firstCategoryName = audioCategorie.isEmpty() ? "No Category" : audioCategorie.get(0).getCategories();
			return new AudiodetailsDTO(a.getId(), a.getAudio_title(), a.getPaid(), a.getProduction_company(),
					a.getRating(), firstCategoryName);
		}).collect(Collectors.toList());
		dtoList.forEach(System.out::println);
		return ResponseEntity.ok(dtoList);
	}

//	@DeleteMapping("/testaudio/{id}")
//	public ResponseEntity<String> deleteAudio(@PathVariable Long id) {
//		try {
//
//			AudioTagRepository.deletetagByAudioId(id);
//			AudioCategoriesRepository.deletecategoriesByAudioId(id);
//			Audiocastandcrewrepository.deleteById(id);
//			audioI.deleteById(id);
//			audio.deleteById(id);
//
//			if (true) {
//				return new ResponseEntity<>("Audio with ID " + id + " deleted successfully.", HttpStatus.OK);
//			} else {
//				return new ResponseEntity<>("Audio not found with ID: " + id, HttpStatus.NOT_FOUND);
//			}
//		} catch (Exception e) {
//			return new ResponseEntity<>("An error occurred while deleting audio with ID: " + id,
//					HttpStatus.INTERNAL_SERVER_ERROR);
//		}
//	}

//	@PostMapping("/afliater")
//	public ResponseEntity<Map<String, Object>> getAfliater(@RequestBody testModel data) {
//		testModel savedData = testRepo.save(data);
//		System.out.println(data);
//		System.out.println(savedData.getId());
//		String UseremailID = savedData.getEmailId();
//		long id = savedData.getId();
//
//		// Random generation logic
//		String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
//		Random random = new Random();
//		StringBuilder sb = new StringBuilder();
//		StringBuilder sb1 = new StringBuilder();
//		StringBuilder sb2 = new StringBuilder();
//
//		for (int i = 0; i < 4; i++) {
//			sb.append(characters.charAt(random.nextInt(characters.length())));
//			sb1.append(characters.charAt(random.nextInt(characters.length())));
//			sb2.append(characters.charAt(random.nextInt(characters.length())));
//		}
//
//		String randomAlphanumeric = sb.toString();
//		String randomAlphanumeric10 = sb1.toString();
//		String randomAlphanumeric20 = sb2.toString();
//
//		String idStr = String.format("%02d", id % 100);
//		String combinedtoken = randomAlphanumeric + idStr;
//		String combinedtoken10 = randomAlphanumeric10 + "10";
//		String combinedtoken20 = randomAlphanumeric20 + "20";
//
//		Optional<testModel> editdata = testRepo.findById(id);
//		if (editdata.isPresent()) {
//			testModel testdata = editdata.get();
//			testdata.setCoupon10(combinedtoken10);
//			testdata.setCoupon20(combinedtoken20);
//			testdata.setReferalid(combinedtoken);
//			testRepo.save(testdata);
//		}
//
//		// Send email asynchronously
//		this.mail(UseremailID, combinedtoken, combinedtoken10, combinedtoken20);
//
//		// Prepare response
//		Map<String, Object> response = new HashMap<>();
//		response.put("message", "Data saved successfully");
//		return ResponseEntity.ok(response);
//	}

//	@Async
//	public void mail(String UseremailID, String combinedtoken, String combinedtoken10, String combinedtoken20) {
//		SimpleMailMessage message = new SimpleMailMessage();
//
//		String htmlContent = generateHtmlContent(combinedtoken, combinedtoken10, combinedtoken20);
//		MimeMessage mimeMessage = sender.createMimeMessage();
////	        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true);
////		 
////		message.setTo(UseremailID);
////		message.setText("token \t" + combinedtoken + "\n" + "10 % coupon \t" + combinedtoken10 + "\n" + "20 % coupon \t"
////				+ combinedtoken20);
////		message.setSubject("Learnhub");
////		sender.send(message);
////		 MimeMessage mimeMessage = sender.createMimeMessage();
//		try {
//			// Create a MIME message
//
//			MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true);
//
//			// Set email details
//			helper.setTo(UseremailID);
//			helper.setSubject("Learnhub");
//			helper.setText(htmlContent, true); // true for HTML
//
//			// Send the email
//			sender.send(mimeMessage);
//		} catch (MessagingException e) {
//			// Handle the exception
//			e.printStackTrace();
//			// You can log the error or rethrow it as a runtime exception, depending on your
//			// needs
//			throw new RuntimeException("Failed to send email", e);
//		}
//
//	}
	
	@GetMapping("/getaudiocat")
	public ResponseEntity<List<Audiodescription>> AudiolistdetailsBycategoryids() {
		long id=1l;
		 List<Audiodescription> audiocat= AudioCategoriesRepository.findaudiobyCategorie_Id(id);
				
		 return ResponseEntity.ok(audiocat);
	}
	
	@GetMapping("/movename/{moviename}")
	public ResponseEntity<?> testmovename(@PathVariable("moviename")String movie) {

		String movieName=movie;
		long a=0L;
		Long id =MovieNameRepository.findIDBy_Moviename(movieName);
		a = (id != null) ? id : 0L;
		if((id != null) ? true : false) {
			a=id;
		}else
		{
			MovieName savemoviename= new MovieName();
			savemoviename.setMovie_name(movieName);
			MovieNameRepository.save(savemoviename);	
			a=savemoviename.getId();
		}
		
		
		 return ResponseEntity.ok(a);
	}
	
	@GetMapping("/movename")
	public ResponseEntity<?> GetMovename() {

		
		List<MovieName> movienames=MovieNameRepository.findAll();
		
		movienames.forEach(movie -> System.out.println(movie));
		
		 return ResponseEntity.ok(movienames);
	}
	
	@GetMapping("/movenam")
	public ResponseEntity<?> GetMovenamelist() {

		String movien ="master";
		List<MovieName> movienames=MovieNameRepository.findAll();
//		movienames.forEach(movie -> movie.setMovie_name(movie.getMovie_name().toLowerCase()));
//		movienames.forEach(movie -> System.out.println(movie));
//		List<String> movieNamesList = movienames.stream()
//		        .map(MovieName::getMovie_name)  // Assuming MovieName has a getMovieName() method
//		        .collect(Collectors.toList());
		Optional<MovieName> movieOptional = movienames.stream()
		        .filter(movie -> movie.getMovie_name().equalsIgnoreCase(movien))
		        .findFirst();
		 MovieName movie = movieOptional.get();
//		 movienames
		
		 return ResponseEntity.ok(movienames);
	}
	
	public Long GetMovenameId(String MovieName) {

		Long id=null;
		String movien =MovieName;
		List<MovieName> movienames=MovieNameRepository.findAll();
//		movienames.forEach(movie -> movie.setMovie_name(movie.getMovie_name().toLowerCase()));
//		 System.out.println("***************GetMovenameId*******************");
//		movienames.forEach(movie -> System.out.println(movie));
//		List<String> movieNamesList = movienames.stream()
//		        .map(MovieName::getMovie_name)  // Assuming MovieName has a getMovieName() method
//		        .collect(Collectors.toList());
		Optional<MovieName> movieOptional = movienames.stream()
		        .filter(movie -> movie.getMovie_name().equalsIgnoreCase(movien))
		        .findFirst();
		 
		 if (movieOptional.isPresent()) {
			    MovieName movie = movieOptional.get();
			    id=movie.getId();
			} else {
				id=null;
			}
		
		 return id;
	}
	
	
	
}
