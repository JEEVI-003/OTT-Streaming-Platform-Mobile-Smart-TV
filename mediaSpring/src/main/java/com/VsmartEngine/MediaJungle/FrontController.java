package com.VsmartEngine.MediaJungle;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import com.VsmartEngine.MediaJungle.Banner.VideoBanner;
import com.VsmartEngine.MediaJungle.Banner.videoBannerController;
import com.VsmartEngine.MediaJungle.Container.VideoContainer;
import com.VsmartEngine.MediaJungle.Container.VideoContainerController;
import com.VsmartEngine.MediaJungle.Container.VideoContainerDTO;
import com.VsmartEngine.MediaJungle.Library.LibraryController;
import com.VsmartEngine.MediaJungle.Library.LikedsongsDTO;
import com.VsmartEngine.MediaJungle.Library.Playlist;
import com.VsmartEngine.MediaJungle.Library.PlaylistController;
import com.VsmartEngine.MediaJungle.Library.WatchLaterDTO;
import com.VsmartEngine.MediaJungle.Library.playlistDTO;
import com.VsmartEngine.MediaJungle.MailVerification.VerificationController;
import com.VsmartEngine.MediaJungle.controller.AddUserController;
import com.VsmartEngine.MediaJungle.controller.AudioController1;
import com.VsmartEngine.MediaJungle.controller.CastandcrewController;
import com.VsmartEngine.MediaJungle.controller.CategoryController;
import com.VsmartEngine.MediaJungle.controller.CertificateController;
import com.VsmartEngine.MediaJungle.controller.EmployeeController;
import com.VsmartEngine.MediaJungle.controller.FeatureController;
import com.VsmartEngine.MediaJungle.controller.FooterSettingsController;
import com.VsmartEngine.MediaJungle.controller.LanguageController;
import com.VsmartEngine.MediaJungle.controller.LicenseController;
import com.VsmartEngine.MediaJungle.controller.MailSettingController;
import com.VsmartEngine.MediaJungle.controller.PaymentController;
import com.VsmartEngine.MediaJungle.controller.PaymentSettingController;
import com.VsmartEngine.MediaJungle.controller.PlanDescriptionController;
import com.VsmartEngine.MediaJungle.controller.PlanDetailsController;
import com.VsmartEngine.MediaJungle.controller.PlanFeatureMergeController;
import com.VsmartEngine.MediaJungle.controller.ProfileImageController;
import com.VsmartEngine.MediaJungle.controller.TagController;
import com.VsmartEngine.MediaJungle.controller.TenureController;
import com.VsmartEngine.MediaJungle.controller.UserWithStatus;
import com.VsmartEngine.MediaJungle.controller.VideoCastAndCrewController;
import com.VsmartEngine.MediaJungle.model.AddCertificate;
import com.VsmartEngine.MediaJungle.model.AddLanguage;
import com.VsmartEngine.MediaJungle.model.AddNewCategories;
import com.VsmartEngine.MediaJungle.model.AddUser;
import com.VsmartEngine.MediaJungle.model.Addaudio1;
import com.VsmartEngine.MediaJungle.model.CastandCrew;
import com.VsmartEngine.MediaJungle.model.CastandCrewDTO;
import com.VsmartEngine.MediaJungle.model.Companysiteurl;
import com.VsmartEngine.MediaJungle.model.Contactsettings;
import com.VsmartEngine.MediaJungle.model.Emailsettings;
import com.VsmartEngine.MediaJungle.model.License;
import com.VsmartEngine.MediaJungle.model.Mobilesettings;
import com.VsmartEngine.MediaJungle.model.Othersettings;
import com.VsmartEngine.MediaJungle.model.PaymentUser;
import com.VsmartEngine.MediaJungle.model.Paymentsettings;
import com.VsmartEngine.MediaJungle.model.PlanDetails;
import com.VsmartEngine.MediaJungle.model.PlanFeatureMerge;
import com.VsmartEngine.MediaJungle.model.PlanFeatures;
import com.VsmartEngine.MediaJungle.model.Seosettings;
import com.VsmartEngine.MediaJungle.model.Sitesetting;
import com.VsmartEngine.MediaJungle.model.Tag;
import com.VsmartEngine.MediaJungle.model.Tenure;
import com.VsmartEngine.MediaJungle.model.UserListWithStatus;
import com.VsmartEngine.MediaJungle.model.VideoCastAndCrew;
import com.VsmartEngine.MediaJungle.model.Videosettings;
import com.VsmartEngine.MediaJungle.notification.controller.NotificationController;
import com.VsmartEngine.MediaJungle.userregister.UserRegister;
import com.VsmartEngine.MediaJungle.userregister.UserRegisterController;
import com.VsmartEngine.MediaJungle.userregister.UserRegisterDTO;
import com.VsmartEngine.MediaJungle.video.VideoController;
import com.VsmartEngine.MediaJungle.video.VideoDescription;
import com.VsmartEngine.MediaJungle.video.VideoImageController;
import com.VsmartEngine.MediaJungle.video.VideoScreenDTO;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.transaction.Transactional;

@CrossOrigin()
@RestController
@RequestMapping("/api/v2/")
public class FrontController {

	@Autowired
	public AddUserController AddUserController;

	@Autowired
	private AudioController1 AudioController;

	@Autowired
	private CastandcrewController CastandcrewController;

	@Autowired
	private FeatureController FeatureController;

	@Autowired
	private TenureController TenureController;
	@Autowired
	private ProfileImageController ProfileImageController;
	@Autowired
	private FooterSettingsController FooterSettingsController;
	@Autowired
	private CategoryController CategoryController;

	@Autowired
	private CertificateController CertificateController;

	@Autowired
	private EmployeeController EmployeeController;

	@Autowired
	private LanguageController LanguageController;

	@Autowired
	private LicenseController LicenseController;

	@Autowired
	private PaymentController PaymentController;

	@Autowired
	private PaymentSettingController PaymentSettingController;

	@Autowired
	private PlanDescriptionController PlanDescriptionController;

	@Autowired
	private PlanDetailsController PlanDetailsController;

	@Autowired
	private TagController TagController;

	@Autowired
	private VideoCastAndCrewController VideoCastAndCrewController;

	@Autowired
	private UserRegisterController UserRegisterController;

	@Autowired
	private NotificationController NotificationController;

	@Autowired
	private VideoController VideoController;
	
	@Autowired
	private VideoImageController videoImageController;
	
	@Autowired
	private VideoContainerController videocontainercontroller;
	
	@Autowired
	private videoBannerController videobannercontroller;
	
	@Autowired
	private PlanFeatureMergeController PlanFeatureMergeController;
  @Autowired
	private PlaylistController playlistcontroller;
	
	@Autowired
	private LibraryController librarycontroller;
	
	@Autowired
	private VerificationController verificationcontroller;
	
	@Autowired MailSettingController mailsettingcontroller;
	
	@Autowired 
	private LogManagement logManagement;
	
	@GetMapping("/dashstatus/{videoId}")
	public ResponseEntity<Map<String, String>> getDashStatus(@PathVariable Long videoId) {
	    return VideoController.getDashStatus(videoId);
	}
	
	@PostMapping("/AdminRegister")
	public ResponseEntity<?> adminRegister(@RequestBody AddUser data) {
		return AddUserController.adminRegister(data);
	}
	

