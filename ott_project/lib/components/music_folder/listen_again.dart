import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:ott_project/components/music_folder/audio.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_provider.dart';

class ListenAgain {
  final int songId;
  int playCount;
  late DateTime lastPlayed;

  ListenAgain({
    required this.songId,
    this.playCount = 1,
    required this.lastPlayed,
  });

  Map<String, dynamic> toJson() => {
        'songId': songId,
        'playCount': playCount,
        'lastPlayed': lastPlayed.toIso8601String(),
      };

  factory ListenAgain.fromJson(Map<String, dynamic> json) => ListenAgain(
      songId: json['songId'],
      lastPlayed: DateTime.parse(json['lastPlayed']),
      playCount: json['playCount']);
}

class ListenAgainSection extends StatefulWidget {
  final List<Audio> allAudios;
  final Function(Audio) onAudioTap;
  final List<Audio> categoryPlayList;

  const ListenAgainSection({
    super.key,
    required this.allAudios,
    required this.onAudioTap,
    required this.categoryPlayList,
  });

  @override
  _ListenAgainSectionState createState() => _ListenAgainSectionState();
}

class _ListenAgainSectionState extends State<ListenAgainSection> {
  Map<int, ListenAgain> listenAgainMap = {};

  @override
  void initState() {
    super.initState();
    _loadListeningHistory();
  }

  Future<void> _loadListeningHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedMap = prefs.getString('ListenAgain');
    if (encodedMap != null) {
      Map<String, dynamic> decodedMap = jsonDecode(encodedMap);
      setState(() {
        listenAgainMap = decodedMap.map((key, value) =>
            MapEntry(int.parse(key), ListenAgain.fromJson(value)));
        listenAgainMap.removeWhere((id, listenAgain) =>
            !widget.allAudios.any((audio) => audio.id == id));
      });
    }
  }

  List<Audio> getListenAgainSongs({int limit = 6}) {
    List<Audio> listenAgainSongs = [];
    listenAgainMap.forEach((id, listenAgain) {
      if (listenAgain.playCount > 1) {
        // Only include songs played more than once
        try {
          final audio = widget.allAudios.firstWhere((song) => song.id == id);
          listenAgainSongs.add(audio);
        } catch (e) {
          print('Song with id $id not found in allAudios');
        }
      }
    });

    listenAgainSongs.sort((a, b) {
      final listenAgainA = listenAgainMap[a.id]!;
      final listenAgainB = listenAgainMap[b.id]!;
      if (listenAgainA.playCount != listenAgainB.playCount) {
        return listenAgainB.playCount.compareTo(listenAgainA.playCount);
      } else {
        return listenAgainB.lastPlayed.compareTo(listenAgainA.lastPlayed);
      }
    });

    return listenAgainSongs.take(limit).toList();
  }

  void _updateListeningHistory(Audio song) async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedMap = prefs.getString('ListenAgain');
    Map<int, ListenAgain> listenAgain = {};
    if (encodedMap != null) {
      Map<String, dynamic> decodedMap = jsonDecode(encodedMap);
      listenAgain = decodedMap.map((key, value) =>
          MapEntry(int.parse(key), ListenAgain.fromJson(value)));
    }

    setState(() {
      if (listenAgain.containsKey(song.id)) {
        listenAgain[song.id]!.playCount++;
        listenAgain[song.id]!.lastPlayed = DateTime.now();
      } else {
        listenAgain[song.id] =
            ListenAgain(songId: song.id, lastPlayed: DateTime.now());
      }
    });

    final String encoded = jsonEncode(listenAgain
        .map((key, value) => MapEntry(key.toString(), value.toJson())));
    await prefs.setString('ListenAgain', encoded);
  }

  @override
  Widget build(BuildContext context) {
    List<Audio> listenAgainSongs = getListenAgainSongs();
    print(
        "Building ListenAgainSection. Songs count: ${listenAgainSongs.length}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Listen Again',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: kWhite)),
        ),
        listenAgainSongs.isNotEmpty
            ? Container(
                height: 250, // Adjust height as needed
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: listenAgainSongs.length,
                  itemBuilder: (context, index) {
                    final song = listenAgainSongs[index];
                    final compressedBytes = base64.decode(song.thumbnail);
                    final decompressedBytes =
                        ZLibDecoder().decodeBytes(compressedBytes);
                    return GestureDetector(
                      onTap: () {
                        print("Song tapped: ${song.songname}");
                        _updateListeningHistory(song);
                        widget.onAudioTap(song);
                        Provider.of<AudioProvider>(context, listen: false)
                            .setCurrentlyPlaying(song, widget.categoryPlayList);
                      },
                      child: ListTile(
                        leading: Image.memory(
                            Uint8List.fromList(decompressedBytes),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover),
                        title: Text(song.songname,
                            style: TextStyle(color: Colors.white)),
                        trailing: IconButton(
                          onPressed: (){},
                          icon:Icon(Icons.more_vert, color: Colors.white)),
                      ),
                    );
                  },
                ),
              )
            : SizedBox.shrink()
      ],
    );
  }

  
}

