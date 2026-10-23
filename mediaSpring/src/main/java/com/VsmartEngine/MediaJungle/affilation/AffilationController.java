package com.VsmartEngine.MediaJungle.affilation;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Random;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.VsmartEngine.MediaJungle.LogManagement;

import io.swagger.v3.oas.annotations.parameters.RequestBody;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

@CrossOrigin()
@RestController
@RequestMapping("/api/v2/")
public class AffilationController {

	@Autowired
	private JavaMailSender sender;

	@Autowired
	private AffilatersRepository AffilatersRepository;
	private static final Logger logger = LoggerFactory.getLogger(AffilationController.class);

	public String generateHtmlContent(String referralid, String coupon10, String coupon20) {
		String htmlContent = """
											        <!DOCTYPE html>
											        <html lang="en">
											        <head>
											            <meta charset="UTF-8">
											            <meta name="viewport" content="width=device-width, initial-scale=1.0">
											            <title>Dynamic HTML Page</title>
											            <style>

								body {
								  font-family: "Open Sans", sans-serif;
								  color: #0c0c0c;
								  background-color: #ffffff;
								  overflow-x: hidden;
								    align-items: center;
								  text-align: center;
								}


								.info_section {
								  background-color: #00204a;
								  color: #ffffff;
								  padding: 45px 0 15px 0;

								}

								.layout_padding2 {
								  padding: 75px 0;
								   align-items: center;
								  text-align: center;
								}

								.heading_container.heading_center {
								  -webkit-box-align: center;
								      -ms-flex-align: center;
								          align-items: center;
								  text-align: center;
								}

								.heading_container {
								  display: -webkit-box;
								  display: -ms-flexbox;
								  display: flex;
								  -webkit-box-orient: vertical;
								  -webkit-box-direction: normal;
								      -ms-flex-direction: column;
								          flex-direction: column;
								  -webkit-box-align: start;
								      -ms-flex-align: start;
								          align-items: flex-start;
								           align-items: center;
								  text-align: center;
								}
								 h1 {
								  position: relative;
								  font-weight: bold;
								  margin-bottom: 0;
								  align-items: center;
								  text-align: center;

								}


								h1 span {
								  color: #00bbf0;
								  align-items: center;
								  text-align: center;

								}

								.service_section .box {
								  display: -webkit-box;
								  display: -ms-flexbox;
								  display: flex;
								  -webkit-box-orient: vertical;
								  -webkit-box-direction: normal;
								      -ms-flex-direction: column;
								          flex-direction: column;
								  -webkit-box-align: center;
								      -ms-flex-align: center;
								          align-items: center;
								  text-align: center;
								  margin-top: 20px;
								  padding: 1%%;
								  border-radius: 5px;
								   align-items: center;
								  text-align: center;
								}

								.service_section .box .detail-box h5 {
								  font-weight: bold;
								  text-transform: uppercase;
								   align-items: center;
								  text-align: center;
								}
								.layout_padding {
								  padding: 20px 0;
								  align-items: center;
								  text-align: center;

								}
								.info_section {
								  background-color: #00204a;
								  color: #ffffff;
								  padding: 45px 0 15px 0;
								}

								.info_section {
								margin-bottom: 0px;
								}
				               .rowr {
				                   display: flex;
				                   justify-content: center; /* Centers the boxes horizontally */
				                   gap: 20px; /* Adds space between boxes */
				                   padding: 20px;
				               }
				               .box {
				                   background-color: #00bbf0;
				                   color: white;
				                   text-align: center;
				                   border-radius: 8px;
				                   box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
				                   transition: transform 0.2s;
               
				               				    align-items: center;
				               				  text-align: center;
				               				  margin:20px;
				}

											            </style>
								</head>
											        </head>
											        <body>
											         <section class="info_section layout_padding2">
								    <div class="container">
								      <div class="row" ></div>
								    </div>
								  </section>
								    <section class="service_section layout_padding">

								      <div class="container ">
								      <div class="row">

								          <h1>
								            Unlock Up to <span>20%% OFF</span>
								          </h1>

								        </div>

								          <h3> Your Special Reward Awaits!</h3>

								          <h4>
								            Use your unique coupon code to earn 10%% or 20%% off on any of the following services:
								          </h4>
								        <div class="rowr">
				    <div class="box">
				        <div class="detail-box">
				            <h5>Passcode</h5>
				            <p>%s</p>
				        </div>
				    </div>

				    <div class="box">
				        <div class="detail-box">
				            <h5>COUPON 10%%</h5>
				            <p>%s</p>
				        </div>
				    </div>

				    <div class="box">
				        <div class="detail-box">
				            <h5>COUPON 20%%</h5>
				            <p>%s</p>
				        </div>
				    </div>
				</div>


								    </div>
								  </section>
								         <section class="info_section layout_padding2">
								    <div class="container">
								      <div class="row"></div>
								    </div>
								  </section>

											        </body>
											        </html>
											        """
				.formatted(referralid, coupon10, coupon20);

		return htmlContent;
	}

