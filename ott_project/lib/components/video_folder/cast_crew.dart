import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

class CastMember {
  final String name;
  final String image;
  final int id;

  CastMember({required this.name, required this.image, required this.id});

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      name: json['name'] as String,
      image: json['image'] ?? 'Test',
      id: json['id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }

  Uint8List get imageBytes {
    final compressedBytes = base64Decode(image);
    return Uint8List.fromList(ZLibDecoder().decodeBytes(compressedBytes));
  }
}


class CastCrew {
  final String name;
  
  final int id;
  Uint8List? image; 

  CastCrew({required this.name,this.image, required this.id});

  factory CastCrew.fromJson(Map<String, dynamic> json) {
    return CastCrew(
      name: json['name'] as String,
      id: json['id'] as int,
    );
  }
   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}