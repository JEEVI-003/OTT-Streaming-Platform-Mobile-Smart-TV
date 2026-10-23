import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ott_project/components/library/watch_later.dart';
import 'package:ott_project/url.dart';
import 'package:ott_project/components/video_folder/movie.dart';
class WatchLaterService {

  //  static const String baseUrl =
  //   //'https://mjdemotomcat.vsmartengine.com/media/api/v2';
  // // 'https://testtomcat.vsmartengine.com/media/api/v2';
  //  //   'http://localhost:8080/api/v2';  
  //    'http://192.168.0.19:8010/api/v2';


  Future<void> addToWatchLater(int videoId,int userId) async{
    final url = Uri.parse('$baseUrl/watchlater/video');
    print('Sending request to: $url');
  print('Sending audioId: $videoId, userId: $userId');

  final response = await http.post(url,
    headers:{'Content-Type': 'application/json'},
    body: jsonEncode({'videoId': videoId, 'userId' : userId})
  );
    if (response.statusCode == 200) {
     print('Video added to watch later: ${response.body}');
     
    } else {
      print('Error liking audio:${response.body}');
    
    }
  }

  Future<List<WatchLater>> getWatchLaterVideos(int userId) async{
    final response = await http.get(Uri.parse('$baseUrl/$userId/Watchlater'));
  
    if(response.statusCode == 200){
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item)=> WatchLater.fromJson(item)).toList();
    }else{
      throw Exception('Failed to load watch later movies');
    }
  }

  Future<bool> isInWatchList(int videoId, int userId) async {
  try {
      List<WatchLater> watchLaterVideos = await getWatchLaterVideos(userId);
    for (var video in watchLaterVideos) {
      if (video.videoId == videoId) {
        return true; 
      }
    }

    return false; 
  } catch (e) {
    print('Error checking watchlist: $e');
    return false; 
  }
}

  Future<String> removeWatchLater(int videoId, int userId) async{
    final response = await http.delete( Uri.parse('$baseUrl/$userId/removewatchlater'),
    headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'videoId': videoId}),
    );
     if (response.statusCode == 200) {
      return 'Video removed from watch later successfully';
    } else if (response.statusCode == 400) {
      return 'Failed to remove video: ${response.body}';
    } else {
      throw Exception('Failed to remove video');
    }
  }
  }

