import 'package:flutter/material.dart';

import 'package:ott_project/components/music_folder/audio_container.dart';

import 'package:ott_project/service/audio_api_service.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/music/audiocardtv.dart';
import 'package:ott_project/tv_ui/music/musicplayerTV.dart';

class LikedSongsTVProfile extends StatefulWidget {
  final int userId;
  const LikedSongsTVProfile({Key? key, required this.userId}) : super(key: key);

  @override
  State<LikedSongsTVProfile> createState() => _LikedSongsTVProfileState();
}

class _LikedSongsTVProfileState extends State<LikedSongsTVProfile> {
  late Future<List<AudioDescription>> _likedSongsFuture;
  List<AudioDescription> _likedSongs = [];

  // White focus border — consistent with movie-page focus style
  static const Color _focusBorderColor = Colors.white;
  static const double _focusBorderWidth = 3.0;

  @override
  void initState() {
    super.initState();
    _likedSongsFuture = _fetchLikedAudios();

    // Register handler immediately so focus manager can fire it even before
    // the future resolves.
    FocusManagerService.onLikedSongsSelect = (index) {
      debugPrint('Song selected at index: $index');
      _handleLikedSongSelection(index);
    };

    // FIX: Rebuild when D-pad moves focus so highlight updates correctly.
    FocusManagerService.globalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    FocusManagerService.globalFocusNode.removeListener(_onFocusChange);
    // Clear stale handler so it is not called after widget is gone.
    FocusManagerService.onLikedSongsSelect = null;
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  Future<List<AudioDescription>> _fetchLikedAudios() async {
    try {
      final List<int> likedAudioIds =
          await AudioApiService().getLikedSongs(widget.userId);
      FocusManagerService.updateLikedSongCount(likedAudioIds.length);

      _likedSongs = await Future.wait(
        likedAudioIds.map((id) => AudioApiService().fetchAudioDetails(id)),
      );

      return _likedSongs;
    } catch (e) {
      debugPrint('Error fetching liked songs: $e');
      return [];
    }
  }

  void _handleLikedSongSelection(int index) {
    debugPrint('Handling liked song selection at index: $index');

    if (index < 0 || index >= _likedSongs.length) {
      debugPrint('Invalid audio index: $index');
      return;
    }

    final selectedSong = _likedSongs[index];
    _onAudioPlay(selectedSong, index);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AudioDescription>>(
      future: _likedSongsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No audios available',
                  style: TextStyle(color: Colors.white)));
        }

        final likedSongs = snapshot.data!;

        return GridView.builder(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.02,
            left: MediaQuery.of(context).size.width * 0.01,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: likedSongs.length,
          itemBuilder: (context, index) {
            final song = likedSongs[index];
            // FIX: isFocused checked every build because _onFocusChange
            // triggers setState on D-pad events.
            final bool isFocused = FocusManagerService.isLikedSongsFocused &&
                FocusManagerService.selectedLikedSongsIndex == index;

            return GestureDetector(
              onTap: () => _onAudioPlay(song, index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  // FIX: White focus border — consistent with movie-page style
                  border: isFocused
                      ? Border.all(
                          color: _focusBorderColor,
                          width: _focusBorderWidth,
                        )
                      : Border.all(
                          color: Colors.transparent,
                          width: _focusBorderWidth),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.25),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isFocused ? 6 : 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: isFocused
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.shade900,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(isFocused ? 6 : 8)),
                    child: TVAudioCard(
                      audio: song,
                      initialIndex: index,
                      onTap: () => _onAudioPlay(song, index),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onAudioPlay(AudioDescription song, int index) async {
    try {
      final info = await AudioApiService().fetchCategoryInfo(song.id);

      final int? categoryId = info['categoryId'];
      final String? categoryName = info['categoryName'];

      if (categoryId == null || categoryName == null) {
        debugPrint('Missing category info for song ${song.id}');
        return;
      }

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => TVMusicPlayerPage(
            categoryId: categoryId,
            categoryName: categoryName,
            audioDescriptions: _likedSongs,
            initialIndex: index,
          ),
        ),
      ).then((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusManagerService.currentPage = 0;
          if (mounted) setState(() {});
        });
      });
    } catch (e) {
      debugPrint('Error while fetching category info: $e');
    }
  }
}