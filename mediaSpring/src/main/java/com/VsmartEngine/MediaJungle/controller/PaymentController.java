
package com.VsmartEngine.MediaJungle.controller;


import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.VsmartEngine.MediaJungle.Container.VideoContainerController;
import com.VsmartEngine.MediaJungle.model.PaymentUser;
import com.VsmartEngine.MediaJungle.model.Paymentsettings;
import com.VsmartEngine.MediaJungle.repository.PaymentRepository;
import com.VsmartEngine.MediaJungle.repository.PaymentsettingRepository;
import com.VsmartEngine.MediaJungle.service.UserService;
import com.VsmartEngine.MediaJungle.userregister.UserRegister;
import com.VsmartEngine.MediaJungle.userregister.UserRegisterRepository;
import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;

@RestController
@RequestMapping("/api/v2/")
@CrossOrigin(origins = "*")
public class PaymentController {

    @Value("${rzp_currency}")
    private String currency;
    
    @Autowired
    private PaymentRepository paymentrepository;
   
    @Autowired
    private UserRegisterRepository userregisterrepository;
    
    @Autowired
    private PaymentsettingRepository paymentsettingrepository;
    
//    @Autowired
//    private PaymentUser PaymentUser;
    
    private static final Logger logger = LoggerFactory.getLogger(PaymentController.class);