	@PostMapping("/AddUser")
	public ResponseEntity<?> addUser(@RequestBody AddUser data, @RequestHeader("Authorization") String token) {

		return AddUserController.addUser(data,token);
	}

	@PostMapping("/login/admin")
	public ResponseEntity<?> login(@RequestBody Map<String, String> loginRequest) {

		return AddUserController.loginadmin(loginRequest);
	}
	@PostMapping("/logout/admin")
	 public ResponseEntity<String> logoutadmin(@RequestHeader("Authorization") String token) {
		return AddUserController.logoutadmin(token);
	}

	@GetMapping("/GetUserId/{userId}")
	public ResponseEntity<UserListWithStatus> getUser(@PathVariable Long userId) {

		return AddUserController.getUser(userId);
	}
	
	@GetMapping("/checkAdminRole")
	public ResponseEntity<?> checkAdminRole() {
           return AddUserController.checkAdminRole();
	}

	@DeleteMapping("/DeleteUser/{UserId}")
	 public ResponseEntity<String> deleteUser(
			    @RequestHeader("Authorization") String token, 
			    @PathVariable Long UserId
			){

		return AddUserController.deleteUser(token,UserId);

	}
	
	@DeleteMapping("/DeletemultipleAdmins")
    public ResponseEntity<String> deleteMultipleAdmins(
            @RequestHeader("Authorization") String token, 
            @RequestBody List<Long> userIds // Accept a list of user IDs
    ) {
		return AddUserController.deleteMultipleAdmins(token, userIds);
	}

	@PatchMapping("/UpdateUser/{userId}")
	public ResponseEntity<String> updateUserDetails(@PathVariable Long userId, @RequestBody AddUser updatedUserData) {

		return AddUserController.updateUserDetails(userId, updatedUserData);
	}

	 @PostMapping("/uploadaudio")
	 public ResponseEntity<Addaudio1> uploadAudio(@RequestParam("category") Long categoryId,
	                                              @RequestParam("audioFile") MultipartFile audioFile,
	                                              @RequestParam("thumbnail") MultipartFile thumbnail,
	                                              @RequestParam(value = "paid", required = false) boolean paid,
	                                              @RequestHeader("Authorization") String token) {

		return AudioController.uploadAudio(categoryId, audioFile, thumbnail, paid, token);
	}

	 
	 
	 
//	 Add the {filename} with the extension example(mp3,mp4 etc).
	@GetMapping("/{filename:.+}/file")
	public ResponseEntity<Resource> getAudioFile(@PathVariable String filename, HttpServletRequest request) {
		return AudioController.getAudioFile(filename, request);
	}

	@GetMapping("/audio/{id}")
	@Transactional
	public ResponseEntity<Addaudio1> getAudioById(@PathVariable Long id) {

		return AudioController.getAudioById(id);
	}


	@GetMapping("/audio/{id}/file")
	public ResponseEntity<Resource> getAudioFile(@PathVariable String id) throws IOException {

		return AudioController.getAudioFile(id);
	}

	@GetMapping("/audio/list")
	public ResponseEntity<List<String>> listAudioFiles() throws IOException {

		return AudioController.listAudioFiles();
	}

	@GetMapping("/GetAll")
	public ResponseEntity<List<Addaudio1>> getAllAudio() {
		return AudioController.getAllUser();
	}

	@GetMapping("/GetDetail/{id}")
	public ResponseEntity<Addaudio1> getAudioDetail(@PathVariable Long id) {

		return AudioController.getAudioDetail(id);

	}

	@GetMapping("/{id}/filename")
	public ResponseEntity<String> getAudioFilename(@PathVariable Long id) {

		return AudioController.getAudioFilename(id);
	}

	@GetMapping("/GetAllThumbnail")
	public ResponseEntity<List<byte[]>> getAllThumbnail() {

		return AudioController.getAllThumbnail();

	}

	@GetMapping("/getbannerthumbnailsbyid/{id}")
	public ResponseEntity<List<String>> getaudiobannerById(@PathVariable Long id) {

		return AudioController.getaudiobannerById(id);
	}
	
	@GetMapping("/getaudiothumbnailsbyid/{id}")
	public ResponseEntity<? > getaudioThumbnailsById(@PathVariable Long id) {

		return AudioController.getaudioThumbnailsById(id);
	}

	@GetMapping("/GetThumbnailsById/{id}")
	public ResponseEntity<List<String>> getAudioThumbnailsById(@PathVariable Long id) {

		return AudioController.getThumbnailsById(id);
	}

	@DeleteMapping("/audio/{id}")
	 public ResponseEntity<Map<String, String>> deleteAudioById(@PathVariable Long id, @RequestHeader("Authorization") String token) {
		 
		return AudioController.deleteAudioById(id, token);

	}

	@PatchMapping("/updateaudio/update/{audioId}")
	 public ResponseEntity<?> updateAudio(		
		        @PathVariable Long audioId,
		        @RequestParam(value = "audioFile", required = false) MultipartFile audioFile,
		        @RequestParam(value = "thumbnail", required = false) MultipartFile thumbnail,
		        @RequestParam(value = "category", required = false) Long categoryId,
		        @RequestHeader("Authorization") String token)
		     {
		return AudioController.updateAudio(audioId, audioFile, thumbnail, categoryId, token);
	}

	@PostMapping("/addcastandcrew")
	public ResponseEntity<?> addCast(@RequestParam("image") MultipartFile image,
            @RequestParam("name") String name,
            @RequestParam("description")String description,
            @RequestHeader("Authorization") String token) throws IOException {

		return CastandcrewController.addCast(image, name,description, token);
	}

	@GetMapping("/GetAllcastandcrew")
	public ResponseEntity<List<CastandCrew>> getAllPCastandcrew() {

		return CastandcrewController.getAllPCastandcrew();
	}
	
	@GetMapping("/getcastids")
    public ResponseEntity<List<CastandCrewDTO>> getCastandcrewByIds(@RequestParam List<Long> ids) {
		 return CastandcrewController.getCastandcrewByIds(ids);
	 }

	@GetMapping("/getcast/{id}")
	public ResponseEntity<CastandCrew> getcast(@PathVariable Long id) {

		return CastandcrewController.getcast(id);
	}
	
	@GetMapping("/getcastimage/{Id}")
	 public ResponseEntity<byte[]> getVideocast(@PathVariable long Id) {
		 return CastandcrewController.getVideocast(Id);
	}

	@GetMapping("/GetAllcastthumbnail")
	public ResponseEntity<List<byte[]>> getcastthumbnail() {

		return CastandcrewController.getcastthumbnail();
	}

	@GetMapping("/GetThumbnailsforcast/{id}")
	public ResponseEntity<List<String>> getCastThumbnailsById(@PathVariable Long id) {
		return CastandcrewController.getThumbnailsById(id);
	}

	
	@DeleteMapping("/Deletecastandcrew/{Id}")
	  public ResponseEntity<?> deletecast(@PathVariable Long Id,@RequestHeader("Authorization") String token) {

		return CastandcrewController.deletecast(Id, token);
	}

	@PatchMapping("/updatecastandcrew/{id}")
	public ResponseEntity<String> updateCast(
	        @PathVariable Long id,
	        @RequestParam(value = "image", required = false) MultipartFile image,
	        @RequestParam(value = "name", required = false) String name,
	        @RequestParam(value= "description",required = false)String description,
	        @RequestHeader("Authorization") String token) {
		return CastandcrewController.updateCast(id, image, name,description,token);
	}
	
