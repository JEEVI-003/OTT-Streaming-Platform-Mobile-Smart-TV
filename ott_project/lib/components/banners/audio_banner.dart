class AudioBanner {

  final int id;
  final int movienameID;

  AudioBanner({required this.id,required this.movienameID});

  factory AudioBanner.fromJson(Map<String,dynamic> json){
    return AudioBanner(id: json['id'], movienameID: json['movienameID']);
  }

   @override
  String toString() {
    return 'AudioBanner{id: $id, movienameID: $movienameID}';
  }
}