class VideoBanner {

  final int id;
  final int videoId;

  VideoBanner({required this.id,required this.videoId});

  factory VideoBanner.fromJson(Map<String,dynamic> json){
    return VideoBanner(id: json['id'], videoId: json['videoId']);
  }

   @override
  String toString() {
    return 'VideoBanner{id: $id, videoId: $videoId}';
  }
}