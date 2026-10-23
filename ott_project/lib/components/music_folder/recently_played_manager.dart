import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:ott_project/components/music_folder/audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class RecentlyPlayedManager extends ChangeNotifier {
  static final RecentlyPlayedManager _instance =
      RecentlyPlayedManager._internal();
  factory RecentlyPlayedManager() => _instance;
  RecentlyPlayedManager._internal();

  final List<Audio> _recentlyPlayed = [];
  static const int maxRecentSongs = 5;

  void addRecentlyPlayed(Audio audio) {
    _recentlyPlayed.removeWhere((a) => a.id == audio.id);
    _recentlyPlayed.insert(0, audio);
    if (_recentlyPlayed.length > maxRecentSongs) {
      _recentlyPlayed.removeLast();
    }
    notifyListeners();
  }

  List<Audio> getRecentlyPlayed() => List.unmodifiable(_recentlyPlayed);
}

class RecentlyPlayedSection extends StatelessWidget {
  final RecentlyPlayedManager recentlyPlayedManager;
  final Function(Audio) onTap;

  const RecentlyPlayedSection({
    Key? key,
    required this.onTap,
    required this.recentlyPlayedManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: recentlyPlayedManager,
      builder: (context, child) {
        final recentlyPlayed = recentlyPlayedManager.getRecentlyPlayed();

        if (recentlyPlayed.isEmpty) {
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
            SizedBox(height: 5),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: recentlyPlayed.length,
              itemBuilder: (context, index) {
                final audio = recentlyPlayed[index];
                final compressedBytes = base64.decode(audio.thumbnail);
                final decompressedBytes =
                    ZLibDecoder().decodeBytes(compressedBytes);
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      Uint8List.fromList(decompressedBytes),
                      width: 50,
                      height: 50,
                      fit: BoxFit.fill,
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
