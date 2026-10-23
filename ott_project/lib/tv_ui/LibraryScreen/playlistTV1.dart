import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ott_project/components/library/audio_playlist.dart';
import 'package:ott_project/components/library/playlist_detail.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';

import 'package:ott_project/service/playlist_service.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/LibraryScreen/TvplaylistDetail.dart';

class TVPlayListTV1 extends StatefulWidget {
  final int userId;
  const TVPlayListTV1({super.key, required this.userId});

  @override
  State<TVPlayListTV1> createState() => _TVPlayListTV1State();
}

class _TVPlayListTV1State extends State<TVPlayListTV1> {
  late Future<List<AudioPlaylist>> _playlistFuture;
  final Map<int, Uint8List?> _thumbnailCache = {};
  final Map<int, List<AudioDescription>> _playlistAudioCache = {};

  @override
  void initState() {
    super.initState();
    _playlistFuture = _fetchPlaylistsWithCache();
    FocusManagerService.globalFocusNode.addListener(_onFocusChange);
    FocusManagerService.onMyPlaylistSelect = (int playlistIndex) async {
      final playlists = await _playlistFuture;
      if (playlistIndex >= 0 && playlistIndex < playlists.length && mounted) {
        _navigateToPlaylistDetails(playlists[playlistIndex]);
      }
    };
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    FocusManagerService.globalFocusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  Future<List<AudioPlaylist>> _fetchPlaylistsWithCache() async {
    try {
      final playlists = await PlaylistService().getPlaylistsByUserId(widget.userId);
      FocusManagerService.updatePlaylistCount(playlists.length);

      await Future.wait(playlists.map((playlist) async {
        try {
          final audios = await playlist.getAudios();
          _playlistAudioCache[playlist.id] = audios;

          if (audios.isNotEmpty) {
            final thumbnail = await audios[0].thumbnailImage;
            _thumbnailCache[playlist.id] = thumbnail;
          }
        } catch (e) {
          print('Error caching playlist ${playlist.id}: $e');
        }
      }));

      return playlists;
    } catch (e) {
      print('Error fetching playlists: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AudioPlaylist>>(
      future: _playlistFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No playlists available',
                style: TextStyle(color: Colors.white)),
          );
        }

        final playlists = snapshot.data!;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            final isFocused = FocusManagerService.isMyPlaylistFocused &&
                FocusManagerService.selectedMyPlaylistIndex == index;

            return Card(
              color: isFocused ? Colors.blue : null,
              clipBehavior: Clip.hardEdge, // clips image to card rounded corners
              child: GestureDetector(
                onTap: () => _navigateToPlaylistDetails(playlist),
                child: Stack(
                  fit: StackFit.expand, // Stack fills entire card
                  children: [
                    // ── FIXED: image fills full card, no fixed width/height ──
                    _buildPlaylistThumbnail(playlist),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      child: Text(
                        playlist.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── FIXED: removed width: 250, height: 330 — image now fills the card ─────
  Widget _buildPlaylistThumbnail(AudioPlaylist playlist) {
    final cachedThumbnail = _thumbnailCache[playlist.id];

    if (cachedThumbnail != null) {
      return Image.memory(
        cachedThumbnail,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildMusicPlaceholder(),
      );
    }

    return _buildMusicPlaceholder();
  }

  Widget _buildMusicPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }

  void _navigateToPlaylistDetails(AudioPlaylist playlist) {
    Navigator.of(context, rootNavigator: true)
        .push(
          MaterialPageRoute(
            builder: (context) => TVPlaylistDetailsPage(
              playlist: playlist,
              playlistId: playlist.id,
            ),
          ),
        )
        .then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusManagerService.currentPage = 0;
        if (mounted) setState(() {});
      });
    });
  }
}