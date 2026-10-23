package com.VsmartEngine.MediaJungle.controller;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import com.VsmartEngine.MediaJungle.Container.VideoContainerController;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.model.License;
import com.VsmartEngine.MediaJungle.repository.AddUserRepository;
import com.VsmartEngine.MediaJungle.repository.licenseRepository;
import com.VsmartEngine.MediaJungle.video.AddVideoDescriptionRepository;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;





@Controller
public class LicenseController {
	
	
	 @Autowired
	    private licenseRepository licenseRepository;
	 
		@Autowired
		private AddUserRepository adduserrepository;
		
		@Autowired
		private AddVideoDescriptionRepository videodescription;
	 
	 @Value("${upload.licence.directory}")
		private String LicenceDirectory;
	
	
	 private static final Logger logger = LoggerFactory.getLogger(LicenseController.class);


	 
	 private String valu;
	 private String valu1;
	 private String file;
	


		public ResponseEntity<UserWithStatus> getAllUser() {
		    List<AddUser> getUser = adduserrepository.findAll();
		    Iterable<License> licenseIterable = licenseRepository.findAll();
	    	List<License> licenseList = StreamSupport.stream(licenseIterable.spliterator(), false)
	    	                                         .collect(Collectors.toList());
	    	
	    	
	    	  boolean isEmpty = licenseList.isEmpty();
			    boolean valid = !(licenseList.isEmpty())?this.getall():false;
	    	  
	    	boolean type=true;
//	    	System.out.println("licenseList.get(0).getType()"+(licenseList.get(0).getType().equals("Demo")));
	    			if (!(licenseList.isEmpty())) {	
	    				if(licenseList.get(0).getType().equals("Demo")) {
	    				type=false;
	    				System.out.println("licenseList.get(0).getType()"+licenseList.get(0).getType());
	    				}
	    			}	
	    			List<Map<String, Object>> dataList = new ArrayList<>();
    		        Map<String, Object> data1 = new HashMap<>();
	    			 DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
	    			 try {
	    			DocumentBuilder builder = factory.newDocumentBuilder();
	    			InputStream inputStream = getClass().getClassLoader().getResourceAsStream("product_info.xml");
					 Document document = builder.parse(inputStream);
					 Element rootElement=document.getDocumentElement();
					 NodeList personList = rootElement.getElementsByTagName("data");
					 Element person4 = (Element) personList.item(0);
					  Element contact = (Element) person4.getElementsByTagName("contact").item(0);
		              Element email = (Element) person4.getElementsByTagName("email").item(0);
		              Element ver = (Element) person4.getElementsByTagName("version").item(0);
		              String Contact = contact.getTextContent();
		              String Email = email.getTextContent();
		              String version = ver.getTextContent();
		              String ProductName="";
		              String CompanyName="";
		              String Type="";
		              String StartDate="";
		              String EndDate="";
		              SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		              
		              for (License license : licenseList) {
		  				
		            	  ProductName=license.getProduct_name();
		            	  CompanyName=license.getCompany_name();
//		            	  
		            	  Type=license.getType();
		            	  StartDate=dateFormat.format(license.getStart_date());
		            	  EndDate=dateFormat.format(license.getEnd_date());
		  			}
//		              if(StartDate.equals(EndDate)) {
//		            	  StartDate="";
//		            	  EndDate="";
//		              }
		              
		              data1.put("Contact",Contact);
	    		        data1.put("Email", Email);
	    		        data1.put("ProductName",ProductName);
	    		        data1.put("CompanyName", CompanyName);
	    		        data1.put("version",version);
	    		        data1.put("Type", Type);
	    		        data1.put("StartDate",StartDate);
	    		        data1.put("EndDate", EndDate);

	    		       
	    		        dataList.add(data1);
	    			 }
	    			 catch(Exception e) {
		                 e.printStackTrace();
		                 logger.error("", e);
		             }
	    			
	    		       
//	    		        // Print the list
//	    		        for (Map<String, Object> data : dataList) {
//	    		            System.out.println(data);
//	    		        }
	    	
		  
		    
		   
//		    logger.info(" total no of course  ======="+count.toString());
		    UserWithStatus userListWithStatus = new UserWithStatus(getUser, isEmpty, valid,type, dataList);
		   
		    return new ResponseEntity<>(userListWithStatus,HttpStatus.OK);
		}
		
		

