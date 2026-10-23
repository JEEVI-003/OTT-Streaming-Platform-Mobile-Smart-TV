package com.VsmartEngine.MediaJungle.test;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

public class Utill {
	
	@Value("${jwt.secret}")
    private static String secretKey;
	 private static final Logger logger = LoggerFactory.getLogger(Utill.class);

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		 DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		  try {
		 DocumentBuilder builder = factory.newDocumentBuilder();
			Document document = builder.parse(new File("licence/data.xml"));
			 Element rootElement=document.getDocumentElement();
			 NodeList personList = rootElement.getElementsByTagName("data");
			File file = new File("licence/data.xml");
			long lastModified = file.lastModified();
			System.out.println("----------------------------------------------------------------");
			logger.info("Last modified string"+lastModified);
			 Date date = new Date(lastModified);
			 logger.info("Last modified date"+date);
			 SimpleDateFormat formatter = new SimpleDateFormat("ddMMyyyy");
			 Element person4 = (Element) personList.item(0);
			  Element trai = (Element) person4.getElementsByTagName("Video").item(0);
              Element stud = (Element) person4.getElementsByTagName("type").item(0);
              Element val = (Element) person4.getElementsByTagName("validity").item(0);
              String tra = trai.getTextContent();
              String stude = stud.getTextContent();
              String valid = val.getTextContent();
              logger.info("No of videos"+tra);
              logger.info("type of license "+stude);
	         String formattedDate = tra+stude+valid;
	         logger.info("Last modified date complete"+formattedDate);
             System.out.println("----------------------------------------------------------------");
             logger.info(Jwts.builder()
             .setSubject(formattedDate)
	            .signWith(SignatureAlgorithm.HS256, secretKey)
	            .compact());
             DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
             DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
             Document doc = dBuilder.parse(file);
             Element root = doc.getDocumentElement();
             Element validity2 = doc.createElement("key");
             validity2.appendChild(
             		doc.createTextNode(Jwts.builder()
 	                .setSubject(formattedDate)
 		            .signWith(SignatureAlgorithm.HS256, secretKey)
 		            .compact())
             		);
             NodeList dataList = root.getElementsByTagName("data");
             Element data = (Element) dataList.item(0);
             Element type2 = (Element) data.getElementsByTagName("version").item(0);
             
             
             Element person1 = (Element) personList.item(0);
             Element key_name1 = (Element) person1.getElementsByTagName("key").item(0);
             
             if(key_name1== null) {
             data.insertBefore(validity2, type2.getNextSibling());
             doc.normalize();
             FileOutputStream fileOutputStream = new FileOutputStream(file);
             try {
             javax.xml.transform.TransformerFactory.newInstance().newTransformer().transform(
                     new javax.xml.transform.dom.DOMSource(doc),
                     new javax.xml.transform.stream.StreamResult(fileOutputStream));
             fileOutputStream.close();

             logger.info("XML file updated successfully!");

             }
             catch (Exception e) {
                 e.printStackTrace();
             }
             }
             else {
			System.out.println("----------------------------------------------------------------");
			logger.info("Root Element ="+rootElement.getNodeName());
			
//	            for (int i = 0; i < personList.getLength(); i++) {
	                Element person = (Element) personList.item(0);
	                // Get the <name> element inside each <person> element
	                Element product = (Element) person.getElementsByTagName("product_name").item(0);
	                Element company = (Element) person.getElementsByTagName("company_name").item(0);
	                Element version_name = (Element) person.getElementsByTagName("version").item(0);
	                Element key_name = (Element) person.getElementsByTagName("key").item(0);
	                Element type_name = (Element) person.getElementsByTagName("type").item(0);
	                Element trainers = (Element) person.getElementsByTagName("Video").item(0);
	                Element validity_date = (Element) person.getElementsByTagName("validity").item(0);
	                // Get the text content of the <name> element
	                String product_name = product.getTextContent();
	                String company_name = company.getTextContent();
	                String version = version_name.getTextContent();
	                String key = key_name.getTextContent();
	                String type = type_name.getTextContent();
	                String trainer = trainers.getTextContent();
	              
	                String validity = validity_date.getTextContent();
	                

	                logger.info("product_name:" + product_name+" company_name: "+company_name+" version: "+version+" key: "+key+" type: "+type+" validity: "+validity+"trainer: "+trainer);

//	            }
             }
		  }
	            catch (ParserConfigurationException |SAXException|IOException  e) {
	                e.printStackTrace();
	         
	            }
	
	}
}