	@PostMapping("/AddNewCategories")
	public ResponseEntity<String> createCategory(@RequestHeader("Authorization") String token, @RequestBody AddNewCategories data) {
		
		return CategoryController.createCategory(token, data);
	}

	@PostMapping("/PlanFeatures")
	public ResponseEntity<String> createFeature(@RequestHeader("Authorization") String token, @RequestBody PlanFeatures data) {
		
		return FeatureController.createFeature(token, data);
	}


	@GetMapping("/GetAllFeatures")
	public ResponseEntity<List<PlanFeatures>> getAllFeature() {

		return FeatureController.getAllFeatures();
	}
	@GetMapping("/GetAllCategories")
	public ResponseEntity<List<AddNewCategories>> getAllCategories() {

		return CategoryController.getAllCategories();
	}


	@GetMapping("/GetFeatureById/{featureId}")
	public ResponseEntity<PlanFeatures> getFeatureById(@PathVariable Long featureId) {

		return FeatureController.getFeatureById(featureId);
	}
	@GetMapping("/GetCategoryById/{categoryId}")
	public ResponseEntity<AddNewCategories> getCategoryById(@PathVariable Long categoryId) {

		return CategoryController.getCategoryById(categoryId);
	}

	@DeleteMapping("/DeleteFeature/{featureId}")
	public ResponseEntity<?> deleteFeature(@PathVariable Long featureId, @RequestHeader("Authorization") String token) {
		

		return FeatureController.deleteFeature(featureId, token);
	}

	@DeleteMapping("/DeleteCategory/{categoryId}")
	public ResponseEntity<?> deleteCategory(@PathVariable Long categoryId, @RequestHeader("Authorization") String token) {
		

		return CategoryController.deleteCategory(categoryId, token);
	}
	@PatchMapping("/editFeature/{featureId}")
	public ResponseEntity<String> editFeatures(@PathVariable Long featureId, @RequestBody PlanFeatures editFeature,@RequestHeader("Authorization") String token) {


		return FeatureController.editFeatures(featureId, editFeature, token);
	}


	@PatchMapping("/editCategory/{categoryId}")
	public ResponseEntity<String> editCategories(@PathVariable Long categoryId, @RequestBody AddNewCategories editCategory,@RequestHeader("Authorization") String token) {


		return CategoryController.editCategories(categoryId, editCategory, token);
	}

	@PostMapping("/AddCertificate")
	public ResponseEntity<String> createEmployee(@RequestHeader("Authorization") String token,@RequestBody AddCertificate data) {

		return CertificateController.createEmployee(token, data);
	}

	@GetMapping("/GetAllCertificate")
	public ResponseEntity<List<AddCertificate>> getAllCertificate() {

		return CertificateController.getAllCertificate();
	}

	@GetMapping("/GetCertificateById/{certificateId}")
	public ResponseEntity<AddCertificate> getcetificateById(@PathVariable Long certificateId) {

		return CertificateController.getTagById(certificateId);
	}

	@DeleteMapping("/DeleteCertificate/{certificateId}")
	   public ResponseEntity<?> deletecertificate(@PathVariable Long certificateId,@RequestHeader("Authorization") String token) {

		return CertificateController.deleteCategory(certificateId, token);
	}

	@PatchMapping("/editCertificate/{certificateId}")
	public ResponseEntity<String> editCategories(@PathVariable Long certificateId, @RequestBody AddCertificate editCertificate,@RequestHeader("Authorization") String token) {
		

		return CertificateController.editCategories(certificateId, editCertificate, token);
	}

	@PostMapping("/OtherSettings")
	public ResponseEntity<?> addothersetting(@RequestHeader("Authorization") String token,@RequestParam("appstore") String appstore,
			@RequestParam("playstore") String playstore){

		return EmployeeController.addothersetting(token, appstore, playstore);
	}

	@GetMapping("/GetOthersettings")
	public ResponseEntity<List<Othersettings>> getOthersettings() {

		return EmployeeController.getOthersettings();
	}

	@PatchMapping("/editothersettings/{id}")
	public ResponseEntity<String> editothersetting(@PathVariable Long id, @RequestBody Othersettings updatedothersetting,
	        @RequestHeader("Authorization") String token) {
		
		return EmployeeController.editothersetting(id, updatedothersetting, token);
	}

	@PostMapping("/Companysiteurl")
	public ResponseEntity<?> addCompanysiteurl(@RequestBody Companysiteurl data) {
		
		return EmployeeController.addCompanysiteurl(data);
	}

	@GetMapping("/GetCompanysiteurl")
	public ResponseEntity<List<Companysiteurl>> getcompanysiteurl() {
		return EmployeeController.getcompanysiteurl();

	}

	@PostMapping("/seoSettings")
	public ResponseEntity<?> addSeosettings(@RequestBody Seosettings data) {
		return EmployeeController.addSeosettings(data);

	}

	@GetMapping("/GetseoSettings")
	public ResponseEntity<List<Seosettings>> getseoSettings() {
		return EmployeeController.getseoSettings();
	}

	@PostMapping("/Contactsettings")
	public ResponseEntity<?> contactsetting(@RequestHeader("Authorization") String token,@RequestParam("contact_email") String contact_email,
			@RequestParam("contact_mobile") String contact_mobile,
			@RequestParam("contact_address") String contact_address,
			@RequestParam("copyright_content") String copyright_content) {
		
		return EmployeeController.contactsetting(token, contact_email, contact_mobile, contact_address, copyright_content);

	}

	@GetMapping("/GetcontactSettings")
	public ResponseEntity<List<Contactsettings>> getcontactsettings() {

		return EmployeeController.getcontactsettings();

	}

	@PatchMapping("/editcontactsetting/{id}")
	public ResponseEntity<String> editcontact(@PathVariable Long id, 
	        @RequestParam(required = false) String contact_email,
	        @RequestParam(required = false) String contact_mobile,
	        @RequestParam(required = false) String contact_address,
	        @RequestParam(required = false) String copyright_content,
	        @RequestHeader("Authorization") String token) {

		return EmployeeController.editcontact(id, contact_email, contact_mobile, contact_address, copyright_content, token);
	}


	@PostMapping("/Emailsettings")
	public ResponseEntity<?> addEmailsettings(@RequestBody Emailsettings data) {
		return EmployeeController.addEmailsettings(data);
	}

	@GetMapping("/GetemailSettings")
	public ResponseEntity<List<Emailsettings>> getemailsettings() {
		return EmployeeController.getemailsettings();
	}

	@PostMapping("/Mobilesettings")
	public ResponseEntity<?> addMobilesettings(@RequestBody Mobilesettings data) {
		return EmployeeController.addMobilesettings(data);
	}

	@GetMapping("/GetmobileSettings")
	public ResponseEntity<List<Mobilesettings>> getmobilesettings() {
		return EmployeeController.getmobilesettings();
	}

	@PostMapping("/SiteSetting")
	public ResponseEntity<?> addsitesetting(@RequestParam("sitename") String sitename,
			@RequestParam("appurl") String appurl,
			@RequestParam("tagName") String tagName,
			@RequestParam("icon") MultipartFile icon,
			@RequestParam("logo") MultipartFile logo,
			@RequestHeader("Authorization") String token) throws IOException {

		return EmployeeController.addsitesetting(sitename, appurl, tagName, icon, logo, token);
	}

