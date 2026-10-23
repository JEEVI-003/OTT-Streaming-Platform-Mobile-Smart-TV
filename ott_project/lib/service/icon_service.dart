import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:ott_project/pages/app_icon.dart';
import 'package:ott_project/url.dart';

class IconService {
  // static const String baseUrl =
  //       'https://testtomcat.vsmartengine.com/media/api/v2';
  //   'http://localhost:8080/api/v2';
  //  'http://192.168.0.19:8010/api/v2';

  static Future<AppIcon> fetchIcon() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/GetsiteSettings'));
      print(response.statusCode);
      //print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          String icon = (jsonResponse[0]['icon']);
          return AppIcon(icon: icon);
        } else {
          throw Exception('Empty response');
        }
      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to load icon: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on HttpException {
      throw Exception("Couldn't find the post");
    } on FormatException {
      throw Exception("Bad response format");
    }
  }
}
