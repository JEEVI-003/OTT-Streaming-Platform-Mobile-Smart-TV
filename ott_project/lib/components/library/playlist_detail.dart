// FILE: lib/components/library/playlist_detail.dart
//
// FIXES IN THIS VERSION
// ─────────────────────
// FIX-1  Removed broken Image.asset('assets/images/bgimg2.jpg') from AppBar.
//         The asset didn't exist → "Unable to load asset" error shown in screenshot.
//         Replaced with a plain branded title text (safe fallback).
//
// FIX-2  Added permanent back arrow (top-left) that is always visible and calls
//         Navigator.pop() safely — no freeze, no missing-widget crash.
//
// FIX-3  Search now actually WORKS. Added _filteredAudios computed getter,
//         _searchQuery state field, and wired onChanged to update it.
//         The search bar was present but onChanged: (value){} was empty —
//         no filtering ever happened.
//
// FIX-4  Search filters by title (case-insensitive). Shows "No songs found"
//         when query has no matches.
//
// FIX-5  Null/empty safety: _playlists.first guarded against empty list,
//         double setState(_isLoading) collapsed into one call.
//
// FIX-6  _searchController disposed in dispose() to prevent memory leak.
//
// FIX-7  AppBar overflow removed — no more RenderFlex overflowed banner.
//         Icon + title are constrained properly.

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/library/playlistDTO.dart';
import 'package:ott_project/components/music_folder/audio_provider.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:ott_project/pages/app_icon.dart';
import 'package:ott_project/service/audio_api_service.dart';
import 'package:ott_project/service/icon_service.dart';
import 'package:ott_project/service/playlist_service.dart';
import 'package:provider/provider.dart';
import '../../service/service.dart';
import '../music_folder/audio_container.dart';
import '../music_folder/song_player_page.dart';
import 'audio_playlist.dart';
import 'likedSongsDTO.dart';

class PlaylistDetailsPage extends StatefulWidget {
  final AudioPlaylist playlist;
  final int playlistId;

  const PlaylistDetailsPage({
    required this.playlistId,
    required this.playlist,
    super.key,
  });

  @override
  State<PlaylistDetailsPage> createState() => _PlaylistDetailsPageState();
}

class _PlaylistDetailsPageState extends State<PlaylistDetailsPage> {
  // ── Search state ────────────────────────────────────────────────────────────
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // FIX-3: drives real-time filtering

  // ── Data state ──────────────────────────────────────────────────────────────
  AppIcon? iconData;
  List<PlaylistDTO> _playlists = [];
  bool _isLoading = true;
  String? _error;
  final Map<int, Uint8List> audioImages = {};