	@GetMapping("/GetsiteSettings")
	public ResponseEntity<List<Sitesetting>> getsitesettings() {

		return EmployeeController.getsitesettings();
	}
	
	@GetMapping("/logo/{Id}")
	public ResponseEntity<byte[]> getlogoThumbnail(@PathVariable long Id) {
		return EmployeeController.getlogoThumbnail(Id);
	}

	@PatchMapping("/editsettings/{id}")
    public ResponseEntity<String> editSetting(
	        @PathVariable Long id, 
	        @RequestParam(required = false) String sitename,
	        @RequestParam(required = false) String appurl,
	        @RequestParam(required = false) String tagName,
	        @RequestParam(required = false) MultipartFile icon,
	        @RequestParam(required = false) MultipartFile logo,
	        @RequestHeader("Authorization") String token) {

		return EmployeeController.editSetting(id, sitename, appurl, tagName, icon, logo, token);
	}

	@PostMapping("/videoSetting")
	public ResponseEntity<?> addVideosettings(@RequestBody Videosettings data) {
		return EmployeeController.addVideosettings(data);
	}

	@GetMapping("/GetvideoSettings")
	public ResponseEntity<List<Videosettings>> getvideosettings() {
		return EmployeeController.getvideosettings();
	}

//	@PostMapping("/Socialsettings")
//	public ResponseEntity<?> addSocialsettings(@RequestBody SocialSettings data) {
//		return EmployeeController.addSocialsettings(data);
//	}
//
//	@GetMapping("/GetsocialSettings")
//	public ResponseEntity<List<SocialSettings>> getsocialsettings() {
//		return EmployeeController.getsocialsettings();
//	}

	@PostMapping("/AddLanguage")
	public ResponseEntity<String> createEmployee(@RequestHeader("Authorization") String token,@RequestBody AddLanguage data) {
		
		return LanguageController.createEmployee(token, data);
	}

	@GetMapping("/GetAllLanguage")
	public ResponseEntity<List<AddLanguage>> getAllLanguage() {
		return LanguageController.getAllLanguage();
	}

	@GetMapping("/GetLanguageById/{languageId}")
	public ResponseEntity<AddLanguage> getLanguageById(@PathVariable Long languageId) {
		return LanguageController.getTagById(languageId);
	}

	@DeleteMapping("/DeleteLanguage/{categoryId}")
	  public ResponseEntity<?> deleteLanguage(@PathVariable Long categoryId,@RequestHeader("Authorization") String token) {
		return LanguageController.deleteLanguage(categoryId, token);
	}

	@PatchMapping("/editLanguage/{languageId}")
	public ResponseEntity<String> editLanguage(@PathVariable Long languageId,@RequestBody AddLanguage editlanguage,@RequestHeader("Authorization") String token) {
		
		return LanguageController.editLanguage(languageId, editlanguage, token);
	}

	@GetMapping("/GetAllUser")
	public ResponseEntity<UserWithStatus> getAllUser() {
		return LicenseController.getAllUser();
	}

	@GetMapping("/count")
	public ResponseEntity<Integer> count() {
		return LicenseController.count();
	}

	@PostMapping("/uploadfile")
	public ResponseEntity<License> upload(@RequestParam("audioFile") MultipartFile File,
			@RequestParam("lastModifiedDate") String lastModifiedDate) {
		return LicenseController.upload(File, lastModifiedDate);
	}

	@PostMapping("/payment")
    public String Payment(@RequestBody Map<String, String> requestData) {
		return PaymentController.Payment(requestData);
	}

//	@PostMapping("/buy")
//	public ResponseEntity<String> updatePaymentId(@RequestBody Map<String, String> requestData) {
//
//		return PaymentController.updatePaymentId(requestData);
//	}
	
	@GetMapping("/paymentHistory/{userId}")
	public ResponseEntity<List<PaymentUser>> getPaymentHistory(@PathVariable Long userId) {
			
		return PaymentController.getPaymentHistory(userId);
	  
	}
	
	   @PostMapping("/confirmPayment")
	   public ResponseEntity<Map<String, String>> confirmPayment(@RequestBody Map<String, String> requestData) {
	   return PaymentController.confirmPayment(requestData);
	   }
	
	   @GetMapping("GetPlanDetailsByUserId/{userId}")
	    public ResponseEntity<Map<String, String>> getPlanDetailsByUserId(@PathVariable Long userId) {
		   return PaymentController.getPlanDetailsByUserId(userId);
	   }
       @PostMapping("/submit")
       public ResponseEntity<?> submitFooterSettings(
           @RequestParam("aboutUsHeaderScript") String aboutUsHeaderScript,
           @RequestParam("aboutUsBodyScript") String aboutUsBodyScript,
           @RequestParam("featureBox1HeaderScript") String featureBox1HeaderScript,
           @RequestParam("featureBox1BodyScript") String featureBox1BodyScript,
           @RequestParam("featureBox2HeaderScript") String featureBox2HeaderScript,
           @RequestParam("featureBox2BodyScript") String featureBox2BodyScript,
           @RequestParam("aboutUsImage") MultipartFile aboutUsImage,  // Updated to handle aboutUsImage
           @RequestParam("contactUsEmail") String contactUsEmail,
           @RequestParam("contactUsBodyScript") String contactUsBodyScript,
           @RequestParam("callUsPhoneNumber") String callUsPhoneNumber,
           @RequestParam("callUsBodyScript") String callUsBodyScript,
           @RequestParam("locationMapUrl") String locationMapUrl,
           @RequestParam("locationAddress") String locationAddress,
           @RequestParam("contactUsImage") MultipartFile contactUsImage,
           @RequestParam("appUrlPlaystore") String appUrlPlaystore,
           @RequestParam("appUrlAppStore") String appUrlAppStore,
           @RequestParam("copyrightInfo") String copyrightInfo
       ) {
    	   return FooterSettingsController.submitFooterSettings(aboutUsHeaderScript,aboutUsBodyScript,featureBox1HeaderScript,featureBox1BodyScript,featureBox2HeaderScript,featureBox2BodyScript,
    			   aboutUsImage,contactUsEmail,contactUsBodyScript,callUsPhoneNumber,callUsBodyScript,locationMapUrl,locationAddress,contactUsImage,appUrlPlaystore,appUrlAppStore,copyrightInfo);
       }   
	
       
//       @PostMapping("/plans")
//       public ResponseEntity<PlanDetails> getPlanById(@PathVariable Long id) {
//       return PlanDetailsController.getPlanById(id);
//       }
       @PutMapping("/planfeaturemerge")
       public ResponseEntity<List<PlanFeatureMerge>> updatePlanFeatureMerge( @RequestBody List<PlanFeatureMerge> planFeatureMerges){
    		   	return PlanFeatureMergeController.updatePlanFeatureMerge(planFeatureMerges);
}
       
       @PatchMapping("/planfeaturemerge")
       public ResponseEntity<List<PlanFeatureMerge>> patchPlanFeatureMerge(
               @RequestBody List<PlanFeatureMerge> planFeatureMerges) {
       return PlanFeatureMergeController.patchPlanFeatureMerge(planFeatureMerges);
       }
       @DeleteMapping("/planfeaturemerge")
       public ResponseEntity<HttpStatus> deleteFeaturesByPlanId(
               @RequestParam Long planId) {
       return PlanFeatureMergeController.deleteFeaturesByPlanId(planId);
       }
       