// class ListenAgainSection extends StatefulWidget {
//   final List<Audio> allAudios;
//   final Function(Audio) onAudioTap;
//   final List<Audio> categoryPlayList;
//   const ListenAgainSection(
//       {super.key,
//       required this.allAudios,
//       required this.onAudioTap,
//       required this.categoryPlayList});

//   @override
//   State<ListenAgainSection> createState() => _ListenAgainSectionState();
// }

// class _ListenAgainSectionState extends State<ListenAgainSection> {
//   Map<int, ListenAgain> _listenAgain = {};
//   List<Audio> _frequentlyListenedSongs = [];

//   @override
//   void initState() {
//     super.initState();
//     print("ListenAgainSection initState called");
//     _loadListenAgain();
//   }

//   Future<void> _loadListenAgain() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? encodeMap = prefs.getString('ListenAgain');
//     if (encodeMap != null) {
//       Map<String, dynamic> decodedMap = jsonDecode(encodeMap);
//       setState(() {
//         _listenAgain = decodedMap.map((key, value) =>
//             MapEntry(int.parse(key), ListenAgain.fromJson(value)));
//         print(
//             "Loaded listening history: ${_listenAgain.map((key, value) => MapEntry(key, '${value.playCount} plays'))}");
//         //_updateFrequentlyListenedSongs();
//       });
//     } else {
//       print("No listening history found in SharedPreferences");
//     }
//     _updateFrequentlyListenedSongs();
//   }

//   // Future<void> _saveListeningHistory() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final String encodedMap = jsonEncode(_listenAgain
//   //       .map((key, value) => MapEntry(key.toString(), value.toJson())));
//   //   await prefs.setString('ListenAgain', encodedMap);
//   //   print("Saved listening history: $encodedMap");
//   // }

//   Future<void> _saveListeningHistory() async {
//     print("Starting to save listening history");
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       print("SharedPreferences instance obtained");

//       if (_listenAgain.isEmpty) {
//         print("Listening history is empty, nothing to save");
//         return;
//       }

//       final String encodedMap = jsonEncode(_listenAgain
//           .map((key, value) => MapEntry(key.toString(), value.toJson())));
//       print("JSON encoded: $encodedMap");

//       bool saveSuccess = await prefs.setString('ListenAgain', encodedMap);
//       if (saveSuccess) {
//         print("Successfully saved listening history: $encodedMap");
//       } else {
//         print("Failed to save listening history");
//       }
//     } catch (e) {
//       print("Error saving listening history: $e");
//     }
//   }

