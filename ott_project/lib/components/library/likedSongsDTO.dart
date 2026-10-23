class LikedsongsDTO {
  final int audioId;
  final String audioTitle;

  LikedsongsDTO({required this.audioId, required this.audioTitle});

  factory LikedsongsDTO.fromJson(Map<String, dynamic> json) {
    return LikedsongsDTO(
      audioId: json['audioId'],
      audioTitle: json['audio_title'],
    );
  }

  @override
  String toString(){
    return 'LikedsongsDTO(audioId:$audioId,audioTitle:$audioTitle)';
  }
}