       @GetMapping("/GetFeaturesByPlanId")
       public ResponseEntity<List<PlanFeatureMerge>> getFeaturesByPlanId(@RequestParam Long planId) {
    	   return PlanFeatureMergeController.getFeaturesByPlanId(planId);
       }
       
       @PutMapping("/updateUser/{userId}")
       public ResponseEntity<?> updateUser(@PathVariable Long userId, @RequestParam("username") String username,
                                            @RequestParam("email") String email, @RequestParam("mobnum") String mobnum,
                                            @RequestParam(value = "profileImage", required = false) MultipartFile profileImage) {
    	   return ProfileImageController.updateUser(userId, username,email, mobnum,profileImage);
       }

       @PostMapping("/UploadProfileImage/{userId}")
       public ResponseEntity<?> uploadProfileImage(@PathVariable Long userId, @RequestParam("image") MultipartFile image) {
    	   return ProfileImageController.uploadProfileImage(userId,image);
       }
       @GetMapping("/GetProfileImage/{userId}")
       @ResponseBody
       public ResponseEntity<byte[]> getProfileImage(@PathVariable Long userId) {
    	   return ProfileImageController.getProfileImage(userId);
       }
	@PostMapping("/AddrazorpayId")
	public ResponseEntity<?>  Addpaymentsetting (@RequestParam("razorpay_key") String razorpay_key,
			@RequestParam("razorpay_secret_key")String razorpay_secret_key,
			@RequestHeader("Authorization") String token){
		return PaymentSettingController.Addpaymentsetting(razorpay_key, razorpay_secret_key, token);
	}
	@GetMapping("/GetPlanById/{id}")
	public ResponseEntity<PlanDetails> getPlanById(@PathVariable Long id) {
		return PlanDetailsController.getPlanById(id);
	}

	@GetMapping("/getrazorpay")
	public ResponseEntity<List<Paymentsettings>> getAllrazorpay() {

		return PaymentSettingController.getAllrazorpay();
	}

    @DeleteMapping("/plans/{planId}")
    public ResponseEntity<?> deletePlan(@PathVariable Long planId, @RequestHeader("Authorization") String token) {
    	
    	return PlanDetailsController.deletePlan(planId, token);
    }
	@PatchMapping("/Editrazorpay/{id}")
	public ResponseEntity<String> editrazorpay(@PathVariable Long id , @RequestBody Paymentsettings updatedrazorpay,
			@RequestHeader("Authorization") String token){
		return PaymentSettingController.editrazorpay(id, updatedrazorpay, token);
	}

	
	@GetMapping("/tenures")
public List<Tenure> getAllTenures()
	{
		return TenureController.getAllTenures();
	}

	 @PostMapping("/addtenure")
public Tenure createTenure( @RequestBody Tenure tenure) {
		 return TenureController.createTenure(tenure);
	 }
	 @GetMapping("/tenures/{id}")
	 public ResponseEntity<Tenure> getTenureById(@PathVariable long id){
		 return TenureController.getTenureById(id);
	 }
	 
	 @PutMapping("/edittenure/{id}")
	 public ResponseEntity<Tenure> updateTenure(@PathVariable long id,@RequestBody Tenure tenureDetails){
		 return TenureController.updateTenure(id,tenureDetails);
	 }

@DeleteMapping("/deletetenure/{id}")
public ResponseEntity<HttpStatus> deleteTenure(@PathVariable long id){
	return TenureController.deleteTenure(id);
}
	@PostMapping("/AddPlanDescription")
	public ResponseEntity<?> addPlanDescription(@RequestParam("description") String description,
	        @RequestHeader("Authorization") String token) {
		return PlanDescriptionController.addPlanDescription(description, token);
	}

	@PostMapping("/AddPlanFeature")
	public ResponseEntity<?> addPlanFeature(@RequestParam("feature") String feature,
	        @RequestHeader("Authorization") String token) {
		return FeatureController.addPlanFeature(feature, token);
	}

//	@PostMapping("/active/{id}")
//	public ResponseEntity<?> addActiveStatus(
//	        @PathVariable Long id,
//	        @RequestParam("active") String active,
//	        @RequestHeader("Authorization") String token
//	) {
//		return PlanDescriptionController.addActiveStatus(id, active, token);
//	}
	
	@DeleteMapping("/deletedesc/{id}")
	public ResponseEntity<?> deletedescription(@PathVariable Long id, @RequestHeader("Authorization") String token) {
	
		return PlanDescriptionController.deletedescription(id, token);
	}


	@PostMapping("/PlanDetails")
	public ResponseEntity<?> planDetails(@RequestParam("planname")String planname,
			@RequestParam("amount") double amount,
			@RequestParam("validity") int validity,
			@RequestHeader("Authorization") String token){

		return PlanDetailsController.planDetails(planname, amount, validity, token);
	}
	
	
	@GetMapping("/GetAllPlans")
	public ResponseEntity<List<PlanDetails>> getAllPlanDetails() {

		return PlanDetailsController.getAllPlanDetails();
	}

//
//	@DeleteMapping("/DeletePlan/{planId}")
//	public ResponseEntity<?> deletePlan(@PathVariable Long planId, @RequestHeader("Authorization") String token) {
//
//		return PlanDetailsController.deletePlan(planId, token);
//	}

	@PatchMapping("/editPlans/{planId}")
    public ResponseEntity<String> editplans(@PathVariable Long planId, @RequestBody PlanDetails updatedPlanDetails,@RequestHeader("Authorization") String token) {

		return PlanDetailsController.editplans(planId, updatedPlanDetails, token);
	}

	@PostMapping("/AddTag")
	public ResponseEntity<String> posttag(@RequestHeader("Authorization") String token,@RequestBody Tag data) {

		return TagController.posttag(token, data);
	}

	@GetMapping("/GetAllTag")
	public ResponseEntity<List<Tag>> getAllTag() {
		return TagController.getAllTag();
	}

	@GetMapping("/GetTagById/{tagId}")
	public ResponseEntity<Tag> getTagById(@PathVariable Long tagId) {

		return TagController.getTagById(tagId);
	}

	@DeleteMapping("/DeleteTag/{tagId}")
    public ResponseEntity<?> deleteTag(@PathVariable Long tagId,@RequestHeader("Authorization") String token) {

		return TagController.deleteTag(tagId, token);
	}

	@PatchMapping("/editTag/{tagId}")
	public ResponseEntity<String> editTag(@PathVariable Long tagId, @RequestBody Tag editTag,@RequestHeader("Authorization") String token) {

		return TagController.editTag(tagId, editTag, token);
	}

	@PostMapping("/save")
	public ResponseEntity<?> saveVideoCastAndCrew(@RequestParam("videoId") long videoId,
			@RequestParam("castAndCrewIds") List<Long> castAndCrewIds) {

		return VideoCastAndCrewController.saveVideoCastAndCrew(videoId, castAndCrewIds);
	}

	@GetMapping("/Getvideocast")
	public ResponseEntity<List<VideoCastAndCrew>> getAllPCastvideo() {

		return VideoCastAndCrewController.getAllPCastvideo();
	}

