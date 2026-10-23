package com.VsmartEngine.MediaJungle.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.VsmartEngine.MediaJungle.LogManagement;
import com.VsmartEngine.MediaJungle.model.FileModel;

@Service
public class FileServiceImplementation implements FileService {
	
	
	 @Value("${project.video}")
	    private String audioUploadDirectory;
	 
	 @Value("${project.videotrailer}")
	 private String videotraileruploadDirectory;
	 private static final Logger logger = LoggerFactory.getLogger(AudioService.class);
//	@Override
//	public FileModel uploadVideo(String path, MultipartFile file) throws IOException {
//		FileModel fileModel = new FileModel();
//		//Fetch file original name .
//		String fileName = file.getOriginalFilename();
//		//try to generate random file name .
//		String randomId = UUID.randomUUID().toString();
//		String finalName = randomId.concat(fileName.substring(fileName.indexOf(".")));
//		
//		//File full path .
//		String filePath = path + File.separator + finalName ;
//		
//		//Create folder to store file .you can create any where you want .
//		File f = new File(path);
//		if(!f.exists()) {
//			f.mkdir();
//		}
//
//		Files.copy(file.getInputStream(),Paths.get(filePath));
//	
//		fileModel.setVideoFileName(finalName);
//		
//		return fileModel;
//	}
//	
//	@Override
//	public FileModel uploadTrailerVideo(String path, MultipartFile file) throws IOException {
//		
//		FileModel fileModel = new FileModel();
//		//Fetch file original name .
//		String fileName = file.getOriginalFilename();
//		//try to generate random file name .
//		String randomId = UUID.randomUUID().toString();
//		String finalName = randomId.concat(fileName.substring(fileName.indexOf(".")));
//		
//		//File full path .
//		String filePath = path + File.separator + finalName ;
//		
//		//Create folder to store file .you can create any where you want .
//		File f = new File(path);
//		if(!f.exists()) {
//			f.mkdir();
//		}
//
//		Files.copy(file.getInputStream(),Paths.get(filePath));
//	
//		fileModel.setVideotrailerfilename(fileName);
//		
//		return fileModel;	
//	}
//	
//	@Override
//	public InputStream getVideoFIle(String path, String fileName, long id) throws  FileNotFoundException {
//		String fullPath = path+File.separator+fileName ;
//		InputStream inputStream = new FileInputStream(fullPath);
//		return inputStream ;
//	}
//	
//	public InputStream getVideotrailerFIle(String path, String trailerfileName, long id) throws  FileNotFoundException {
//		String fullPath = path+File.separator+trailerfileName ;
//		InputStream inputStream = new FileInputStream(fullPath);
//		return inputStream ;
//	}
//	
//	
//	
//	public boolean deleteAudioFile(String fileName) {
//    	Path filePath = Paths.get(audioUploadDirectory,fileName);
//    	
//        System.out.println("Deleting file: " + filePath.toString());
//        System.out.println("Absolute Path: " + filePath.toAbsolutePath().toString());
//        try {
//            boolean deleted = Files.deleteIfExists(filePath);
//
//            if (deleted) {
//                System.out.println("File deleted successfully");
//            } else {
//                System.out.println("File does not exist or deletion failed");
//            }
//
//            return deleted; // Return the result to the caller
//        } catch (IOException e) {
//            e.printStackTrace();
//            System.out.println("Error occurred while deleting the file");
//            return false; // Return false in case of an exception
//        }
//    }
//	
	
	    @Override
	    public FileModel uploadVideo(String path, MultipartFile file) throws IOException {
	        return uploadFile(path, file, true);
	    }

	    @Override
	    public FileModel uploadTrailerVideo(String path, MultipartFile file) throws IOException {
	        return uploadFile(path, file, false);
	    }

	    private FileModel uploadFile(String path, MultipartFile file, boolean isVideo) throws IOException {
	        FileModel fileModel = new FileModel();
	        String fileName = file.getOriginalFilename();
	        String randomId = UUID.randomUUID().toString();
	        String finalName = randomId.concat(fileName.substring(fileName.indexOf(".")));

	        String filePath = path + File.separator + finalName;

	        File f = new File(path);
	        if (!f.exists()) {
	            f.mkdir();
	        }

	        Files.copy(file.getInputStream(), Paths.get(filePath));

	        if (isVideo) {
	            fileModel.setVideoFileName(finalName);
	        } else {
	            fileModel.setVideotrailerfilename(finalName);
	        }

	        return fileModel;
	    }

		@Override
		public InputStream getVideoFIle(String path, String fileName, long id) throws  FileNotFoundException {
			String fullPath = path+File.separator+fileName ;
			InputStream inputStream = new FileInputStream(fullPath);
			return inputStream ;
		}
		
//		@Override
//		public InputStream getVideotrailerFIle(String path, String trailerfileName, long id) throws  FileNotFoundException {
//			String fullPath = path+File.separator+trailerfileName ;
//			InputStream inputStream = new FileInputStream(fullPath);
//			return inputStream ;
//		}
		
		@Override
		public InputStream getVideotrailerFIle(String path, String trailerfileName, long id) throws FileNotFoundException {
		    Path fullPath = Paths.get(path, trailerfileName);
		    return new FileInputStream(fullPath.toFile());
		}
		
		@Override
		public boolean deleteVideoFile(String fileName) throws IOException{
	    	Path filePath = Paths.get(audioUploadDirectory,fileName);
	    	
	        System.out.println("Deleting file: " + filePath.toString());
	        System.out.println("Absolute Path: " + filePath.toAbsolutePath().toString());
	        try {
	            boolean deleted = Files.deleteIfExists(filePath);

	            if (deleted) {
	                System.out.println("File deleted successfully");
	            } else {
	                System.out.println("File does not exist or deletion failed");
	            }

	            return deleted; // Return the result to the caller
	        } catch (IOException e) {
	            e.printStackTrace();
	            logger.error("", e);
	            System.out.println("Error occurred while deleting the file");
	            return false; // Return false in case of an exception
	        }
	    }
		
		@Override
		public boolean deletetrailerFile(String fileName) throws IOException{
	    	Path filePath = Paths.get(videotraileruploadDirectory,fileName);
	    	
	        System.out.println("Deleting file: " + filePath.toString());
	        System.out.println("Absolute Path: " + filePath.toAbsolutePath().toString());
	        try {
	            boolean deleted = Files.deleteIfExists(filePath);

	            if (deleted) {
	                System.out.println("File deleted successfully");
	            } else {
	                System.out.println("File does not exist or deletion failed");
	            }

	            return deleted; // Return the result to the caller
	        } catch (IOException e) {
	            e.printStackTrace();
	            logger.error("", e);
	            System.out.println("Error occurred while deleting the file");
	            return false; // Return false in case of an exception
	        }
	    }
		
		
		
		
}
