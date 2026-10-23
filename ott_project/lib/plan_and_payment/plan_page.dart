import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:ott_project/pages/app_icon.dart';
import 'package:ott_project/plan_and_payment/featureList.dart';
import 'package:ott_project/plan_and_payment/payment_settings.dart';
import 'package:ott_project/plan_and_payment/plan_details.dart';
import 'package:ott_project/service/icon_service.dart';
import 'package:ott_project/service/plan_api_service.dart';
import 'package:ott_project/url.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:ott_project/service/service.dart';

import '../pages/custom_appbar.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  String selectedPlan = '';
  String selectedDuration = '';
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  AppIcon? iconData;
  List<PlanDetails> plan = [];
  late Razorpay _razorpay;
  String? razorpayKey;
  Map<String, bool> expandedState = {};
  int? _userId;
  // String baseUrl = 
  // 'https://testtomcat.vsmartengine.com/media/api/v2';
  // //'http://192.168.0.19:8010/api/v2';
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

  // double? discountedAmount;
  Map<String, Map<String, double>> discountedAmounts = {};
  @override
  void initState() {
    super.initState();
    _loadIcon();
    _loadPlans();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadUserId();
    _fetchPaymentSettings();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    _userId = await Service().getLoggedInUserId();
    setState(() {});
  }

  void _showNotification() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notification'),
          content: const Text('New song dropped! Check it out now!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadIcon() async {
    try {
      final icon = await IconService.fetchIcon();

      setState(() {
        iconData = icon;
      });
    } catch (e) {
      print('Error loading icon: $e');
    }
  }

  Future<void> _loadPlans() async {
    try {
      List<PlanDetails> fetchedplans = await PlanService.fetchPlan();
      List<Tenures> fetchedTenures = await PlanService.fetchTenures();
      List<Features> fetchedFeatures = await PlanService.fetchFeatures();
      setState(() {
        plan = fetchedplans.map((p) {
          return PlanDetails(
              id: p.id,
              planname: p.planname,
              amount: p.amount,
              tenure: fetchedTenures,
              feature: fetchedFeatures);
        }).toList();
        expandedState = {for (var plans in plan) plans.planname: false};
      });
    } catch (e) {
      print('Error loading plans: $e');
    }
  }

  //Future<void> _calculateDiscountForTenures(PlanDetails planDetails) async{}

  Future<void> _calculateDiscount(String planName, String tenureName,
      double monthlyAmount, int totalMonths, int discountedMonths) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/calculateDiscount'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'monthlyAmount': monthlyAmount,
          'totalMonths': totalMonths,
          'discountedMonths': discountedMonths,
        }),
      );
      print('ResponseDiscount:${response.statusCode}');
      if (response.statusCode == 200) {
        if(response.body.isNotEmpty){
        final discountedPrice = double.tryParse(response.body);
        if(discountedPrice != null){
        setState(() {
          discountedAmounts[planName] ??= {};
          discountedAmounts[planName]![tenureName] = discountedPrice;
        });
        }else{
          print('Invalid discount format from server.');
        }
      }else {
        print('Empty response body from server.');
      }
      }
       else {
        print('Failed to calculate discount');
      }
    } catch (e) {
      print('Error calculating discount: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error calculating discount. Please try again.')));
      // return monthlyAmount * totalMonths;
    }
    //return monthlyAmount * totalMonths;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    PlanDetails selectedPlanDetails = plan.firstWhere(
        (plan) => plan.planname == selectedPlan,
        orElse: () => PlanDetails(
            id: 0, planname: '', amount: 0, tenure: [], feature: []));
    double finalAmount = discountedAmounts[selectedPlan]?[selectedDuration] ??
        selectedPlanDetails.amount;
    Tenures selectedTenure = selectedPlanDetails.tenure.firstWhere(
      (tenure) => tenure.tenureName == selectedDuration,
      orElse: () => Tenures(id: 0, tenureName: '', months: 0, discount: 0),
    );

    await _sendPaymentDetailsToServer(
      response.orderId!,
      response.paymentId!,
      '200',
      selectedPlan,
      finalAmount,
      selectedTenure.id.toString(),
      //selectedPlanDetails.feature.toString(),
      response.signature!,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment failed: ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed:${response.message}')));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet:${response.walletName}');
  }

  Future<void> _sendPaymentDetailsToServer(
    String orderId,
    String paymentId,
    String statusCode,
    String planName,
    double amount,
    String tenureId,
    String signature,
  ) async {
    if (_userId == null) {
      print('Not logged in');
      return;
    }
    print('Sending payment details to server:');
    print('Order ID: $orderId');
    print('Payment ID: $paymentId');
    print('Status Code: $statusCode');
    print('Plan Name: $planName');
    print('Amount: $amount');
    print('User ID: $_userId');

    //final response = await http.post(url)

    final response = await http.post(
      Uri.parse('$baseUrl/confirmPayment'),
      body: jsonEncode({
        'orderId': orderId,
        'paymentId': paymentId,
        'status': statusCode,
        'planname': planName,
        'amount': amount.toInt().toString(),
        'userId': _userId.toString(),
        'tenure': tenureId,
        'signature': signature
      }),
      headers: {'Content-type': 'application/json'},
    );
    print('Amount:$amount');
    print('Amt res:${response.statusCode}');
    if (response.statusCode == 200) {
      print('Payment ID and signature sent to server');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Payment successful')));
    } else {
      print('Amount:$amount');
      print('Amt res:${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '$amount, $statusCode, $paymentId Failed to confirm payment with server')));
    }
  }

  Future<void> _fetchPaymentSettings() async {
    try {
      List<PaymentSettings> settings = await PlanService.fetchPayment();
      if (settings.isNotEmpty) {
        setState(() {
          razorpayKey = settings[0].razorpay_key;
        });
      } else {
        print('No key found');
      }
    } catch (e) {
      print('No key found: $e');
    }
  }

  void _startPayment() async {
    if (razorpayKey == null) {
      print('No razorkey found');
    }

    if (selectedPlan.isEmpty || selectedDuration.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a plan and duration')));
      return;
    }
    if (_userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User not logged in')));
      return;
    }

    PlanDetails selectedPlanDetails = plan.firstWhere(
        (plan) => plan.planname == selectedPlan,
        orElse: () => PlanDetails(
            id: 0, planname: '', amount: 0, tenure: [], feature: []));
    double amount = selectedPlanDetails.amount;
    // double amount = discountedAmounts[selectedPlan]?[selectedDuration];
    if (discountedAmounts[selectedPlan] != null &&
        discountedAmounts[selectedPlan]![selectedDuration] != null) {
      amount = discountedAmounts[selectedPlan]![selectedDuration]!;
    }
    try {
      print('Amount before sending: $amount');
      final amountInPaise = (amount).toInt();
      final userId = _userId.toString();
      final planName = selectedPlan;

      // print('Amount before sending: $amount');  // Debugging check
//final amountInPaise = (amount * 100).toInt().toString();
      print('Amount in paise before sending: $amountInPaise');

      final requestData = {
        'amount': amountInPaise,
        'userId': userId,
        'planname': planName,
      };

      print('Sending request to server with data: $requestData');

      final body = jsonEncode(requestData);

      print('JSON-encoded body: $body');

      final orderResponse = await http.post(
        Uri.parse('$baseUrl/payment'),
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      print('Status code: ${orderResponse.statusCode}');
      print('Response body: ${orderResponse.body}');

      if (orderResponse.statusCode == 200) {
        final responseBody = orderResponse.body.trim();

        if (responseBody == "Invalid data format") {
          print('Server returned an error: Invalid data format');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Server error: Invalid data format. Please check server logs.')),
          );
          return;
        }

        if (responseBody.isEmpty) {
          print('Server returned an empty response');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Server error: Empty response. Please check server logs.')),
          );
          return;
        }

        final orderId = responseBody;
        print('Order ID: $orderId');

        if (orderId.startsWith('order_')) {
          var options = {
            'key': razorpayKey,
            'amount': amountInPaise, // Amount in paise
            'name': 'Meganar',
            'order_id': orderId,
            'description': '$selectedPlan plan for $selectedDuration',
            'prefill': {
              'contact': '7339600840',
              'email': 'meganar@gmail.com',
            },
          };
          print('Opening Razorpay with options: $options');
          try {
            _razorpay.open(options);
          } catch (e) {
            print('Error opening Razorpay: ${e.toString()}');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text('Error opening payment gateway: ${e.toString()}')));
          }
        } else {
          print('Invalid order ID format: $orderId');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Failed to create payment order: Invalid order ID format')));
        }
      } else {
        print('Failed to create payment order: ${orderResponse.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Failed to create payment order: Server returned status ${orderResponse.statusCode}')));
      }
    } catch (e) {
      print('Error during HTTP request: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create payment order: ${e.toString()}')));
    }
  }

  void handleSearchState(bool isSearching, List<dynamic> results) {
    setState(() {
      _isSearching = isSearching;
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackgroundImage(),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(
                  onSearchChanged: handleSearchState,
                ),
                Divider(
                  color: Colors.white,
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height:  MediaQuery.sizeOf(context).height * 0.01,
                      ),
                      Text(
                        'Select Your Plan',
                        style: TextStyle(
                            color: kWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height:  MediaQuery.sizeOf(context).height * 0.04,
                      ),
                      ...plan.map((plans) => _buildPlanSection(plans)).toList(),
                      SizedBox(
                        height:  MediaQuery.sizeOf(context).height * 0.02,
                      ),
                      if (selectedPlan.isNotEmpty) _buildSelectedPlanDetails(),
                      SizedBox(
                        height:  MediaQuery.sizeOf(context).height * 0.02,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSection(PlanDetails plan) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 15, 19, 58),
              Color.fromARGB(48, 105, 144, 228)
            ],
          ),
          //color: Color.fromARGB(255, 15, 19, 58),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  bool iscurrentlySelected = expandedState[plan.planname]!;
                  expandedState.updateAll((key, value) => false);
                  expandedState[plan.planname] = !iscurrentlySelected;
                });
              },
              child: Padding(
                padding:
                    EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.planname,
                      style: TextStyle(
                          color: kWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    Icon(
                      expandedState[plan.planname]!
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                    ),
                    //SizedBox(height: 10,),
                  ],
                ),
              ),
            ),
            if (expandedState[plan.planname]!)
              Padding(
                padding: EdgeInsets.only(top: 0, right: 8, left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color: Colors.white,
                    ),
                    FeatureList(planId: plan.id),
                    SizedBox(height:  MediaQuery.sizeOf(context).height * 0.02),
                    Wrap(
                      runSpacing: 8.0,
                      spacing: 8.0,
                      children: plan.tenure.map((tenure) {
                        if (discountedAmounts[plan.planname] == null ||
                            discountedAmounts[plan.planname]![
                                    tenure.tenureName] ==
                                null) {
                          _calculateDiscount(plan.planname, tenure.tenureName,
                              plan.amount, tenure.months, tenure.discount);
                        }
                        double discountedPrice =
                            discountedAmounts[plan.planname]
                                    ?[tenure.tenureName] ??
                                (plan.amount * tenure.months);
                        return FractionallySizedBox(
                            widthFactor: 0.48,
                            child: _buildDurationButton(
                              tenure.tenureName,
                              discountedPrice,
                              plan.planname,
                            ));
                      }).toList(),
                    ),
                    SizedBox(height:  MediaQuery.sizeOf(context).height * 0.02),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationButton(String tenure, double price, String planName) {
    bool isSelected = selectedPlan == planName && selectedDuration == tenure;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = planName;
          selectedDuration = tenure;
        });
      },
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(62, 35, 118, 1),
                Color.fromARGB(255, 10, 3, 13)
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border:
                isSelected ? Border.all(color: Colors.white, width: 0.6) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ]),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tenure,
                  style: const TextStyle(color: Colors.white),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
            Text(
              'Rs: $price',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPlanDetails() {
    // PlanDetails? selectedPlanDetails = plan.firstWhere(
    //     (plan) => plan.planname == selectedPlan,
    //     orElse: () => PlanDetails(
    //         id: 0, planname: '', amount: 0, tenure: [], feature: []));
    // Tenures selectedTenure = selectedPlanDetails.tenure.firstWhere(
    //     (tenure) => tenure.tenureName == selectedDuration,
    //     orElse: () => Tenures(id: 0, tenureName: '', months: 0, discount: 0));
    double? discountedPrice =
        discountedAmounts[selectedPlan]?[selectedDuration];
    return Column(
      children: [
        SizedBox(
          height:  MediaQuery.sizeOf(context).height * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                'Rs: ${discountedPrice != null ? discountedPrice.toStringAsFixed(2) : "Calculating..."}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: _startPayment,
              child: Text(
                'Continue',
                style: TextStyle(color: kWhite),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 127, 21, 193),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            )
          ],
        ),
        SizedBox(
          height:  MediaQuery.sizeOf(context).height * 0.01,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '$selectedPlan plan x $selectedDuration',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
