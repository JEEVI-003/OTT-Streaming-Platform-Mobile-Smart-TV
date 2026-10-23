import 'dart:convert';
import 'dart:typed_data';



class AppIcon {
  final String icon;

  AppIcon({required this.icon});

  

  Uint8List get imageBytes {
   
    try {
      return base64Decode(icon);
    } catch (e) {
      print('Error decoding icon: $e');
      return Uint8List(0);
    }
  }
}
