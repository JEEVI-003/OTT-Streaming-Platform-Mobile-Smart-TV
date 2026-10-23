import 'package:flutter/material.dart';
import 'package:ott_project/components/background_image.dart';

import 'package:ott_project/components/music_folder/audio_card.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/components/music_folder/song_player_page.dart';

import 'package:ott_project/pages/custom_appbar.dart';

class CategoryBasedSong extends StatefulWidget {

  final String categoryName;
  final List<AudioDescription> audioDescriptions;
  const CategoryBasedSong({super.key, required this.categoryName, required this.audioDescriptions});

  @override
  State<CategoryBasedSong> createState() => _CategoryBasedSongState();
}

class _CategoryBasedSongState extends State<CategoryBasedSong> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  AudioDescription? currentSong;
  Set<int> likedSongIds = {};

  List<AudioDescription> _filteredAudioDescriptions = [];

  @override
  void initState() {
    super.initState();
    _filteredAudioDescriptions = List.from(widget.audioDescriptions);
  }

  void handleSearchState(bool isSearching, List<dynamic> results) {
    setState(() {
      _isSearching = isSearching;
      _searchResults = results;
    });
  }
void handleDislike(AudioDescription song) {
  setState(() {
    if (likedSongIds.contains(song.id)) {
      likedSongIds.remove(song.id); // Unlike
    } else {
      likedSongIds.add(song.id); // Like
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackgroundImage(),
          CustomAppBar(onSearchChanged: handleSearchState),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.sizeOf(context).height * 0.15,
              left: MediaQuery.sizeOf(context).width * 0.02,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
                Text(
                  '${widget.categoryName} Songs',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            top: MediaQuery.sizeOf(context).height * 0.20,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.06,
              ),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 35,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.65,
                ),
                itemCount: _filteredAudioDescriptions.length,
                itemBuilder: (context, index) {
                  final song = _filteredAudioDescriptions[index];
                  return AudioCard(
                    audio: song,
                    initialIndex: index,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongPlayerPage(
                            music: song,
                            musicList: _filteredAudioDescriptions,
                            onChange: (newSong) {
                              setState(() => currentSong = newSong);
                            },
                            onDislike: handleDislike,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}