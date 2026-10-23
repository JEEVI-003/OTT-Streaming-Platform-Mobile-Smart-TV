import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/service/audio_api_service.dart';

class AudioPlaylist {
  final int id;
  final int userId;
  final String title;
  final String description;
  final List<int> audioIds;
  List<AudioDescription>? _cachedAudios;

  AudioPlaylist({required this.id,required this.userId, required this.audioIds,required this.description,required this.title});
 
  factory AudioPlaylist.fromJson(Map<String, dynamic> json){
    return AudioPlaylist(id:json['id'] as int, userId:json['userId'], audioIds:json['audioIds'] != null ? (json['audioIds'] as List<dynamic>).map((item)=> item as int).toList() : [],
            description:json['description'] , title:json['title'] );
  }

 @override
  String toString() {
    return 'AudioPlaylist(id: $id, userId: $userId, audioIds: $audioIds, description: $description, title: $title)';
  }

  Future<List<AudioDescription>> getAudios()async{
    if(_cachedAudios != null){
      return _cachedAudios!;
    }
    try{
      List<AudioDescription> audioList =[];
      for(int audioId in audioIds){
        final audio = await AudioApiService().fetchAudioDetails(audioId);
        audioList.add(audio);
            }
      _cachedAudios = audioList;
      return audioList;
    }catch (e) {
      print('Error fetching audios: $e');
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'userId' : userId,
      'title': title,
      'description': description,
      'audiosIds': audioIds,
    };
  }
}