	@GetMapping("/GetcastvideoById/{Id}")
	public ResponseEntity<VideoCastAndCrew> getcastvideoById(@PathVariable Long Id) {

		return VideoCastAndCrewController.getcastvideoById(Id);
	}

	@GetMapping("/get/{videoId}")
	public ResponseEntity<List<VideoCastAndCrew>> getCastVideo(@PathVariable Long videoId) {

		return VideoCastAndCrewController.getCastVideo(videoId);
	}
	
	@PostMapping("/userregister")
	public ResponseEntity<?> register(
	        @RequestParam("username") String username,
	        @RequestParam("email") String email,
	        @RequestParam("password") String password,
	        @RequestParam("mobnum") String mobnum,
	        @RequestParam(value = "profile", required = false) MultipartFile profile) {
		return UserRegisterController.register(username, email, password, mobnum, profile);
	}

//	@GetMapping("/GetAllUsers")
//	public ResponseEntity<List<UserRegister>> getAllUserRegester() {
//
//		return UserRegisterController.getAllUser();
//	}
	
	@GetMapping("/GetAllUsers")
	 public ResponseEntity<List<UserRegister>> getAllUserr() {
		 return UserRegisterController.getAllUser();
	 }
	
//	@PostMapping("/send-code")
//	@Transactional
//    public ResponseEntity<String> sendCode(@RequestParam String email) {
//		return verificationcontroller.sendCode(email);
//	}
	
	@PostMapping("/send-code")
	@Transactional
	public ResponseEntity<String> sendCodewhileRegister(@RequestParam String email) {
		return verificationcontroller.sendCodewhileRegister(email);
	}
	
	@PostMapping("/send-code/forgetpassword")
	@Transactional
	 public ResponseEntity<String> sendCode(@RequestParam String email) {
		 return verificationcontroller.sendCode(email);
	 }
	
	@PostMapping("/verify-code")
    public ResponseEntity<String> verifyCode(@RequestParam String email, @RequestParam String code) {
		return verificationcontroller.verifyCode(email, code);
	}
	
	@GetMapping("/registereduserget")
	@Transactional
	public ResponseEntity<List<UserRegisterDTO>> getUsersRegisteredWithinLast15Days() {
		return UserRegisterController.getUsersRegisteredWithinLast15Days();
	}

	@GetMapping("/GetUserById/{id}")
	public ResponseEntity<UserRegister> getUserById(@PathVariable Long id) {

		return UserRegisterController.getUserById(id);
	}

	@PostMapping("/login")
	@Transactional
	public ResponseEntity<?> userlogin(@RequestBody Map<String, String> loginRequest) {
		return UserRegisterController.login(loginRequest);
	}

	@PostMapping("/logout")
	public ResponseEntity<String> logout(@RequestHeader("Authorization") String token) {

		return UserRegisterController.logout(token);
	}

