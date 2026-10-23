import 'dart:typed_data';

import 'package:ott_project/components/video_folder/category.dart';

import '../../service/audio_service.dart';

class Music {
  final int id;
  final int? userId;
  Uint8List? thumbnail;
  Uint8List? banner;
  final String songname;
  final String fileName;
  //final String description;
  final List<Category> categories;

  // Future<Uint8List?> get thumbnailImage async {
  //   if (thumbnail == null) {
  //     await fetchImage();
  //   }
  //   return thumbnail;
  // }
  Future<Uint8List?> get thumbnailImage async {
    if (thumbnail == null) {
      await fetchImage();
    }
    return thumbnail;
  }

  Future<void> fetchImage() async {
    try {
      thumbnail = await AudioService.fetchMusicImage(id);
      if (thumbnail != null) {
        print('Thumbnail fetched successfully for music ID: $id');
      } else {
        print('Thumbnail not found for music ID: $id');
      }
    } catch (e) {
      print('Error in fetching image:$e');
    }
  }

  Future<Uint8List?> get bannerImage async {
    if (banner == null) {
      await fetchBanner();
    }
    return banner;
  }

  Future<void> fetchBanner() async {
    try {
      this.banner = await AudioService().fetchMusicBanner(id);
    } catch (e) {
      print('Error in fetching image:$e');
    }
  }

  Music({
    required this.id,
    required this.songname,
    this.userId,
    required this.categories,
    required this.fileName,
    //required this.description,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'],
      songname: json['audioTitle'],
      userId: json['userId'],
      fileName: json['audio_file_name'],
      //description: json['description'],
      categories: (json['category'] as List<dynamic>?)
              ?.map((cat) => Category.fromJson(cat))
              .toList() ??
          [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'songname': songname,
      'userId': userId,
      'categories': categories,
      'fileName': fileName,
    };
  }

  //Music update

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Music && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode ^ songname.hashCode;

  @override
  String toString() {
    return 'Music{id: $id, songname: $songname,category: $categories}';
  }
}
