import 'dart:typed_data';

import 'package:ott_project/service/audio_service.dart';

class AudioContainer {
  final String categoryName;
  final List<AudioDescription> audiolist;

  AudioContainer({
    required this.categoryName,
    required this.audiolist,
  });

  factory AudioContainer.fromJson(Map<String, dynamic> json) {
    var audioListFromJson = json['audiolist'] as List;
    List<AudioDescription> audioList = audioListFromJson
        .map((audio) => AudioDescription.fromJson(audio))
        .toList();

    return AudioContainer(
      categoryName: json['category_name'],
      audiolist: audioList,
    );
  }
}

class AudioDescription {
  final int id;
  final String audioTitle;
    String? movieName;
  final String? rating;
  final String? description;
  final String? productionCompany;
  final bool paid;
  final String? audioFileName;
  final String? certificateName;
  final String? audioDuration;
  final String? certificateNo;

   Uint8List? thumbnail;
   Uint8List? bannerthumbnail;

  AudioDescription({
    required this.id,
    required this.audioTitle,
   this.movieName,
     this.rating,
     this.description,
     this.productionCompany,
    required this.paid,
     this.audioFileName,
     this.certificateName,
     this.audioDuration,
     this.certificateNo,
     this.thumbnail,
     this.bannerthumbnail,
    
  });

  factory AudioDescription.fromJson(Map<String, dynamic> json) {
    return AudioDescription(
      id: json['id'] ?? 0,
      audioTitle: json['audio_title'] ?? json['audioTitle'],
     // movieName: json['movie_name'] as String,
            movieName: json['movie_name'] != null ? json['movie_name'].toString() : null,
      rating: json['rating']?.toString(),
      description: json['description']?.toString(),
      productionCompany: json['production_company']?.toString(),
      paid: json['paid'] ?? false,
      audioFileName: json['audio_file_name']?.toString(),
      certificateName: json['certificate_name']?.toString(),
      audioDuration: json['audio_Duration']?.toString(),
      certificateNo: json['certificate_no']?.toString(),
    );
  }
  Map<String, dynamic> toJson(){
    return{
      'id':id,
      'audio_title' : audioTitle,
      //'movieName' : movieName,
      'rating' : rating,
      'description': description,
      'productionCompany' :productionCompany,
      'paid' : paid,
      'audioFileName' : audioFileName,
      'certificateName':certificateName,
      'audioDuration' : audioDuration,
      'certificateNo' : certificateNo
    };
  }

  static Future<AudioDescription> fromJsonAsync(Map<String, dynamic> json) async {
    final audio = AudioDescription.fromJson(json);
    await audio.fetchImage();
    await audio.fetchBannerImage();
    return audio;
  }

  @override
  String toString(){
    return 'AudioDescription(id:$id,audioTitle:$audioTitle,rating:$rating,description:$description,audioFileName:$audioFileName,thumbnail:$thumbnail)';
  }

  Future<Uint8List?> get thumbnailImage async {
    if (thumbnail == null) {
      await fetchImage();
    }
    return thumbnail;
  }

  Future<Uint8List?> get bannerImage async{
    if(bannerthumbnail == null){
      await fetchBannerImage();
    }
    return bannerthumbnail;
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

  Future<void> fetchBannerImage() async {
    try {
      bannerthumbnail = await AudioService().fetchMusicBanner(id);
      if (bannerthumbnail != null) {
        print('Thumbnail fetched successfully for music ID: $id');
      } else {
        print('Thumbnail not found for music ID: $id');
      }
    } catch (e) {
      print('Error in fetching image:$e');
    }
  }
}
