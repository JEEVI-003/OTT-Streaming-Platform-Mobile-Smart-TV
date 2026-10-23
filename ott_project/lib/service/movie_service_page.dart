import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:ott_project/components/video_folder/category.dart';
import 'package:ott_project/components/video_folder/movie.dart';
import 'package:ott_project/components/video_folder/video_container.dart';
import 'package:ott_project/tv_ui/banner/moviebanner.dart';
import 'package:ott_project/url.dart';

class MovieService {
  //  static const String baseUrl =
  //   //    'https://mjdemotomcat.vsmartengine.com/media/api/v2';
  //  // 'https://testtomcat.vsmartengine.com/media/api/v2';
  //   // 'http://localhost:8080/api/v2';
  // 'http://192.168.0.19:8010/api/v2';

  static Future<List<Movie>> fetchMovies() async {
    final response = await http.get(Uri.parse('$baseUrl/video/getall'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((video) {
        return Movie.fromJson(video);
      }).toList();
    } else {
      throw Exception("Failed to load movies");
    }
  }

  static Future<List<VideoBanner>> fetchAllVideoBanners() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/getallvideobanners'));
      print('Video all Banners: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> videoJson = jsonDecode(response.body);
        return videoJson.map((data) => VideoBanner.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load video banners');
      }
    } catch (e) {
      print('Error fetching video banners: $e');
      return [];
    }
  }

  static Future<VideoDescription> fetchMovieDetail(int id) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/GetvideoDetail/$id'));
      print(response.statusCode);
      if (response.statusCode == 200) {
        return VideoDescription.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load video details');
      }
    } catch (e) {
      print("Error fetching movie details: $e");
      rethrow;
    }
  }

  static Future<Uint8List?> fetchVideoBannerImage(int videoId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/$videoId/videoBanner'));
      print('Video banner: ${response.statusCode}');
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print("Error fetching banner for movie $videoId: $e");
    }
    return null;
  }

  static Future<List<Movies>> fetchVideos() async {
    final response = await http.get(Uri.parse('$baseUrl/video/getall'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      print('Videos:${response.body}');
      return body.map((video) {
        return Movies.fromJson(video);
      }).toList();
    } else {
      throw Exception("Failed to load movies");
    }
  }

  static Future<List<VideoContainer>> fetchVideoContainer() async {
    final response =
        await http.get(Uri.parse('$baseUrl/getvideocontainer'));

    print('Video container response: ${response.statusCode}');
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body
          .map((container) => VideoContainer.fromJson(container))
          .toList();
    } else {
      throw Exception("Failed to load video containers");
    }
  }

  
  // -----------------------------------------------------------------------
  static Future<String> fetchVideoStreamUrl(int id) async {
    // Simply return the streaming endpoint URL.
    // ExoPlayer (used internally by the video_player plugin) will open this
    // URL itself, send the correct Range headers, and handle HTTP 206
    // Partial Content responses entirely on its own.
    return '$baseUrl/$id/videofile';
  }

  static Future<Uint8List?> fetchvideoImage(int videoId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/$videoId/videothumbnail'));
      print('Video image${response.statusCode}');
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print("Error fetching image for movie $videoId: $e");
      return null;
    }
    return null;
  }

  static Future<List<Category>> fetchAllCategories() async {
    final response =
        await http.get(Uri.parse('$baseUrl/GetAllCategories'));
    print('Categories:$response.statusCode');
    if (response.statusCode == 200) {
      print(response.statusCode);
      List<dynamic> categoryJson = jsonDecode(response.body);
      return categoryJson.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }

  Future<List<Movies>> getMoviesWithCategories() async {
    final categories = await fetchAllCategories();
    final movies = await fetchVideos();
    for (var movie in movies) {
      movie.setCategoryNames(categories);
    }
    return movies;
  }

  Future<Category> getCategoryById(int id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/GetCategoryById/$id'));
    if (response.statusCode == 200) {
      return Category.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load category');
    }
  }

  static Future<List<String>> getCategoryNamesById(
      List<int> categoryId) async {
    final queryParams =
        categoryId.map((id) => 'categoryId=$id').join('&');
    final response = await http
        .get(Uri.parse('$baseUrl/categorylist/category?$queryParams'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> categoryNames = jsonDecode(response.body);
      return List<String>.from(categoryNames);
    } else {
      throw Exception('Failed to load category names');
    }
  }
}