//   void _updateListeningHistory(Audio song) async {
//     print("Updating listening history for song: ${song.songname}");
//     setState(() {
//       if (_listenAgain.containsKey(song.id)) {
//         _listenAgain[song.id]!.playCount++;
//         _listenAgain[song.id]!.lastPlayed = DateTime.now();
//       } else {
//         _listenAgain[song.id] =
//             ListenAgain(songId: song.id, lastPlayed: DateTime.now());
//       }
//     });
//     print(
//         "Updated listening history for song ${song.songname}: ${_listenAgain[song.id]!.playCount} plays");
//     await _saveListeningHistory();
//     print("Save operation completed");
//     _updateFrequentlyListenedSongs();
//   }

//   void _updateFrequentlyListenedSongs({int limit = 10}) {
//     print(
//         "Updating frequently listened songs. History size: ${_listenAgain.length}");
//     final now = DateTime.now();
//     final recentSong = now.subtract(Duration(days: 2));
//     final sortedHistory = _listenAgain.values.toList()
//       ..sort((a, b) {
//         if (a.playCount > 1 && b.playCount <= 1) return -1;
//         if (b.playCount > 1 && a.playCount <= 1) return 1;
//         if (a.playCount == 1 && b.playCount == 1) {
//           if (a.lastPlayed.isAfter(recentSong) &&
//               b.lastPlayed.isBefore(recentSong)) return -1;
//           if (b.lastPlayed.isAfter(recentSong) &&
//               a.lastPlayed.isBefore(recentSong)) return 1;
//         }
//         final playCountComparison = b.playCount.compareTo(a.playCount);
//         if (playCountComparison != 0) return playCountComparison;
//         return b.lastPlayed.compareTo(a.lastPlayed);
//       });

//     final frequentOrRecentSongIds = sortedHistory
//         .where((h) => h.playCount > 1 || h.lastPlayed.isAfter(recentSong))
//         .take(limit)
//         .map((h) => h.songId)
//         .toList();
//     print("Frequent or recent song IDs: $frequentOrRecentSongIds");
//     setState(() {
//       _frequentlyListenedSongs = widget.allAudios
//           .where((song) => frequentOrRecentSongIds.contains(song.id))
//           .toList();
//       print(
//           "Updated frequently listened songs. Count: ${_frequentlyListenedSongs.length}");
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     print(
//         "Building ListenAgainSection. Songs count: ${_frequentlyListenedSongs.length}");
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Text('Listen Again',
//               style: TextStyle(
//                   fontSize: 20, fontWeight: FontWeight.bold, color: kWhite)),
//         ),
//         _frequentlyListenedSongs.isNotEmpty
//             ? Container(
//                 height: 250, // Adjust height as needed
//                 child: ListView.builder(
//                   scrollDirection: Axis.vertical,
//                   itemCount: _frequentlyListenedSongs.length,
//                   itemBuilder: (context, index) {
//                     final song = _frequentlyListenedSongs[index];
//                     final compressedBytes = base64.decode(song.thumbnail);
//                     final decompressedBytes =
//                         ZLibDecoder().decodeBytes(compressedBytes);
//                     return GestureDetector(
//                       onTap: () {
//                         print("Song tapped: ${song.songname}");
//                         _updateListeningHistory(song);
//                         widget.onAudioTap(song);
//                         Provider.of<AudioProvider>(context, listen: false)
//                             .setCurrentlyPlaying(song, widget.categoryPlayList);
//                       },
//                       child: ListTile(
//                         leading: Image.memory(
//                             Uint8List.fromList(decompressedBytes),
//                             width: 50,
//                             height: 50,
//                             fit: BoxFit.cover),
//                         title: Text(song.songname,
//                             style: TextStyle(color: Colors.white)),
//                         //subtitle: Text(song.artistname, style: TextStyle(color: Colors.white70)),
//                         trailing: Icon(Icons.more_vert, color: Colors.white),
//                       ),
//                     );
//                   },
//                 ),
//               )
//             : SizedBox.shrink()
//       ],
//     );
//   }
// }