		public ResponseEntity<Integer> count() {
			
			Iterable<License> licenseIterable = licenseRepository.findAll();
	    	List<License> licenseList = StreamSupport.stream(licenseIterable.spliterator(), false)
	    	                                         .collect(Collectors.toList());
	    	
			Long count = videodescription.count();
			String courseString=" ";
//			System.out.println("out side for"+courseString==null);
			for (License license : licenseList) {
				
				courseString=license.getCourse();
			}
			Long course=0l;
			System.out.println(courseString.isEmpty());
			if(!(courseString.isEmpty())) {
				course = Long.parseLong(courseString);
				logger.info(course.toString());
				
			}
			
			if(count<course) {
				logger.info("-------------------------------------------------------");
				logger.info("ADD course");
				logger.info("-------------------------------------------------------");
		    return new ResponseEntity<>(200, HttpStatus.OK);
			}
			
//			else if(!(licenseList.isEmpty())&&courseString.isEmpty()) {
//				logger.info("-------------------------------------------------------");
//				logger.info("unlimited course");
//				logger.info("-------------------------------------------------------");
//			    return new ResponseEntity<>(200, HttpStatus.OK);
//			}
			else
			{
				logger.info("-------------------------------------------------------");
				logger.info("limited reached");
				 return new ResponseEntity<>(401, HttpStatus.BAD_REQUEST);
			}
				
		}
		
