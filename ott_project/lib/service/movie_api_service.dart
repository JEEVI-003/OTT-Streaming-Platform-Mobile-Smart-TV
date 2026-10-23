import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:ott_project/components/banners/video_banner.dart';
import 'package:ott_project/components/video_folder/cast_crew.dart';
import 'package:ott_project/components/video_folder/category.dart';
import 'dart:convert';

import 'package:ott_project/components/video_folder/movie.dart';
import 'package:ott_project/components/video_folder/video_container.dart';
import 'package:ott_project/url.dart';

class MovieApiService {

  Future<Movie> fetchVideoDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/GetvideoDetail/$id'));

    print(response.statusCode);
    if (response.statusCode == 200) {
      return Movie.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load video details');
    }
  }

  Future<Movies> fetchVideoDetails(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/GetvideoDetail/$id'));

    print(response.statusCode);
    if (response.statusCode == 200) {
      return Movies.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load video details');
    }
  }

  Future<VideoDescription> fetchMovieDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/GetvideoDetail/$id'));

    print(response.statusCode);
    if (response.statusCode == 200) {
      return VideoDescription.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load video details');
    }
  }

  /// FIX — BUG-A:
  /// The old implementation used http.GET which caused Spring Boot's streaming
  /// controller to serve the first 5 MB chunk into Flutter's memory.
  /// ExoPlayer then tried to open the same URL independently, got a confused
  /// server state, and threw "Source error, null".
  ///
  /// Fix: Use http.HEAD for validation only (no body downloaded).
  /// ExoPlayer handles all Range/206 negotiation by itself once given the URL.
  Future<String> fetchVideoStreamUrl(int id) async {
    final url = '$baseUrl/$id/videofile';
    try {
      // HEAD request — validates the endpoint exists without downloading a body.
      final response = await http.head(Uri.parse(url));
      print('Stream HEAD status: ${response.statusCode}');
      if (response.statusCode == 200 ||
          response.statusCode == 206 ||
          response.statusCode == 405) {
        // 405 = Method Not Allowed for HEAD but endpoint exists — still usable.
        return url;
      } else {
        throw Exception('Stream endpoint returned ${response.statusCode}');
      }
    } catch (_) {
      // If HEAD is not supported by the server at all, return URL directly
      // and let ExoPlayer determine validity on its own.
      return url;
    }
  }

  Future<VideoDescription> fetchVideoScreenDetails(
      int videoId, int categoryId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/videoscreen?videoId=$videoId&categoryId=$categoryId'));
    print('Response:${response.statusCode}');
    print('Response: ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      List<VideoDescription> videoDescriptions =
          (jsonResponse['videoDescriptions'] as List)
              .map((item) => VideoDescription.fromJson(item))
              .toList();

      try {
        return videoDescriptions.firstWhere(
          (video) => video.id == videoId,
          orElse: () => throw Exception('Video not found'),
        );
      } catch (e) {
        throw Exception('Failed to find video with ID: $videoId');
      }
    } else {
      throw Exception('Failed to load video screen details');
    }
  }

  /// Fetch a single banner image as bytes.
  static Future<Uint8List?> fetchVideoBannerImage(int videoId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/$videoId/videoBanner'));
      print('Video banner:${response.statusCode}');
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print("Error fetching banner for movie $videoId: $e");
      return null;
    }
    return null;
  }

  Future<List<VideoBanner>> fetchAllVideoBanner() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/getallvideobanners'));
      print('Video all Banners:${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> videojson = jsonDecode(response.body);
        return videojson.map((data) => VideoBanner.fromJson(data)).toList();
      } else {
        throw Exception(
            'Failed to load video banners:${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching video banners: $e');
      throw Exception('Failed to fetch video banners');
    }
  }

  Future<List<CastCrew>> fetchCastAndCrew(List<int> castIds) async {
    List<CastCrew> castList = [];
    for (var id in castIds) {
      try {
        final response =
            await http.get(Uri.parse('$baseUrl/getcast/$id'));

        if (response.statusCode == 200) {
          final Map<String, dynamic> castDetails =
              jsonDecode(response.body);

          Uint8List? image = await fetchCastAndCrewImage(id);

          CastCrew member = CastCrew(
              name: castDetails['name'] ?? 'Unknown',
              id: castDetails['id'],
              image: image);

          castList.add(member);
        } else {
          print(
              'Failed to load cast details for ID $id: ${response.statusCode}');
          castList.add(CastCrew(name: 'Cast Member', id: id));
        }
      } catch (e) {
        print('Error fetching cast member $id: $e');
        castList.add(CastCrew(name: 'Cast Member', id: id));
      }
    }
    return castList;
  }

  Future<Uint8List?> fetchCastAndCrewImage(int castId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/getcastimage/$castId'));
      print('CastImage: ${response.statusCode}');
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print('Error fetching cast image $castId: $e');
    }
    return null;
  }

  static Future<List<Category>> fetchCategories() async {
    final response =
        await http.get(Uri.parse('$baseUrl/GetAllCategories'));
    if (response.statusCode == 200) {
      print('Categories :${response.body}');
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Categories');
    }
  }

  static Future<List<VideoDescription>> fetchMoviesByCategory(
      int categoryId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/GetCategoryById/$categoryId'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('Categorize movie: ${response.body}');
      var body = jsonDecode(response.body);
      VideoContainer videoContainer = VideoContainer.fromJson(body);
      return videoContainer.videoDescriptions;
    } else {
      throw Exception("Failed to load movies by category");
    }
  }
}