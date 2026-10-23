import 'package:ott_project/components/library/likedSongsDTO.dart';

class PlaylistDTO {
  final int userId;
  final int playlistId;
  final String title;
  final String description;
  final List<LikedsongsDTO> audioDetails;

  PlaylistDTO({required this.userId,required this.playlistId,required this.title,required this.description,required this.audioDetails});

  factory PlaylistDTO.fromJson(Map<String,dynamic> json){
    return PlaylistDTO(
      userId:json['userId'] , 
      playlistId: json['playlistId'], 
      title: json['title'], 
      description: json['description'], 
      audioDetails: (json['audioDetails'] as List).map((item)=>LikedsongsDTO.fromJson(item)).toList());
  }

  @override
  String toString(){
    return 'PlaylistDTO(userId:$userId,title:$title,description:$description,audioDetails:$audioDetails)';
  }
}