		 public boolean getall(){
		    	
		    	Iterable<License> licenseIterable = licenseRepository.findAll();
		    	List<License> licenseList = StreamSupport.stream(licenseIterable.spliterator(), false)
		    	                                         .collect(Collectors.toList());
		    	LocalDate currentDate = LocalDate.now();
	            java.util.Date Datecurrent = java.sql.Date.valueOf(currentDate);
	            long milliseconds = Datecurrent.getTime(); // Get the time in milliseconds
	            java.sql.Timestamp timestamp = new java.sql.Timestamp(milliseconds);
	           String val="";
	            String localFile="";
		    	for (License license : licenseList) {
		    		localFile=license.getFilename();
		    		 System.out.println("---------------------------------------------------");
		    	    System.out.println("ID: " + license.getId());
		    	    System.out.println("Company Name: " + license.getCompany_name());
		    	    System.out.println("Product Name: " + license.getProduct_name());
		    	    System.out.println("key " + license.getKey());
		    	    System.out.println("start_date: " + license.getStart_date());
		    	    System.out.println("end_date: " + license.getEnd_date());
//		            java.util.Date licenseStartDateUtil = java.sql.Date.valueOf(license.getStart_date().toLocaleString());
		    	    System.out.println(" start date :"+license.getStart_date()+" present date :"+Datecurrent+" is equal"+license.getEnd_date().equals(timestamp));
		    	    // Print other fields as needed
		    	}
		    	
		    	 DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
				  try {
						 DocumentBuilder builder = factory.newDocumentBuilder();
							 Document document = builder.parse(new File(LicenceDirectory+localFile));
							 Element rootElement=document.getDocumentElement();
							 NodeList personList = rootElement.getElementsByTagName("data");
//							File file = new File("Audio/"+localFile);
//							 SimpleDateFormat formatter = new SimpleDateFormat("ddMMyyyy");
							 Element person4 = (Element) personList.item(0);
							  Element trai = (Element) person4.getElementsByTagName("Video").item(0);
				              Element stud = (Element) person4.getElementsByTagName("type").item(0);
				              Element vale = (Element) person4.getElementsByTagName("validity").item(0);
				              String tra = trai.getTextContent();
				              String stude = stud.getTextContent();
				              val = vale.getTextContent();
				              System.out.println("No of trainer"+tra);
				              System.out.println("No of student"+stude);
				              System.out.println("No of student"+val.isEmpty());
					         String formattedDate =tra+stude+val;
					         System.out.println("Last modified date complete"+formattedDate);
				             System.out.println("----------------------------------------------------------------");
				             System.out.println(Jwts.builder()
				             .setSubject(formattedDate)
					            .signWith(SignatureAlgorithm.HS256, "yourSecretKeyStringWithAtLeast256BitsLength")
					            .compact());
//				             DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
//				             DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
//				             Document doc = dBuilder.parse(file);
//				             Element root = doc.getDocumentElement();
//				             Element validity2 = doc.createElement("key");
				             this.valu=(Jwts.builder()
				 	                .setSubject(formattedDate)
				 		            .signWith(SignatureAlgorithm.HS256, "yourSecretKeyStringWithAtLeast256BitsLength")
				 		            .compact());
				             		
//				             NodeList dataList = root.getElementsByTagName("data");
//				             Element data = (Element) dataList.item(0);
//				             Element type2 = (Element) data.getElementsByTagName("version").item(0);
//				            
//				             Element person1 = (Element) personList.item(0);
//				             Element key_name1 = (Element) person1.getElementsByTagName("key").item(0);
//				             
//				             if(key_name1== null) {
//				             data.insertBefore(validity2, type2.getNextSibling());
//				             doc.normalize();
//				             FileOutputStream fileOutputStream = new FileOutputStream(file);
//				             try {
//				             javax.xml.transform.TransformerFactory.newInstance().newTransformer().transform(
//				                     new javax.xml.transform.dom.DOMSource(doc),
//				                     new javax.xml.transform.stream.StreamResult(fileOutputStream));
//				             fileOutputStream.close();
//
//				             logger.info("XML file updated successfully!");
//
				             }
				             catch (Exception e) {
				                 e.printStackTrace();
				                 this.valu="123344";
				                 logger.error("", e);
				             }
		    	
		    	
		  
		    	 boolean valid = false; // Initialize valid to false
//		    	 boolean same = this.areJwtsEqual();
		    	 
		    	 System.out.println("out of the loop"+valid);
		    	    for (License license : licenseList) {
		    	    	this.valu1=license.getKey();
				 
//		    	        if (license.getEnd_date().equals(timestamp)) {
//		    -------------------------------------testarea-----------------------------
		    	        	  if ((valu.equals(valu1)) && !(license.getEnd_date().equals(timestamp)) && !(val.isEmpty())) {  
		    	        		 
		    	        	
		    	            valid =  true;
		    	            logger.info("License is Valid"+valid);
////		    	            System.out.println("inside of the loop IF of same!!!*!*!*!*!*!*!*!"+same);
//		    	            System.out.println("generated valueeee======"+this.valu);
//		    	            System.out.println("license  valueeee======"+this.valu1);
//		    	            System.out.println("license"+license.getEnd_date()+"       "+timestamp+"          "+ !(license.getEnd_date().equals(timestamp)));
		    	            break; 
		    	        }
//		    	        	else if((val.isEmpty()) && (valu.equals(valu1))) {
//			    	        		valid=true;
//				    	        	logger.info("License is valid");
//				    	        	logger.info("License validy is unlimited");
//				    	        	
//			    	        	
//			    	        	}
		    	        else
		    	        {
		    	        	logger.info("License is InValid");
		    	        	if(!(valu.equals(valu1)))
		    	        			{
		    	        	valid=false;
		    	        	logger.info("License is Modified");
		    	        			}
		    	        	else if(license.getEnd_date().equals(timestamp)) {
		    	        		valid=false;
			    	        	logger.info("License is Expired");
		    	        	
		    	        	}
		    	        }
		    	    }

//		    	  List<Addaudio1> allAudio = audiorepository.findAll();
		    	 
		    	return valid;
		    }
		 
//		 public boolean areJwtsEqual() {
//		        // Decode and parse the payloads of both JWTs
//		        Claims claims1 = Jwts.parser().parseClaimsJwt("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyOTA0MjAyNDBmcmVlIn0.FTsji32AaS0P-5B2BI3LyN5XJK_J1Z8pI8hcW4Vo_9U").getBody();
//		        Claims claims2 = Jwts.parser().parseClaimsJwt("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyOTA0MjAyNDBmcmVlIn0.FTsji32AaS0P-5B2BI3LyN5XJK_J1Z8pI8hcW4Vo_9U").getBody();
//
//		        // Compare the decoded payloads
//		        return claims1.equals(claims2);
//		    }
//		 
//			-------------------------------------------licensefile--------------------------------------------
			// @PostMapping("/uploadfile")
		 //    public ResponseEntity<License> upload(@RequestParam("audioFile") MultipartFile File,@RequestParam("lastModifiedDate") String lastModifiedDate)
		 //      {
		 //        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
				
		 //        try {
		 //            // Save audio with file using the service 
		 //        	License savedAudio = this.saveFile(File);
		 //            DocumentBuilder builder = factory.newDocumentBuilder();
		    		
		    		
			// 		Document document = builder.parse(new File("Audio/"+file));
					
