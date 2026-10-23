import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:ott_project/components/banners/audio_banner.dart';
import 'package:ott_project/components/music_folder/audio.dart';
import 'package:ott_project/tv_ui/banner/audiobanner.dart';
import 'package:ott_project/url.dart';
import 'dart:convert';


import '../components/music_folder/audio_container.dart';
import '../components/music_folder/music.dart';

class AudioApiService with ChangeNotifier {
  //static const String baseUrl =
    //'https://mjdemotomcat.vsmartengine.com/media/api/v2';
   //'https://testtomcat.vsmartengine.com/media/api/v2';
  // 'http://localhost:8080/api/v2';
   //'http://192.168.0.19:8010/api/v2';

  Future<Audio> fetchAudioDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/audio/$id'));

    //print(response.statusCode);
    if (response.statusCode == 200) {
      return Audio.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load audio details');
    }
  }

  Future<Music> fetchMusicDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/getaudio/$id'));

    //print(response.statusCode);
    if (response.statusCode == 200) {
      //   print('Response Audio:${response.body}');
      return Music.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load audio details');
    }
  }

  Future<AudioDescription> fetchAudioDetails(int id) async{
    final response = await http.get(Uri.parse('$baseUrl/getaudio/$id'));
    //print('Fetch Audiodescription Response:${response.statusCode}');
    //print('Fetch Audiodescription:${response.body}');
    if(response.statusCode == 200){

      var jsonResponse = jsonDecode(response.body);
      //print('Decoded JSon:$jsonResponse');
        return AudioDescription.fromJson(jsonResponse);
    }else {
      throw Exception('Failed to load audio details');
    }
  }

Future<String> fetchAudioStreamUrl(String fileName) async {
  final url = '$baseUrl/$fileName/file';
  final response = await http.get(Uri.parse(url));

  print('Fetching audio stream: $url');
  print('Response Status Code: ${response.statusCode}');
  print('Response Headers: ${response.headers}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 206 || response.statusCode == 200) {
    return url;
  } else {
    throw Exception('Failed to load audio stream. Status: ${response.statusCode}');
  }
}

 // Fetch banner image
  Future<Uint8List?> fetchMusicBanner(int movienameID) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getimage/banner/$movienameID'));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load banner image');
      }
    } catch (e) {
      print('Error fetching banner image: $e');
      return null;
    }
  }


  Future<bool> likeAudio(int audioId, int userId) async {
    final url = Uri.parse('$baseUrl/favourite/audio');

    print('Sending request to: $url');
  print('Sending audioId: $audioId, userId: $userId');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'audioId': audioId, 'userId': userId}));
    print('Like response:${response.statusCode}');
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error liking audio:${response.body}');
      return false;
    }
  }

  Future<List<int>> getLikedSongs(int userId) async {
    final url = Uri.parse('$baseUrl/$userId/UserAudios');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> likedAudiosJson = jsonDecode(response.body);
        print('LikedSongs:$likedAudiosJson');

      return likedAudiosJson.map((audio) => audio['audioId'] as int).toList();

      //return likedAudiosJson.map((audio) => audio['id'].toString()).toList();
    } else {
      throw Exception('Failed to load liked songs');
    }
  }

   Future<bool> unlikeAudio(int audioId, int userId) async {
    final url = Uri.parse(
        '$baseUrl/$userId/removeFavoriteAudio?audioId=$audioId');
    final response = await http.delete(url);
    print(response.statusCode);
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error in unlike:${response.statusCode}-${response.body}');
      return false;
    }
  }


Future<Map<String, dynamic>> fetchCategoryInfo(int id) async {
  final response = await http.get(Uri.parse('$baseUrl/getaudio/$id'));
  print('Fetch AudioDetails Response: ${response.statusCode}');
  print('Fetch AudioDetails Body: ${response.body}');

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse.containsKey('category') && jsonResponse['category'] is List) {
      final categoryList = jsonResponse['category'] as List;

      if (categoryList.isNotEmpty) {
        final category = categoryList[0];
        final categoryId = category['category_id'];
        final categoryName = category['categories'];

        return {
          'categoryId': categoryId,
          'categoryName': categoryName,
          'audioDescription': AudioDescription.fromJson(jsonResponse), // optional
        };
      }
    }
    throw Exception('Category not found in audio');
  } else {
    throw Exception('Failed to load audio details');
  }
}



 
 // get all banner
   Future<List<AudioBanner>> fetchAllAudioBanner() async{
    try{
      final response = await http.get(Uri.parse('$baseUrl/getallaudiobanner'));
      print('audio all Banners:${response.statusCode}');
      if(response.statusCode == 200){
        final List<dynamic> audiojson = jsonDecode(response.body);
        return audiojson.map((data)=> AudioBanner.fromJson(data)).toList();
      }else{
        throw Exception('Falied to load audio banners:${response.statusCode}');
      }
    }catch (e) {
    print('Error fetching audio banners: $e');
    throw Exception('Failed to fetch audio banners');
  }
   }
   // get all banner
   Future<List<AudioBannerTV>> fetchAllAudioBannerTV() async{
    try{
      final response = await http.get(Uri.parse('$baseUrl/getallaudiobanner'));
      print('audio all Banners:${response.statusCode}');
      if(response.statusCode == 200){
        final List<dynamic> audiojson = jsonDecode(response.body);
        return audiojson.map((data)=> AudioBannerTV.fromJson(data)).toList();
      }else{
        throw Exception('Falied to load audio banners:${response.statusCode}');
      }
    }catch (e) {
    print('Error fetching audio banners: $e');
    throw Exception('Failed to fetch audio banners');
  }
   }

 
}
