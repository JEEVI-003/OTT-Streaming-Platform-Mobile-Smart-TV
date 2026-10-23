package com.VsmartEngine.MediaJungle.File;


import java.io.File;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Date;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.VsmartEngine.MediaJungle.LogManagement;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.Marshaller;
import org.springframework.beans.factory.annotation.Value;

@Service
public class XmlFileService {

	private final Root root;
	private static final Logger logger = LoggerFactory.getLogger(XmlFileService.class);
	
	@Value("${jwt.secret}")
	private String jwtSecret;

    public XmlFileService(Root root) {
        this.root = root;
    }
    
    public void createXmlFile(String filePath, String trainer, String student, String validity, 
            String course, String type, String companyName, String storageSize, 
            String productName, String version) {
try {
LocalDate currentDate = LocalDate.now();
SimpleDateFormat formatter = new SimpleDateFormat("ddMMyyyy");

String formattedDate = formatter.format(Date.from(currentDate.atStartOfDay(ZoneId.systemDefault()).toInstant())) 
                  + course + type + validity;
String formattedDate2 = formatter.format(Date.from(currentDate.plusDays(1)
                  .atStartOfDay(ZoneId.systemDefault()).toInstant())) 
                  + course + type + validity;

String key = Jwts.builder()
  .setSubject(formattedDate)
  .signWith(SignatureAlgorithm.HS256, jwtSecret)
  .compact();
String key2 = Jwts.builder()
  .setSubject(formattedDate2)
  .signWith(SignatureAlgorithm.HS256, jwtSecret)
  .compact();

Data data = new Data(companyName,productName, storageSize , version, key, key2, type, course, trainer, student, validity);
Root root = new Root(); // Assuming a default constructor exists
root.setData(data);

JAXBContext context = JAXBContext.newInstance(Root.class);
Marshaller marshaller = context.createMarshaller();
marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);

marshaller.marshal(root, new File(filePath));
System.out.println("XML file created successfully at: " + filePath);
} catch (Exception e) {
	logger.error("", e);
e.printStackTrace();
}
}


}