			// 		Element rootElement=document.getDocumentElement();
			// 		System.out.println("Root Element ="+rootElement.getNodeName());
			// 		 NodeList personList = rootElement.getElementsByTagName("data");
			//             for (int i = 0; i < personList.getLength(); i++) {
			//                 Element person = (Element) personList.item(i);
			//                 // Get the <name> element inside each <person> element
			//                 Element product = (Element) person.getElementsByTagName("product_name").item(0);
			//                 Element company = (Element) person.getElementsByTagName("company_name").item(0);
			//                 Element version_name = (Element) person.getElementsByTagName("version").item(0);
			//                 Element key_name = (Element) person.getElementsByTagName("key").item(0);
			//                 Element type_name = (Element) person.getElementsByTagName("type").item(0);
			//                 Element courses = (Element) person.getElementsByTagName("Video").item(0);
			//                 Element validity_date = (Element) person.getElementsByTagName("validity").item(0);
			//                 // Get the text content of the <name> element
			//                 String product_name = product.getTextContent();
			//                 String company_name = company.getTextContent();
			//                 String version = version_name.getTextContent();
			//                 String key = key_name.getTextContent();
			//                 String type = type_name.getTextContent();
			//                 String course = courses.getTextContent();
			//                 String validity = validity_date.getTextContent();
			//                 this.licensedetails(product_name, company_name, key, validity,course,type,file);
			//                 System.out.println("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
			//                 System.out.println("product_name:" + product_name+" company_name: "+company_name+" version: "+version+" key: "+key+" type: "+type+" validity: "+validity+"Video"+course+"lastModifiedDate"+lastModifiedDate);
			//                 System.out.println("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
			                
			//             }
	
		               
			            
		 //            return ResponseEntity.ok().body(savedAudio);
		 //        } catch (ParserConfigurationException |SAXException|IOException  e) {
		 //            e.printStackTrace();
		 //            return ResponseEntity.badRequest().build();
		 //        }
		 //    }

