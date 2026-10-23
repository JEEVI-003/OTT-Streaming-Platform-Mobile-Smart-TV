// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:archive/archive.dart';
// import 'package:flutter/material.dart';
// import 'package:ott_project/components/music_folder/audio.dart';

// class AudioCategorySection extends StatelessWidget {
//   final String title;
//   final List<Audio> audios;
//   final int userId;
//   final Function(Audio) onTap;

//   const AudioCategorySection(
//       {super.key,
//       required this.title,
//       required this.audios,
//       required this.userId,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     // final displayedAudios = audios.length > 5 ? audios.sublist(0, 5) : audios;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             TextButton(
//                 onPressed: () {},
//                 child: Text('See more', style: TextStyle(color: Colors.green))),
//           ],
//         ),
//         SizedBox(
//           height: 10,
//         ),
//         Container(
//           height: 200,
//           child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: audios.length,
//               itemBuilder: (context, index) {
//                 final audio = audios[index];
//                 final compressedBytes = base64.decode(audio.thumbnail);
//                 final decompressedBytes =
//                     ZLibDecoder().decodeBytes(compressedBytes);
//                 return GestureDetector(
//                   onTap: () => onTap(audio),
//                   child: Container(
//                     width: 120,
//                     margin: EdgeInsets.only(right: 15),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child:
//                               Image.memory(
//                                 Uint8List.fromList(decompressedBytes),
//                                 width: 164,
//                                 height: 155,
//                                 fit: BoxFit.fill,
//                               ),
//                             ),
//                             Icon(Icons.play_circle,
//                                 color: Colors.white, size: 35),
//                           ],
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           audios[index].songname,
//                          //audio.songname,
//                           style: TextStyle(color: Colors.white),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Container(
//                   //   width: 120,
//                   //   margin: EdgeInsets.only(right: 10),
//                   //   child: Column(
//                   //     crossAxisAlignment: CrossAxisAlignment.start,
//                   //     children: [
//                   //       Image.memory(
//                   //         Uint8List.fromList(decompressedBytes),
//                   //         width: 120,
//                   //         height: 120,
//                   //         fit: BoxFit.cover,
//                   //       ),
//                   //       SizedBox(
//                   //         height: 5,
//                   //       ),
//                   //       Text(
//                   //         audio.songname,
//                   //         style: TextStyle(color: Colors.white),
//                   //         maxLines: 2,
//                   //         overflow: TextOverflow.ellipsis,
//                   //       ),
//                   //     ],
//                   //   ),
//                   // ),
//                 );
//               }),
//         ),
//         SizedBox(
//           height: 20,
//         ),
//       ],
//     );
//   }
// }
