
 
   
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ott_project/components/library/audio_playlist.dart';
import 'package:ott_project/components/library/playlistDTO.dart';
import 'package:ott_project/service/audio_api_service.dart';
import 'package:ott_project/url.dart';
import '../components/music_folder/audio_container.dart';
import '../components/music_folder/playlist.dart';

class PlaylistService {
  // Uses baseUrl from url.dart — NO hardcoded IP here
  
  // static const String baseUrl =
  //  // 'https://mjdemotomcat.vsmartengine.com/media/api/v2';
  //   //'http://localhost:8080/api/v2';
  //   'http://192.168.0.19:8010/api/v2';

  Future<AudioPlaylist> createPlayList({
    required String title,
    required String description,
    required int userId,
  }) async {
    final url = Uri.parse('$baseUrl/createplaylist');
    final response = await http.post(url,
        body: {
          'title': title,
          'description': description,
          'userId': userId.toString()
        });
    if (response.statusCode == 200) {
      return AudioPlaylist.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create playlist');
    }
  }

  Future<AudioPlaylist> createPlayListWithAudioId({
    required String title,
    required String description,
    required int userId,
    required int audioId,
  }) async {
    final url = Uri.parse('$baseUrl/createplaylistid');
    final response = await http.post(url,
        body: {
          'title': title,
          'description': description,
          'userId': userId.toString(),
          'audioId': audioId.toString()
        });
    if (response.statusCode == 200) {
      return AudioPlaylist.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create playlist with audio');
    }
  }

  Future<void> addAudiosToPlaylist(int playlistId, int audioId) async {
    final url = Uri.parse('$baseUrl/$playlistId/audio/$audioId');
    final response =
        await http.post(url, headers: {'Content-type': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception('Failed to add audio');
    }
  }

  Future<Map<String, String>?> getPlaylistById(int playlistId) async {
    final url = Uri.parse('$baseUrl/$playlistId/playlists');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'title': data['title'], 'description': data['description']};
    }
    return null;
  }

  Future<List<AudioPlaylist>> getPlaylistsByUserId(int userId) async {
    final url = Uri.parse('$baseUrl/user/$userId/playlists');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AudioPlaylist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get playlists');
    }
  }

  Future<List<PlaylistDTO>> getPlaylistWithAudioDetails(int id) async {
    final url = Uri.parse('$baseUrl/$id/getPlaylistWithAudioDetails');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PlaylistDTO.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get audio details');
    }
  }

  Future<List<AudioDescription>> getAudioDetailsForPlaylist(
      List<int> audioIds) async {
    try {
      return await Future.wait(
          audioIds.map((id) => AudioApiService().fetchAudioDetails(id)));
    } catch (e) {
      print('Error fetching audio details: $e');
      rethrow;
    }
  }

  Future<String> deletePlaylist(int id) async {
    final url = Uri.parse('$baseUrl/$id/delete/playlist');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) return 'Playlist deleted successfully';
      if (response.statusCode == 404) return 'Playlist not found';
      return 'Something went wrong';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> updatePlaylist(
      int playlistId, String title, String description) async {
    final url = Uri.parse('$baseUrl/editplaylist/$playlistId');
    try {
      await http.patch(url, body: {
        'title': title,
        'description': description,
      });
    } catch (e) {
      print('Playlist edit error: $e');
    }
  }

  Future<void> removeAudioFromPlaylist(int playlistId, int audioId) async {
    final url = Uri.parse('$baseUrl/$playlistId/audio/$audioId/delete');
    try {
      await http.delete(url);
    } catch (e) {
      print('Error removing audio: $e');
    }
  }

  Future<void> moveAudioToPlaylist(
      int playlistId, int audioId, int movedPlaylistId) async {
    final url = Uri.parse(
        '$baseUrl/$playlistId/moveAudioToPlaylist/$audioId/$movedPlaylistId');
    try {
      await http.patch(url);
    } catch (e) {
      print('Error moving audio: $e');
    }
  }
}