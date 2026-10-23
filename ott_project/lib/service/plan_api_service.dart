import 'dart:convert';
import 'package:ott_project/plan_and_payment/payment_settings.dart';
import 'package:ott_project/plan_and_payment/plan_details.dart';
import 'package:http/http.dart' as http;
import 'package:ott_project/url.dart';

class PlanService {
  //  static const String baseUrl =
  //   // 'https://mjdemotomcat.vsmartengine.com/media/api/v2';
  //   //   'http://localhost:8080/api/v2';
  //  'http://192.168.0.19:8010/api/v2';
  // //'http://192.168.40.165:8080/api/v2';

  static Future<List<PlanDetails>> fetchPlan() async {
    final response = await http.get(Uri.parse('$baseUrl/GetAllPlans'));
    // print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);

      return body.map((dynamic plan) {
        return PlanDetails.fromJson(plan);
      }).toList();
    } else {
      throw Exception("Failed to fetch plans");
    }
  }

  static Future<List<Tenures>> fetchTenures() async {
    final response = await http.get(Uri.parse('$baseUrl/tenures'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);

      return body.map((dynamic tenure) {
        return Tenures.fromJson(tenure);
      }).toList();
    } else {
      throw Exception("Failed to fetch tenures");
    }
  }

  static Future<List<Features>> fetchFeatures() async {
    final response = await http.get(Uri.parse('$baseUrl/GetAllFeatures'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      print('All features response: $body');

      return body.map((dynamic feature) {
        return Features.fromJson(feature);
      }).toList();
    } else {
      throw Exception("Failed to fetch feature");
    }
  }

  static Future<Map<int, String>> getFeatureIdToNameMap() async {
    List<Features> allFeatures = await fetchFeatures();

    print(
        'ID to Name Map: ${allFeatures.map((f) => '${f.id}: ${f.featureName}').toList()}');

    return {for (var feature in allFeatures) feature.id: feature.featureName};
  }

  static Future<List<Features>> fetchFeaturesByPlanId(int planId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/GetFeaturesByPlanId?planId=$planId'));

    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      print('Features API Response: ${response.body}');
      List<Features> features = body.map((dynamic feature) {
        return Features.fromPlanJson(feature);
      }).toList();

      List<Features> activeFeatures =
          features.where((feature) => feature.active == true).toList();
      Map<int, String> idToNameMap = await getFeatureIdToNameMap();
      print('ID to Name Map: $idToNameMap');
      return features.map((feature) {
        return Features(
          id: feature.id,
          featureName:
              idToNameMap[feature.featureId ?? feature.id] ?? 'Unknown',
          active: feature.active,
          isActiveForPlan: activeFeatures.any((f) => f.id == feature.id),
        );
      }).toList();
      // List<dynamic> body = jsonDecode(response.body);

      // return body.map((dynamic feature) {
      //   return Features.fromJson(feature);
      // }).toList();
    } else {
      throw Exception("Failed to fetch features for plan");
    }
  }

  static Future<List<PaymentSettings>> fetchPayment() async {
    final response = await http.get(Uri.parse('$baseUrl/getrazorpay'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);

      return body.map((data) {
        return PaymentSettings.fromJson(data);
      }).toList();
    } else {
      throw Exception("Failed to fetch payment key");
    }
  }
}
