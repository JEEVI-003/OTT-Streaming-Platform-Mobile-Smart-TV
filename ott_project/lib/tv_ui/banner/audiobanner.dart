class AudioBannerTV {

  final int id;
  final int movienameID;

  AudioBannerTV({required this.id,required this.movienameID});

  factory AudioBannerTV.fromJson(Map<String,dynamic> json){
    return AudioBannerTV(id: json['id'], movienameID: json['movienameID']);
  }

   @override
  String toString() {
    return 'AudioBanner{id: $id, movienameID: $movienameID}';
  }
}

