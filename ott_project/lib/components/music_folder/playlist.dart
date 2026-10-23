import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'audio.dart';
import 'music.dart';

class Playlist {
  String title;
  String description;
  List<Audio> audios;

  Playlist(
      {required this.audios, required this.description, required this.title});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'audios': audios.map((audio) => audio.toJson()).toList(),
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
        audios: (json['audios'] as List)
            .map((audioJson) => Audio.fromJson(audioJson))
            .toList(),
        description: json['description'],
        title: json['title']);
  }

  Uint8List? getPlaylistImage() {
    if (audios.isNotEmpty) {
      final String? thumbnail = audios.first.thumbnail;
      if (thumbnail != null && thumbnail.isNotEmpty) {
        final compressedBytes = base64.decode(thumbnail);
        final decompressedBytes = ZLibDecoder().decodeBytes(compressedBytes);
        return Uint8List.fromList(decompressedBytes);
      }
    }
    return null;
  }
}

class MusicPlaylist {
  String title;
  String description;
  List<Music> music;

  MusicPlaylist(
      {required this.music, required this.description, required this.title});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'music': music.map((audio) => audio.toJson()).toList(),
    };
  }

  factory MusicPlaylist.fromJson(Map<String, dynamic> json) {
    return MusicPlaylist(
        music: (json['music'] as List)
            .map((audioJson) => Music.fromJson(audioJson))
            .toList(),
        description: json['description'],
        title: json['title']);
  }

  Uint8List? getMusicPlaylistImage() {
    if (music.isNotEmpty) {
      final Uint8List? thumbnail = music.first.thumbnail;
      if (thumbnail != null && thumbnail.isNotEmpty) {
        String base64Image = thumbnail[0] as String;
        return base64Decode(base64Image);
      }
    }
    return null;
  }
}

  // Uint8List? getPlaylistImage() {
  //   if (music.isNotEmpty) {
  //     final String? thumbnail = music.first.thumbnail;
  //     if (thumbnail != null && thumbnail.isNotEmpty) {
  //       final compressedBytes = base64.decode(thumbnail);
  //       final decompressedBytes = ZLibDecoder().decodeBytes(compressedBytes);
  //       return Uint8List.fromList(decompressedBytes);
  //     }
  //   }
  //   return null;
  // }