    public ResponseEntity<List<PaymentUser>> getPaymentHistory(@PathVariable Long userId) {
        try {
            List<PaymentUser> paymentHistory = paymentrepository.findUserByUserId(userId);
            if (paymentHistory.isEmpty()) {
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            }
            return new ResponseEntity<>(paymentHistory, HttpStatus.OK);
        } catch (Exception e) {
            e.printStackTrace(); // Log the exception
            logger.error("", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
 
    public ResponseEntity<Map<String, String>> confirmPayment(@RequestBody Map<String, String> requestData) {
        Map<String, String> response = new HashMap<>(); // Create a response map
        try {
            // Log received data for debugging
            System.out.println("Received payment data: " + requestData);
            
            // Extract data from the request
            String paymentId = requestData.get("paymentId");
            String orderId = requestData.get("orderId");
            int statusCode = Integer.parseInt(requestData.get("status")); // Parse as int
            String subscriptionTitle = requestData.get("planname");
            Long amount = Long.parseLong(requestData.get("amount"));
            Long userId = Long.parseLong(requestData.get("userId"));
            int tenure = Integer.parseInt(requestData.get("tenure"));

            // Validate the received payment information
            boolean isPaymentSuccessful = checkIfPaymentIsSuccessful(statusCode);
            String finalStatus = isPaymentSuccessful ? "success" : "failed"; 
            System.out.println("Payment Status: " + finalStatus);
            Optional<UserRegister> userOption = userregisterrepository.findById(userId);
            // Check if the user exists and retrieve their payment details
            Optional<PaymentUser> paymentUserOptional = paymentrepository.findByUserId(userId);
            if (paymentUserOptional.isPresent()) {
                PaymentUser paymentUser = paymentUserOptional.get();
                System.out.println("If1 Part");
              
                // Check if the payment has expired
                if (paymentUser.getExpiryDate().isBefore(LocalDate.now())) {
                	  System.out.println("If2");
                    // Payment expired, update with new payment details
                    paymentUser.setPaymentId(paymentId);
                    paymentUser.setOrderId(orderId);
                    paymentUser.setStatus(finalStatus);
                    paymentUser.setSubscriptionTitle(subscriptionTitle);
                    paymentUser.setAmount(amount);
                    paymentUser.setUserId(userId);
                    paymentUser.setExpiryDate(LocalDate.now().plusMonths(tenure)); // Update expiry date

                    // Save updated payment details
                    paymentrepository.save(paymentUser);
                    UserRegister user = new UserRegister();
                    System.out.println(paymentUser.getId());
                    System.out.println(paymentUser);
                    Optional<UserRegister> useroption = userregisterrepository.findById(userId);
                    UserRegister user1 = useroption.get();
                    user1.setPaymentId(paymentUser);
                    userregisterrepository.save(user1);
                    response.put("message", "Payment confirmed successfully");
                    return new ResponseEntity<>(response, HttpStatus.OK);
                } else {
                    // Payment is still active
                	  System.out.println("else1");
                    response.put("message", "You already have an active payment. Please wait until it expires or upgrade.");
                    return new ResponseEntity<>(response, HttpStatus.CONFLICT);
                }
            } else {
                // Create a new payment entry
                PaymentUser paymentUser = new PaymentUser();
                paymentUser.setPaymentId(paymentId);
                paymentUser.setOrderId(orderId);
                paymentUser.setStatus(finalStatus);
                paymentUser.setSubscriptionTitle(subscriptionTitle);
                paymentUser.setAmount(amount);
                paymentUser.setUserId(userId);
                paymentUser.setExpiryDate(LocalDate.now().plusMonths(tenure)); // Set expiry date

                // Save the new payment details
                paymentrepository.save(paymentUser);
                UserRegister user = new UserRegister();
                System.out.println("Els2");
                System.out.println(paymentUser);
                Optional<UserRegister> useroption = userregisterrepository.findById(userId);
                UserRegister user1 = useroption.get();
                user1.setPaymentId(paymentUser);
                userregisterrepository.save(user1);
                response.put("message", "Payment confirmed successfully");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
        } catch (NumberFormatException e) {
            response.put("message", "Invalid number format");
            logger.error("", e);
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("", e);
            response.put("message", "An error occurred while confirming the payment");
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    // Helper method to determine payment success based on statusCode
    private boolean checkIfPaymentIsSuccessful(int statusCode) {
        // Check if the status code is 200 (HTTP OK)
        return statusCode == 200;
    }

    public String Payment(@RequestBody Map<String, String> requestData) {
        try {
            Long amount = Long.parseLong(requestData.get("amount"));
            Long userId = Long.parseLong(requestData.get("userId"));
            String planName = requestData.get("planname");
            System.out.println(":::::::::::::::::::FSDFASDFASDF::::::::::::::::::::" +requestData);
            Optional<PaymentUser> optionPayment = paymentrepository.findByUserId(userId);
            Optional<UserRegister> userOption = userregisterrepository.findById(userId);

            if (userOption.isPresent()) {
            	   UserRegister user = userOption.get(); // Get the user object
                
                // Check if the user has an existing payment
                if (optionPayment.isPresent()){
                    PaymentUser paym = optionPayment.get();
                    
                    // Check if the existing payment is still valid
                    if (paym.getExpiryDate().isAfter(LocalDate.now()) && 
                            paym.getPaymentId() != null && 
                            "success".equalsIgnoreCase(paym.getStatus())) { // Safe null check
                            return "You have already paid for the plan. Your subscription is valid until " + paym.getExpiryDate();
                        }
                }

                // Fetch Razorpay keys from the payment settings repository
                Optional<Paymentsettings> paymentSettingOptional = paymentsettingrepository.findById(1L); // Adjust ID as needed
                if (!paymentSettingOptional.isPresent()) {
                    return "Payment settings not found";
                }

                Paymentsettings paymentSetting = paymentSettingOptional.get();
                String razorpayApiKey = paymentSetting.getRazorpay_key();
                String razorpayApiSecret = paymentSetting.getRazorpay_secret_key();

                // Create a new Razorpay order
                RazorpayClient client = new RazorpayClient(razorpayApiKey, razorpayApiSecret);
                JSONObject orderRequest = new JSONObject();
                orderRequest.put("amount", amount * 100); // Convert amount to paisa
                orderRequest.put("currency", "INR");
                orderRequest.put("notes", new JSONObject().put("user_id", userId));
                Order order = client.orders.create(orderRequest);

                String orderId = order.get("id").toString();
                
//                // Save or update payment details
//                PaymentUser payment;
//                if (optionPayment.isPresent()) {
//                    payment = optionPayment.get();
//                } else {
//                    payment = new PaymentUser();
//                    payment.setUserId(userId);
//                }
//                payment.setOrderId(orderId);
//                payment.setSubscriptionTitle(planName);
//                payment.setExpiryDate(LocalDate.now().plusMonths(1)); // Assuming 1-month subscription
////                paymentrepository.save(payment);

//              Save or update payment details
//                PaymentUser payment = optionPayment.orElseGet(() -> {
//                    PaymentUser newPayment = new PaymentUser();
//                    newPayment.setUserId(userId);
//                    return newPayment;
//                });
//
//                payment.setOrderId(orderId);
//                payment.setSubscriptionTitle(planName);
//                payment.setExpiryDate(LocalDate.now().plusMonths(1)); // Assuming 1-month subscription
//
//                paymentrepository.save(payment);

                return orderId;
            } else {
                // Return an error response if the user is not found
                return "User not found";
            }
        } catch (NumberFormatException e) {
        	logger.error("", e);
            return "Invalid data format";
        } catch (RazorpayException e) {
        	logger.error("", e);
            e.printStackTrace();
            return "Error creating order: " + e.getMessage();
        } catch (Exception e) {
        	logger.error("", e);
            e.printStackTrace();
            return "Error creating order: " + e.getMessage();
        }
    }

    @Autowired
    private UserService userService;

    public ResponseEntity<Map<String, String>> getPlanDetailsByUserId(@PathVariable Long userId) {
        String plan = userService.getPlanDetailsByUserId(userId); // Get the plan details as a string

        // Wrap the plan details in a JSON object
        Map<String, String> response = new HashMap<>();
        response.put("planName", plan);

        return ResponseEntity.ok(response); // Return the JSON object
    }

//
//    public ResponseEntity<String> updatePaymentd(@RequestBody Map<String, String> requestData) {
//        try {
//            String orderId = requestData.get("orderId");
//            String paymentId = requestData.get("paymentId");
//            String planname = requestData.get("planname");
//            int validityDays = Integer.parseInt(requestData.get("validity"));
//            long userid = Long.parseLong(requestData.get("userId"));
//
//            // Fetch Razorpay keys from the payment settings repository
//            Optional<Paymentsettings> paymentSettingOptional = paymentsettingrepository.findById(1L); // Adjust ID as needed
//            if (!paymentSettingOptional.isPresent()) {
//                return new ResponseEntity<>("Payment settings not found", HttpStatus.NOT_FOUND);
//            }
//            
//            Paymentsettings paymentSetting = paymentSettingOptional.get();
//            String razorpayApiKey = paymentSetting.getRazorpay_key();
//            String razorpayApiSecret = paymentSetting.getRazorpay_secret_key();
//
//            RazorpayClient client = new RazorpayClient(razorpayApiKey, razorpayApiSecret);
//
//            // Fetch order details from Razorpay
//            Order detailedOrder = client.orders.fetch(orderId);
//            String amountPaidString = detailedOrder.get("amount_paid").toString();
//            Long amountPaidIn = Long.parseLong(amountPaidString) / 100;
//            String status = detailedOrder.get("status").toString();
//            System.out.println(detailedOrder);
//
//            Optional<PaymentUser> paym = paymentrepository.findByUserId(userid);
//            Optional<UserRegister> useroption = userregisterrepository.findById(userid);
//
//            LocalDate currentDate = LocalDate.now();
//            LocalDate expiryDate = currentDate.plusDays(validityDays);
//
//            Optional<PaymentUser> orderUserOptional = paymentrepository.findByOrderId(orderId);
//            if (orderUserOptional.isPresent()) {
//                PaymentUser pay = orderUserOptional.get();
//                pay.setPaymentId(paymentId);
//                pay.setAmount(amountPaidIn);
//                pay.setSubscriptionTitle(planname);
//                pay.setStatus(status);
//                pay.setExpiryDate(expiryDate);
//                paymentrepository.save(pay);
//                
//                
//                if (useroption.isPresent()) {
//                    UserRegister user = useroption.get();
//                    PaymentUser p = paym.orElseThrow(() -> new RuntimeException("PaymentUser not found"));
//
//                    if (status.equals("paid")) { 
//                        user.setPaymentId(p);
//                        userregisterrepository.save(user);
//                    }
//                } else {
//                    return new ResponseEntity<>("User not found", HttpStatus.NOT_FOUND);
//                }
//
//                // Return a success response with the userId
//                return new ResponseEntity<>("Payment ID updated successfully for user ID: " + userid, HttpStatus.OK);
//            } else {
//                return new ResponseEntity<>("Order ID not found", HttpStatus.NOT_FOUND);
//            }
//        } catch (NumberFormatException e) {
//            return new ResponseEntity<>("Invalid number format", HttpStatus.BAD_REQUEST);
//        } catch (Exception e) {
//            // Log the exception (use a logger in real applications)
//            e.printStackTrace();
//            return new ResponseEntity<>("An error occurred while updating the payment ID", HttpStatus.INTERNAL_SERVER_ERROR);
//        }
//    }
}
    
