import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:ott_project/components/music_folder/music.dart';

class RecentlyPlayed extends ChangeNotifier {
  static final RecentlyPlayed _instance = RecentlyPlayed._internal();
  factory RecentlyPlayed() => _instance;
  RecentlyPlayed._internal();

  final List<Music> _mrecentlyPlayed = [];
  static const int maxRecentSongs = 5;

  void addRecentlyPlayed(Music music) {
    print('Add recently playing:${music.songname}');
    _mrecentlyPlayed.removeWhere((a) => a.id == music.id);
    _mrecentlyPlayed.insert(0, music);
    if (_mrecentlyPlayed.length > maxRecentSongs) {
      _mrecentlyPlayed.removeLast();
    }
    print(
        "Recently played list: ${_mrecentlyPlayed.map((a) => a.songname).toList()}");
    notifyListeners();
  }

  List<Music> getRecentlyPlayed() => List.unmodifiable(_mrecentlyPlayed);
}

class RecentlyPlayedSongs extends StatelessWidget {
  final RecentlyPlayed recentlyPlayed;
  final Function(Music) onTap;

  const RecentlyPlayedSongs({
    Key? key,
    required this.onTap,
    required this.recentlyPlayed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Rebuilding RecentlyPlayedSongs");
    return AnimatedBuilder(
      animation: recentlyPlayed,
      builder: (context, child) {
        final recentlPlayed = recentlyPlayed.getRecentlyPlayed();

        if (recentlPlayed.isEmpty) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recently Played',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child:
                      Text('Play all', style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
            //SizedBox(height: 5),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: recentlPlayed.length,
              itemBuilder: (context, index) {
                final audio = recentlPlayed[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FutureBuilder<Uint8List?>(
                      future: audio.thumbnailImage,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Image.memory(snapshot.data!,
                              width: 50, height: 50, fit: BoxFit.fill);
                        } else {
                          return Container(
                            width: 50,
                            height: 50,
                            // fit: BoxFit.fill
                            color: Colors.grey,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                      },
                    ),
                  ),
                  title: Text(audio.songname,
                      style: TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                  onTap: () => onTap(audio),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