	@PostMapping("/affliation")
	public ResponseEntity<Map<String, Object>> getAfliater(@RequestBody Affilaters data) {
		Affilaters savedData = AffilatersRepository.save(data);
		String UseremailID = savedData.getEmailId();
		long id = savedData.getId();

		// Random generation logic
		String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
		Random random = new Random();
		StringBuilder sb = new StringBuilder();
		StringBuilder sb1 = new StringBuilder();
		StringBuilder sb2 = new StringBuilder();

		for (int i = 0; i < 4; i++) {
			sb.append(characters.charAt(random.nextInt(characters.length())));
			sb1.append(characters.charAt(random.nextInt(characters.length())));
			sb2.append(characters.charAt(random.nextInt(characters.length())));
		}

		String randomAlphanumeric = sb.toString();
		String randomAlphanumeric10 = sb1.toString();
		String randomAlphanumeric20 = sb2.toString();

		String idStr = String.format("%02d", id % 100);
		String referralid = randomAlphanumeric + idStr;
		String coupon10 = randomAlphanumeric10 + "10";
		String coupon20 = randomAlphanumeric20 + "20";

		Optional<Affilaters> editdata = AffilatersRepository.findById(id);
		if (editdata.isPresent()) {
			Affilaters locadata = editdata.get();
			locadata.setCoupon10(coupon10);
			locadata.setCoupon20(coupon20);
			locadata.setReferalid(referralid);
			AffilatersRepository.save(locadata);
		}

		// Send email asynchronously
		this.mail(UseremailID, referralid, coupon10, coupon20);

		// Prepare response
		Map<String, Object> response = new HashMap<>();
		response.put("message", "Data saved successfully");
		return ResponseEntity.ok(response);
	}

//	
	
//	@GetMapping("/test")
	@Async
	public void mail(String UseremailID, String referralid, String coupon10, String coupon20)
//	public void mail()
	
	{
//		String UseremailID="cheziangowtham@gmail.com";
//		String referralid="hjjhjjk";
//		String coupon10="ghjhj";
//		String coupon20="oiujh";

		String htmlContent = generateHtmlContent(referralid, coupon10, coupon20);
		MimeMessage mimeMessage = sender.createMimeMessage();
		try {
			MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true);

			// Set email details
			helper.setTo(UseremailID);
			helper.setSubject("Learnhub");
			helper.setText(htmlContent, true); // true for HTML

			// Send the email
			sender.send(mimeMessage);
		} catch (MessagingException e) {
			// Handle the exception
			e.printStackTrace();
			logger.error("", e);
			// You can log the error or rethrow it as a runtime exception, depending on your
			// needs
			throw new RuntimeException("Failed to send email", e);
		}

	}

}
