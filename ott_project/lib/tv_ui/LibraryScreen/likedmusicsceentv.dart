import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ott_project/components/music_folder/audio.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/service/audio_api_service.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/LibraryScreen/storagedata.dart';
import 'package:ott_project/tv_ui/music/audiocardtv.dart';
import 'package:ott_project/tv_ui/music/musicplayerTV.dart';

class TVLikedSongsPage extends StatefulWidget {
  final int userId;

  const TVLikedSongsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _TVLikedSongsPageState createState() => _TVLikedSongsPageState();
}

class _TVLikedSongsPageState extends State<TVLikedSongsPage> {
  List<AudioDescription> _likedAudio = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // FIX: Register selection handler immediately — not inside the async
    // fetch callback — so it is always available when focus manager fires it.
    FocusManagerService.onLikedSongsSelect = (int index) {
      debugPrint('LikedSong selection: index $index');
      if (index < 0 || index >= _likedAudio.length) {
        debugPrint('Invalid liked song index: $index');
        return;
      }
      _onAudioPlay(_likedAudio[index], index);
    };

    // FIX: Rebuild when focus node fires (D-pad moves highlight)
    FocusManagerService.globalFocusNode.addListener(_onFocusChange);
    _fetchLikedAudios();
  }

  @override
  void dispose() {
    FocusManagerService.globalFocusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchLikedAudios() async {
    try {
      debugPrint('Fetching liked audio IDs...');
      final List<int> likedAudioIds =
          await AudioApiService().getLikedSongs(widget.userId);
      debugPrint('Fetched ${likedAudioIds.length} liked song IDs');

      FocusManagerService.updateLikedSongCount(likedAudioIds.length);

      final List<AudioDescription> likedAudio = await Future.wait(
        likedAudioIds.map((id) async {
          try {
            return await AudioApiService().fetchAudioDetails(id);
          } catch (e) {
            debugPrint('Error fetching audio ID $id: $e');
            rethrow;
          }
        }),
      );

      LikedSongsData.instance.updateLikedSongs(likedAudio.length);

      if (mounted) {
        setState(() {
          _likedAudio = likedAudio;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch liked songs: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Library',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Liked Songs',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text('Error: $_error',
            style: const TextStyle(color: Colors.white)),
      );
    }
    if (_likedAudio.isEmpty) {
      return const Center(
        child: Text('No liked songs yet',
            style: TextStyle(color: Colors.white)),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.02,
        left: MediaQuery.of(context).size.width * 0.01,
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: _likedAudio.length,
        itemBuilder: (context, index) {
          final song = _likedAudio[index];
          // FIX: isFocused is evaluated every build — correctly reflects
          // current D-pad position because _onFocusChange triggers setState.
          final bool isFocused = FocusManagerService.isLikedSongsFocused &&
              FocusManagerService.selectedLikedSongsIndex == index;

          return Card(
            color: isFocused ? Colors.blue.shade700 : null,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            child: Stack(
              children: [
                TVAudioCard(
                  audio: song,
                  initialIndex: index,
                  onTap: () => _onAudioPlay(song, index),
                ),
                // FIX: Visual focus border for remote navigation
                if (isFocused)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 143, 228, 0),
                            width: 3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
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

      Navigator.of(context, rootNavigator: true)
          .push(MaterialPageRoute(
            builder: (context) => TVMusicPlayerPage(
              categoryId: categoryId,
              categoryName: categoryName,
              audioDescriptions: _likedAudio,
              initialIndex: index,
            ),
          ))
          .then((_) {
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