	@PostMapping("/forgetPassword")
	@Transactional
	public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> loginRequest) {

		return UserRegisterController.resetPassword(loginRequest);
	}
	
	@PatchMapping("/Update/user/{userId}")
    public ResponseEntity<String> updateUserr(
            @PathVariable Long userId,
            @RequestParam(value = "username", required = false) String username,
            @RequestParam(value = "email", required = false) String email,
            @RequestParam(value = "mobnum", required = false) String mobnum,
            @RequestParam(value = "password", required = false) String password,
            @RequestParam(value = "profile", required = false) MultipartFile profile) {

    	return UserRegisterController.updateUserr(userId, username, email, mobnum, password, profile);
    }
	
	
	
	 @GetMapping("/notifications")
	 public ResponseEntity<?>GetAllNotification(@RequestHeader("Authorization") String token){
		 
		 return NotificationController.GetAllNotification(token);
	 }

	 @GetMapping("/usernotifications")
	 public ResponseEntity<?>GetuserNotification(@RequestHeader("Authorization") String token){
		 
		 return NotificationController.GetuserNotification(token);
		 
	 }
	 
	 @PostMapping("/markAllAsRead")
	    public ResponseEntity<?> markAllAsRead(@RequestHeader("Authorization") String token) {
		 
		 return NotificationController.markAllAsRead(token);
	 }
	 
	 @PostMapping("/markAllAsReaduser")
	    public ResponseEntity<?> markAllAsReaduser(@RequestHeader("Authorization") String token) {
		 
		 return NotificationController.markAllAsReaduser(token);
	 }
	 
		@GetMapping("/unreadCount")
		public ResponseEntity<?> UreadCount(@RequestHeader("Authorization") String token) {
			
			return NotificationController.UreadCount(token);
		}
		
		@GetMapping("/unreadCountuser")
		public ResponseEntity<?> UreadCountuser(@RequestHeader("Authorization") String token) {
			
			return NotificationController.UreadCountuser(token);
		}
		
		@GetMapping("/clearAll")
		public ResponseEntity<?>ClearAll(@RequestHeader("Authorization") String token){
			
			return NotificationController.ClearAll(token);
		}
		
		@GetMapping("/clearAlluser")
		public ResponseEntity<?>ClearAlluser(@RequestHeader("Authorization") String token){
			
			return NotificationController.ClearAlluser(token);
		}
		
		@PostMapping("/uploaddescription")
	    public ResponseEntity<?> uploadVideoDescription(
	    		@RequestParam("videoTitle") String videoTitle,
				@RequestParam("mainVideoDuration") String mainVideoDuration,
				@RequestParam("trailerDuration") String trailerDuration,
				@RequestParam("rating") String rating,
				 @RequestParam("language") String language,
				@RequestParam("certificateNumber") String certificateNumber,
				@RequestParam("videoAccessType") boolean videoAccessType,
				@RequestParam("description") String description,
				@RequestParam("productionCompany") String productionCompany,
				@RequestParam("certificateName") String certificateName,
				@RequestParam("castandcrewlist") List<Long> castandcrewlist,
				@RequestParam("taglist") List<Long> taglist,
				@RequestParam("categorylist") List<Long> categorylist,
				@RequestParam("videoThumbnail") MultipartFile videoThumbnail,
				@RequestParam("trailerThumbnail") MultipartFile trailerThumbnail,
				@RequestParam("userBanner") MultipartFile userBanner,
				@RequestParam("video") MultipartFile video,
		        @RequestParam("trailervideo") MultipartFile trailervideo,
		        @RequestParam("advertisementTimings") List<String> advertisementTimings,
//		        @RequestParam("date") String date, // Add this line to accept the date as a string
	            @RequestHeader("Authorization") String token){
			return VideoController.uploadVideoDescription(videoTitle, mainVideoDuration, trailerDuration, rating, language,certificateNumber, videoAccessType,
                    description, productionCompany, certificateName, castandcrewlist, taglist, categorylist,
                    videoThumbnail, trailerThumbnail, userBanner,video,trailervideo,advertisementTimings,token);
		}
		
		@GetMapping("/get/getadtiming/{id}")
		public ResponseEntity<List<Integer>> getVideoAdvertisementTiming(@PathVariable Long id) {
			return VideoController.getVideoAdvertisementTiming(id);
		}
		
		@GetMapping("/video/getall")
		public ResponseEntity<List<VideoDescription>> getAllVideo() {
			return VideoController.getAllVideo();
		}
		
		
		 @GetMapping("/GetvideoDetail/{id}")
		 public ResponseEntity<VideoDescription> getVideoDetailById(@PathVariable Long id) {			 
			 return VideoController.getVideoDetailById(id);
		 }
		 
		 
		 
		 @GetMapping("/videoimage/{id}")
		 @Transactional
		 public ResponseEntity<Map<String, byte[]>> getVideoImagesByVideoId(@PathVariable Long id) {
		 	return videoImageController.getVideoImagesByVideoId(id);
		 }
		 
		 
		 @GetMapping("/{id}/videofile")
		 public ResponseEntity<?> getVideo(@PathVariable Long id, HttpServletRequest request) {	
			return VideoController.getVideo(id, request);
		}
		 
		 @GetMapping("/{id}/dash/{filename:.+}")
		 public ResponseEntity<Resource> getVideoSegment(@PathVariable Long id, @PathVariable String filename) {
			 return VideoController.getVideoSegment(id, filename);
		 }
		
		 @GetMapping("/{id}/trailerfile")
		 public ResponseEntity<?> getVideotrailer(@PathVariable Long id, HttpServletRequest request) {
			 return VideoController.getVideotrailer(id, request);
		 }

		 @PatchMapping("/updateVideoDescription/{videoId}")
		 @Transactional
		 public ResponseEntity<?> updateVideoDescription(
				 @PathVariable("videoId") Long videoId,
		         @RequestParam(value = "videoTitle", required = false) String videoTitle,
		         @RequestParam(value = "mainVideoDuration", required = false) String mainVideoDuration,
		         @RequestParam(value = "trailerDuration", required = false) String trailerDuration,
		         @RequestParam(value = "rating", required = false) String rating,
		         @RequestParam(value= "language",required = false) String language,
		         @RequestParam(value = "certificateNumber", required = false) String certificateNumber,
		         @RequestParam(value = "videoAccessType", required = false) Boolean videoAccessType,
		         @RequestParam(value = "description", required = false) String description,
		         @RequestParam(value = "productionCompany", required = false) String productionCompany,
		         @RequestParam(value = "certificateName", required = false) String certificateName,
		         @RequestParam(value = "castandcrewlist", required = false) List<Long> castandcrewlist,
		         @RequestParam(value = "taglist", required = false) List<Long> taglist,
		         @RequestParam(value = "categorylist", required = false) List<Long> categorylist,
		         @RequestParam(value = "videoThumbnail", required = false) MultipartFile videoThumbnail,
		         @RequestParam(value = "trailerThumbnail", required = false) MultipartFile trailerThumbnail,
		         @RequestParam(value = "userBanner", required = false) MultipartFile userBanner,
		         @RequestParam(value = "video", required = false) MultipartFile video,
		         @RequestParam(value = "trailervideo", required = false) MultipartFile trailervideo,
		         @RequestParam(value = "advertisementTimings", required = false) List<String> advertisementTimings,
		         @RequestHeader("Authorization") String token) { 
			 return VideoController.updateVideoDescription(videoId,videoTitle, mainVideoDuration, trailerDuration, rating,language, certificateNumber, videoAccessType,
	                    description, productionCompany, certificateName, castandcrewlist, taglist, categorylist,
	                    videoThumbnail, trailerThumbnail, userBanner,video,trailervideo,advertisementTimings,token);
			}
		 
		 @DeleteMapping("/deletevideo/{videoId}")
		 @Transactional
		    public ResponseEntity<?> deleteVideoDescription(
		            @PathVariable("videoId") Long videoId,
		            @RequestHeader("Authorization") String token) {
		        if (videoId == null) {
		            return ResponseEntity.badRequest().body("videoId is required");
		        }
		     return VideoController.deleteVideoDescription(videoId, token);
		 }
		 
		 @DeleteMapping("/deleteMultiplevideos")
		 @Transactional
		 public ResponseEntity<?> deleteMultiplevideos(
		            @RequestHeader("Authorization") String token, 
		            @RequestBody List<Long> videoIds
		    ) {
			 return VideoController.deleteMultiplevideos(token, videoIds);
		 }
		 
		 @GetMapping("/videoscreen")
		    public ResponseEntity<VideoScreenDTO> getVideoScreenDetails(
		            @RequestParam(value = "videoId", required = false) Long videoId,
		            @RequestParam(value = "categoryId", required = false) Long categoryId) {

		        if (videoId == null || categoryId == null) {
		            return ResponseEntity.badRequest().build();
		        }
		        return VideoController.getVideoScreenDetails(videoId, categoryId);
		    }
		 @GetMapping("/access")
		 public ResponseEntity<?> getUserAccess(
		         @RequestParam(value = "userId", required = false) Long userId) {
		     if (userId == null) {
		         return ResponseEntity.badRequest().body("userId is required");
		     }
		     return VideoController.getUserAccess(userId);
		 }
		 
		 @GetMapping("/categorylist/category")
			public ResponseEntity<List<String>> getCategoryNamesByIds(@RequestParam List<Long> categoryIds) {
                  return CategoryController.getCategoryNamesByIds(categoryIds);
		 }
		 
		 @GetMapping("/castlist/castandcrew")
			public ResponseEntity<List<String>> getCastNamesByIds(@RequestParam List<Long> castIds) {
			 return  CastandcrewController.getCastNamesByIds(castIds);
		 }
		 
		 @GetMapping("/taglist/tag")
		 public ResponseEntity<List<String>> gettagNamesByIds(@RequestParam List<Long> tagIds) {
			 return  TagController.gettagNamesByIds(tagIds);
		 }