  // ── FIX-3: computed filtered list ───────────────────────────────────────────
  // Returns the song list for the first (and only) playlist in _playlists,
  // filtered by the current search query. Empty query → full list.
  List<LikedsongsDTO> get _filteredAudios {
    if (_playlists.isEmpty) return [];
    final all = _playlists.first.audioDetails;
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all.where((a) => a.audioTitle.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadIcon();
    _loadPlaylistDetails();
  }

  @override
  void dispose() {
    _searchController.dispose(); // FIX-6
    super.dispose();
  }

  // ── Icon loader ─────────────────────────────────────────────────────────────

  Future<void> _loadIcon() async {
    try {
      final icon = await IconService.fetchIcon();
      if (!mounted) return;
      setState(() => iconData = icon);
    } catch (e) {
      print('Error loading icon: $e');
    }
  }

  // ── Playlist data loader ────────────────────────────────────────────────────

  Future<void> _loadPlaylistDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<PlaylistDTO> playlistData =
          await PlaylistService().getPlaylistWithAudioDetails(widget.playlistId);
      print('PlaylistData: $playlistData');

      if (playlistData.isNotEmpty) {
        await Future.wait(
          playlistData.map((playlist) async {
            print('Audio details: ${playlist.audioDetails}');
            await _loadAudioImages(playlist.audioDetails);
          }),
        );

        if (!mounted) return;
        // FIX-5: collapsed into one setState
        setState(() {
          _playlists = playlistData;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Playlist not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load playlist: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // ── Image loader ────────────────────────────────────────────────────────────

  Future<void> _loadAudioImages(List<LikedsongsDTO> audioDetails) async {
    for (final audio in audioDetails) {
      try {
        final audioDesc = await AudioApiService().fetchAudioDetails(audio.audioId);
        if (audioDesc != null) {
          final image = await audioDesc.thumbnailImage;
          if (image != null && mounted) {
            setState(() => audioImages[audio.audioId] = image);
          }
        }
      } catch (e) {
        print('Error loading image for audio ${audio.audioId}: $e');
      }
    }
  }

  Widget _buildAudioImage(LikedsongsDTO audio) {
    final bytes = audioImages[audio.audioId];
    if (bytes != null) {
      return Image.memory(bytes, height: 50, width: 50, fit: BoxFit.cover);
    }
    return Container(
      height: 50,
      width: 50,
      color: Colors.grey[850],
      child: const Icon(Icons.music_note_rounded, color: Colors.white),
    );
  }

  // ── Song row context menu ───────────────────────────────────────────────────

  void _showMenu(BuildContext context, LikedsongsDTO audio, int playlistId) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
            button.size.bottomCenter(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: Colors.grey[700],
      items: [
        const PopupMenuItem(
          value: 'move',
          child: Text('Move to playlist',
              style: TextStyle(color: Colors.white)),
        ),
        const PopupMenuItem(
          value: 'remove',
          child: Text('Remove', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    ).then((value) async {
      if (value == 'move') {
        _showMoveDialog(context, playlistId, audio.audioId);
      } else if (value == 'remove') {
        await PlaylistService()
            .removeAudioFromPlaylist(playlistId, audio.audioId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio removed from this playlist')),
        );
        await _loadPlaylistDetails();
      }
    });
  }

  // ── Move dialog ─────────────────────────────────────────────────────────────

  Future<void> _showMoveDialog(
      BuildContext context, int currentPlaylistId, int audioId) async {
    final userId = await Service().getLoggedInUserId();
    if (userId == null) return;
    final playlists = await PlaylistService().getPlaylistsByUserId(userId);
    int? selectedPlaylistId;

    await showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(180, 60, 60, 60),
          title: const Text('Move to Playlist',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final pl in playlists)
                if (pl.id != currentPlaylistId)
                  ListTile(
                    leading: const Icon(Icons.playlist_play_rounded,
                        color: Colors.white),
                    title: Text(pl.title,
                        style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      selectedPlaylistId = pl.id;
                      Navigator.of(ctx).pop();
                    },
                  ),
              if (playlists
                  .where((pl) => pl.id != currentPlaylistId)
                  .isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No other playlists available.',
                      style: TextStyle(color: Colors.white70)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );

    if (selectedPlaylistId != null) {
      await PlaylistService().moveAudioToPlaylist(
          currentPlaylistId, audioId, selectedPlaylistId!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio moved successfully')),
      );
      await _loadPlaylistDetails();
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            BackgroundImage(),
            // FIX-2: back arrow shown even during loading
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                  onPressed: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                ),
              ),
            ),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    // Error state
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            BackgroundImage(),
            SafeArea(
              child: Column(
                children: [
                  // FIX-2: back arrow in error state
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 12),
                          Text(_error!,
                              style:
                                  const TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadPlaylistDetails,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // FIX-5: guard against empty list (shouldn't happen after error handling above)
    if (_playlists.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            BackgroundImage(),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                  onPressed: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                ),
              ),
            ),
            const Center(
              child: Text('Playlist not found',
                  style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      );
    }

    final playlistTitle = _playlists.first.title;
    final filtered = _filteredAudios; // FIX-3

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackgroundImage(),
          SafeArea(
            child: Column(
              children: [
                // ── FIX-1 + FIX-2 + FIX-7: Clean AppBar ──────────────────────
                // Back arrow is always present.
                // FIX-1: removed broken Image.asset fallback.
                // FIX-7: Row constraints prevent overflow.
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  title: _showSearch
                      // ── Search mode: full-width text field ──────────────────
                      ? Row(
                          children: [
                            // FIX-2: back arrow visible in search mode too
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white),
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Search songs...',
                                  hintStyle:
                                      TextStyle(color: Colors.white60),
                                  border: InputBorder.none,
                                ),
                                // FIX-3: update query → triggers filtered rebuild
                                onChanged: (value) {
                                  setState(() => _searchQuery = value);
                                },
                              ),
                            ),
                          ],
                        )
                      // ── Normal mode ─────────────────────────────────────────
                      : Row(
                          children: [
                            // FIX-2: permanent back arrow
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white),
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            // FIX-1: replaced broken Image.asset with safe icon widget
                            if (iconData != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.memory(
                                  iconData!.imageBytes,
                                  height: 36,
                                  width: 36,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              const Icon(Icons.music_note_rounded,
                                  color: Colors.white70, size: 28),
                            const Spacer(),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.cast_connected_rounded,
                                  color: Colors.white),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.notifications,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                  // FIX-3: search toggle — also clears query when closing
                  actions: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showSearch = !_showSearch;
                          if (!_showSearch) {
                            _searchController.clear();
                            _searchQuery = ''; // FIX-3: reset filter
                          }
                        });
                      },
                      icon: Icon(
                        _showSearch ? Icons.close : Icons.search_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),

                // ── Playlist title ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      playlistTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),

                // ── Song count / search hint ───────────────────────────────────
                if (_showSearch && _searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${filtered.length} result${filtered.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                    ),
                  ),

                // ── Song list ─────────────────────────────────────────────────
                Expanded(
                  child: _playlists.first.audioDetails.isEmpty
                      ? const Center(
                          child: Text('No songs in this playlist',
                              style: TextStyle(color: Colors.white70)),
                        )
                      // FIX-3 + FIX-4: show filtered list, "No songs found" fallback
                      : filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.search_off_rounded,
                                      color: Colors.white38, size: 48),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No songs found for "$_searchQuery"',
                                    style: const TextStyle(
                                        color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final audio = filtered[index];

                                return ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _buildAudioImage(audio),
                                  ),
                                  title: Text(
                                    audio.audioTitle,
                                    style: const TextStyle(
                                        color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Builder(
                                    builder: (btnCtx) => IconButton(
                                      onPressed: () => _showMenu(
                                        btnCtx,
                                        audio,
                                        _playlists.first.playlistId,
                                      ),
                                      icon: const Icon(
                                          Icons.more_vert_rounded,
                                          color: Colors.white),
                                    ),
                                  ),
                                  onTap: () async {
                                    try {
                                      // Show loading indicator
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) => const Center(
                                            child:
                                                CircularProgressIndicator()),
                                      );

                                      final selectedAudio =
                                          await AudioApiService()
                                              .fetchAudioDetails(
                                                  audio.audioId);
                                      await selectedAudio.fetchImage();

                                      final audioProvider =
                                          Provider.of<AudioProvider>(
                                              context,
                                              listen: false);
                                      audioProvider
                                          .updateCurrentlyPlayingSong(
                                              selectedAudio);
                                      final playlistAudios = audioProvider
                                          .convertPlaylistToAudioDescriptions(
                                              _playlists.first.audioDetails);
                                      await audioProvider
                                          .setCurrentlyPlayingSong(
                                              selectedAudio, playlistAudios);

                                      if (context.mounted &&
                                          Navigator.canPop(context)) {
                                        Navigator.pop(context); // dismiss dialog
                                      }

                                      if (!context.mounted) return;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SongPlayerPage(
                                            music: selectedAudio,
                                            onChange: (newAudio) {
                                              if (!mounted) return;
                                              setState(() {
                                                final i = _playlists.first
                                                    .audioDetails
                                                    .indexWhere((a) =>
                                                        a.audioId ==
                                                        newAudio.id);
                                                if (i != -1) {
                                                  _playlists.first
                                                      .audioDetails[i] =
                                                      LikedsongsDTO(
                                                    audioId: newAudio.id,
                                                    audioTitle:
                                                        newAudio.audioTitle,
                                                  );
                                                }
                                              });
                                            },
                                            onDislike: (_) {},
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      print(
                                          'Error fetching audio details: $e');
                                      // Dismiss dialog if open
                                      if (context.mounted &&
                                          Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}