		    public ResponseEntity<License> upload(@RequestParam("audioFile") MultipartFile File, @RequestParam("lastModifiedDate") String lastModifiedDate) {
		        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		        
		        try {
		            // Save audio with file using the service 
		            License savedAudio = this.saveFile(File);
		            DocumentBuilder builder = factory.newDocumentBuilder();
		            
		            // Define the date-time formatter for the custom format
//		            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("M/d/yyyy, h:mm:ss a");

		            // Parse the string to a LocalDateTime
//		            LocalDateTime localDateTime;
//		           
//		                localDateTime = LocalDateTime.parse(lastModifiedDate, formatter);

		            // Convert LocalDateTime to Instant
//		            Instant instant = localDateTime.atZone(ZoneId.systemDefault()).toInstant();

		            // Create a FileTime from the Instant
//		            FileTime newModifiedTime = FileTime.from(instant);

//		            Path filePath = Paths.get("Audio/" + File.getOriginalFilename());
//		            Files.setLastModifiedTime(filePath, newModifiedTime);

		            Document document = builder.parse(new File(LicenceDirectory+ File.getOriginalFilename()));
		            
		            Element rootElement = document.getDocumentElement();
		            System.out.println("Root Element = " + rootElement.getNodeName());
		            NodeList personList = rootElement.getElementsByTagName("data");
		            for (int i = 0; i < personList.getLength(); i++) {
		                Element person = (Element) personList.item(i);
		                Element product = (Element) person.getElementsByTagName("product_name").item(0);
		                Element company = (Element) person.getElementsByTagName("company_name").item(0);
		                Element versionName = (Element) person.getElementsByTagName("version").item(0);
		                Element keyName = (Element) person.getElementsByTagName("key").item(0);
		                Element typeName = (Element) person.getElementsByTagName("type").item(0);
		                Element courses = (Element) person.getElementsByTagName("Video").item(0);
		                Element validityDate = (Element) person.getElementsByTagName("validity").item(0);

		                String productName = product.getTextContent();
		                String companyName = company.getTextContent();
		                String version = versionName.getTextContent();
		                String key = keyName.getTextContent();
		                String type = typeName.getTextContent();
		                String course = courses.getTextContent();
		                String validity = validityDate.getTextContent();
		                
		                
		                this.licensedetails(productName, companyName, key, validity,course,type,file);

//		                this.licensedetails(productName, companyName, key, validity, course, type);
//		                this.licensedetails(productName, companyName, key, validity,course,type,file);
		                System.out.println("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
		                System.out.println("product_name: " + productName + " company_name: " + companyName + " version: " + version + " key: " + key + " type: " + type + " validity: " + validity + " Video: " + course + " lastModifiedDate: " + lastModifiedDate);
		                System.out.println("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
		            }
		            
		            return ResponseEntity.ok().body(savedAudio);
		        } catch (ParserConfigurationException | SAXException |DateTimeParseException| IOException e) {
		            e.printStackTrace();
		            System.err.println("Error parsing date string:"+e.getMessage());
		            logger.error("", e);
		            return ResponseEntity.badRequest().build();
		        }
		    }

			
			 public  License saveFile(MultipartFile File) throws IOException {
			        // Save the audio file to the server and get the file path
			         this.savFile(File);
//			        license
			          
			        return null ;
			    }
			 public String savFile(MultipartFile File) throws IOException {
			        // Generate a unique file name (you can use other strategies)
			        String uniqueFileName =File.getOriginalFilename();
			        System.out.println("audioFile.getOriginalFilename()");
			        System.out.println(File.getOriginalFilename());
			        Path uploadPath = Paths.get(LicenceDirectory);
			        if (!Files.exists(uploadPath)) {
			        	System.out.println("---------------------Folder created--------------------------------");
			            Files.createDirectories(uploadPath);
			        }
			        this.file=File.getOriginalFilename();
			        logger.info(file);
			        
			        // Define the file path where the audio file will be stored
			        String filePath = Paths.get(LicenceDirectory).resolve(uniqueFileName).toString();
//			        String modifiedPath = filePath.replace("Audio\\", "");
//			        System.out.println(modifiedPath);
	
	
			        // Save the file to the server
			        Files.copy(File.getInputStream(), Path.of(filePath), StandardCopyOption.REPLACE_EXISTING);
			        System.out.println("--------------------------------File uploaded------------------------------------------");
		            
	
			        return "modifiedPath";   
			        
			    }
			   
		//   -------------------------------
		    public String licensedetails(String product_name, String company_name, String key, String validity,String course,String type,String file) {
		    	
		    	Iterable<License> licenseIterable = licenseRepository.findAll();
		    	List<License> licenseList = StreamSupport.stream(licenseIterable.spliterator(), false)
                        .collect(Collectors.toList());
		    	if(licenseList.isEmpty())
		    	{
		    	License data =new License();
		        LocalDate currentDate = LocalDate.now();
		        java.util.Date Datecurrent = java.sql.Date.valueOf(currentDate);
		        int num = validity.isEmpty()?0:Integer.parseInt(validity);
		        LocalDate futureDate = currentDate.plusDays(num);
		        java.util.Date Datefuture = java.sql.Date.valueOf(futureDate);
		        data.setStart_date(Datecurrent);
		        data.setEnd_date(Datefuture);
		        data.setCompany_name(company_name);
		        data.setKey(key);
		        data.setProduct_name(product_name);
		        data.setCourse(course);;
		        data.setType(type);
		        data.setFilename(file);
		        licenseRepository.save(data);   
		    	}
		    	else {
		    		for (License license : licenseList) {
		    		if(!(license.getKey().equals(key)))
		    		{
		    			
		    			license.getFilename();
		    		System.out.println("file are same  :"+(file.equals(license.getFilename())));
		    			
		    			 String filePath =LicenceDirectory+license.getFilename();
		    		        File file1 = new File(filePath);
		    		        if (file1.exists()&& !(file.equals(license.getFilename()))) {
		    		            // Attempt to delete the file
		    		            if (file1.delete()) {
		    		                logger.info("File deleted successfully.");
		    		            } else {
		    		            	logger.info("Failed to delete the file.");
		    		            }
		    		        } else {
		    		        	logger.info("File does not exist.");
		    		        }
		    			
		    			licenseRepository.deleteAll();
		    			
		    			
		    			
		    			License data =new License();
				        LocalDate currentDate = LocalDate.now();
				        java.util.Date Datecurrent = java.sql.Date.valueOf(currentDate);
				        int num = validity.isEmpty()?0:Integer.parseInt(validity);
				        LocalDate futureDate = currentDate.plusDays(num);
				        java.util.Date Datefuture = java.sql.Date.valueOf(futureDate);
				        data.setStart_date(Datecurrent);
				        data.setEnd_date(Datefuture);
				        data.setCompany_name(company_name);
				        data.setKey(key);
				        data.setProduct_name(product_name);
				        data.setCourse(course);;
				        data.setType(type);
				        data.setFilename(file);
				        licenseRepository.save(data);   
		    			
		    			
		    		}
		    			
		    		}
		    		
		    	}
		    	
		    	
		    	
		        return null;
		    }

}