//		    @GetMapping("/{videoId}/videothumbnail")
//			 @Transactional
//		    public ResponseEntity<Map<String, byte[]>> getVideoThumbnail(@PathVariable long videoId) {
//		    	return videoImageController.getVideoThumbnail(videoId);
//		    }
		 
		 @GetMapping("/{videoId}/videothumbnail")
		 @Transactional
		 public ResponseEntity<byte[]> getVideoThumbnail(@PathVariable long videoId) {
			 return videoImageController.getVideoThumbnail(videoId);
		 }
		 
		 @GetMapping("/{videoId}/videoBanner")
		 @Transactional
		 public ResponseEntity<byte[]> getVideoBanner(@PathVariable long videoId) {
			 return videoImageController.getVideoBanner(videoId);
		 }
		    
		    @GetMapping("/images-by-category")
		    @Transactional
		    public List<Long> getVideoImagesByCategory(@RequestParam Long categoryId) {
		    	return VideoController.getVideoImagesByCategory(categoryId);
		    }
		    
		    
		    @PostMapping("/videocontainer")
			public ResponseEntity<?> createVideoContainer(@RequestBody List<VideoContainer> videoContainerRequests) {
		    	return videocontainercontroller.createVideoContainer(videoContainerRequests);
		    }
		    
		    @GetMapping("/getvideocontainers")
		    public ResponseEntity<List<VideoContainer>> getAllVideoContainers() {
		    	return videocontainercontroller.getAllVideoContainers();
		    }
		    
		    @DeleteMapping("/videocontainer/{id}")
		   	public ResponseEntity<?> Deletevideoconatiner(@PathVariable("id") long id) {
		    	return videocontainercontroller.Deletevideoconatiner(id);
		    }
		    
		    @GetMapping("/getvideocontainer")
		    public ResponseEntity<List<VideoContainerDTO>> getVideoContainersWithDetails() {
		    	return videocontainercontroller.getVideoContainersWithDetails();
		    }

		    @PostMapping("/addvideobanner")
		    public ResponseEntity<?> createVideoBanner(@RequestBody List<VideoBanner> videoBannerRequest) {
		    	return videobannercontroller.createVideoBanner(videoBannerRequest);
		    }
		    
		    @GetMapping("/getallvideobanners")
		    public ResponseEntity<List<VideoBanner>> getAllVideoBanner() {
		    	return videobannercontroller.getAllVideoBanner();
		    }
		    
		    @DeleteMapping("/videobanner/{id}")
		   	public ResponseEntity<?> Deletevideobanner(@PathVariable("id") long id) {
		    	return videobannercontroller.Deletevideobanner(id);
		    }
		    
		    //-----------------libary controller--------------------------------------
		    
		    @PostMapping("/favourite/audio")
		    public ResponseEntity<String> createOrder(@RequestBody Map<String, Long> requestData) {
		    	return librarycontroller.createOrder(requestData);
		    }
		    
		    @GetMapping("/{userId}/UserAudios")
		    public ResponseEntity<List<LikedsongsDTO>> getAudioForUsermobile(@PathVariable Long userId) {
		    	return librarycontroller.getAudioForUsermobile(userId);
		    }
		    
		    @DeleteMapping("/{userId}/removeFavoriteAudio")
		    public ResponseEntity<String> removeFavoriteAudio(@PathVariable Long userId, @RequestParam Long audioId) {
		    	return librarycontroller.removeFavoriteAudio(userId, audioId);
		    }
		    
		//  ---------------------------------watchlater----------------------------------------------
		    
		    @PostMapping("/watchlater/video")
		    public ResponseEntity<String> watchlaterVideo(@RequestBody Map<String, Long> requestData) {
		    	return librarycontroller.watchlaterVideo(requestData);
		    }
		    
		    @GetMapping("/getwatchlater/video")
		    public ResponseEntity<String> getwatchlaterVideo(@RequestParam Long videoId, @RequestParam Long userId) {
		    	return librarycontroller.getwatchlaterVideo(videoId, userId);
		    }
		    
		    @GetMapping("/{userId}/Watchlater")
		    public ResponseEntity<List<WatchLaterDTO>> getVideosForWatchlater(@PathVariable Long userId) {
		    	return librarycontroller.getVideosForWatchlater(userId);
		    }
		    
		    @DeleteMapping("/{userId}/removewatchlater")
		    public ResponseEntity<String> removeWatchlater(@PathVariable Long userId, @RequestBody Map<String, Long> payload) {
		    	return librarycontroller.removeWatchlater(userId, payload);
		    }
		    
		    //---------- playlist--------------------------------------------------------------------------
		    
		    @PostMapping("/createplaylist")
		    public ResponseEntity<Playlist> createPlaylist(
		        @RequestParam String title, @RequestParam String description,@RequestParam Long userId) {
		    	return playlistcontroller.createPlaylist(title, description, userId);
		    }

		 
		    @PostMapping("/{playlistId}/audio/{audioId}")
		    public ResponseEntity<Playlist> addAudioIdToPlaylist(
		        @PathVariable Long playlistId, @PathVariable Long audioId) {
		    	return playlistcontroller.addAudioIdToPlaylist(playlistId, audioId);
		    }
		    
		    @PostMapping("/createplaylistid")
		    public ResponseEntity<Playlist> createPlaylistwithid(
		        @RequestParam String title, 
		        @RequestParam String description,
		        @RequestParam Long audioId,
		        @RequestParam Long userId) {
		    	return playlistcontroller.createPlaylistwithid(title, description, audioId, userId);
		    }
		    
		    @GetMapping("/user/{userId}/playlists")
		    public ResponseEntity<List<Playlist>> getPlaylistsByUserId(@PathVariable Long userId) {
		    	return playlistcontroller.getPlaylistsByUserId(userId);
		    }
		    
		    
		    @GetMapping("/{Id}/playlists")
		    public ResponseEntity<Playlist> getPlaylists(@PathVariable Long Id) {
		    	return playlistcontroller.getPlaylists(Id);
		    }
		    
		    @GetMapping("/{id}/getPlaylistWithAudioDetails")
		    public ResponseEntity<List<playlistDTO>> getPlaylistWithAudioDetails(@PathVariable Long id) {
		    	return playlistcontroller.getPlaylistWithAudioDetails(id);
		    }
		    
		    @DeleteMapping("/{id}/delete/playlist")
		    public ResponseEntity<String> deletePlaylist(@PathVariable Long id) {
		    	return playlistcontroller.deletePlaylist(id);
		    }
		    
		    @DeleteMapping("/{playlistId}/audio/{audioId}/delete")
		    public ResponseEntity<Void> removeAudioFromPlaylist(@PathVariable Long playlistId, @PathVariable Long audioId) {
		    	return playlistcontroller.removeAudioFromPlaylist(playlistId, audioId);
		    }
		    
		    @PatchMapping("/editplaylist/{Id}")
		    public ResponseEntity<String> updatePlaylist(
		            @PathVariable Long Id,
		            @RequestParam(value = "title", required = false) String title,
		            @RequestParam(value = "description", required = false) String description){
		    	return playlistcontroller.updatePlaylist(Id, title, description);
		    }
		    
		    @PatchMapping("/{playlistId}/moveAudioToPlaylist/{audioId}/{movedPlaylistId}")
		    public ResponseEntity<String> moveAudioToAnotherPlaylist(
		            @PathVariable Long playlistId, 
		            @PathVariable Long audioId, 
		            @PathVariable Long movedPlaylistId) {
		    	return playlistcontroller.moveAudioToAnotherPlaylist(playlistId, audioId, movedPlaylistId);
		    }
		    
		    
		    //---------------------mailconfiguration------------------------------------
		    @PostMapping("/configuremail")
			public ResponseEntity<String> addOrUpdateMail(
			        @RequestParam(value = "mailhostname", required = false) String mailhostname,
			        @RequestParam(value = "mailportname", required = false) Integer mailportname,
			        @RequestParam(value = "emailid", required = false) String emailid,
			        @RequestParam(value = "password", required = false) String password) {
		    	return mailsettingcontroller.addOrUpdateMail(mailhostname, mailportname, emailid, password);
		    }
		    
		    
		    @GetMapping("/getmailconfig")
		    public ResponseEntity<?> getMailConfiguration() {
		    	return mailsettingcontroller.getMailConfiguration();
		    }
		    
		    @GetMapping("/test")
		    public int getMailCon()  throws Exception {
		    	 String url = "http://localhost:8010/v3/api-docs";
		         RestTemplate restTemplate = new RestTemplate();
		         String response = restTemplate.getForObject(url, String.class);
		         ObjectMapper objectMapper = new ObjectMapper();
		         JsonNode rootNode = objectMapper.readTree(response);
		         JsonNode pathsNode = rootNode.path("paths");
		         int totalApis = pathsNode.size();
		         System.out.println("Total APIs: " + totalApis);	
		    	return totalApis;
		    }
		    
			@GetMapping("/log/time/{id}")
			public ResponseEntity<?> errorSendindToMail(@PathVariable int id) {
				return logManagement.logdetails(id);
			}		    
}