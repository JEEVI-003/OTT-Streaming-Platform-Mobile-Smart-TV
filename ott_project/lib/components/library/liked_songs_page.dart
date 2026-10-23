// ─────────────────────────────────────────────────────────────────────────────
// liked_songs_page.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/components/music_folder/audio_provider.dart';
import 'package:ott_project/service/audio_api_service.dart';
import 'package:ott_project/service/service.dart';
import 'package:provider/provider.dart';
import '../music_folder/song_player_page.dart';

class LikedSongsPage extends StatefulWidget {
  final int userId;

  const LikedSongsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _LikedSongsPageState createState() => _LikedSongsPageState();
}

class _LikedSongsPageState extends State<LikedSongsPage> {
  List<AudioDescription> _allAudios = [];
  List<AudioDescription> _filteredAudios = [];
  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLikedAudios();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAudios = query.isEmpty
          ? List.from(_allAudios)
          : _allAudios
              .where((a) => a.audioTitle.toLowerCase().contains(query))
              .toList();
    });
  }

  Future<void> _fetchLikedAudios() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<int> likedIds =
          await AudioApiService().getLikedSongs(widget.userId);

      // FIX F — Sync fetched IDs into the provider's central set so that
      // provider.isLiked(id) returns correct values in every Consumer below.
      if (mounted) {
        final provider = Provider.of<AudioProvider>(context, listen: false);
        await provider.loadLikedSongs(widget.userId);
      }

      // Fetch audio details in parallel
      final List<AudioDescription?> results = await Future.wait(
        likedIds.map((id) async {
          try {
            return await AudioApiService().fetchAudioDetails(id);
          } catch (_) {
            return null;
          }
        }),
      );

      final List<AudioDescription> audios =
          results.whereType<AudioDescription>().toList();

      // Pre-fetch thumbnails in parallel
      await Future.wait(
        audios.map((audio) async {
          try {
            await audio.fetchImage();
          } catch (_) {}
        }),
      );

      if (!mounted) return;
      setState(() {
        _allAudios = audios;
        _filteredAudios = List.from(audios);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load liked songs';
        _isLoading = false;
      });
    }
  }

  Widget _buildAudioItem(AudioDescription audio, int index) {
    // FIX F — Each tile is wrapped in Consumer<AudioProvider> so the heart
    // icon updates live whenever liked/unliked from inside SongPlayerPage
    // or from the trailing button below, without needing a full page reload.
    return Consumer<AudioProvider>(
      builder: (context, provider, _) {
        final isLiked = provider.isLiked(audio.id);

        return ListTile(
          // ── Thumbnail ──────────────────────────────────────────────
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: audio.thumbnail != null
                ? Image.memory(audio.thumbnail!,
                    width: 50, height: 50, fit: BoxFit.cover)
                : Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note,
                        color: Colors.white54),
                  ),
          ),

          // ── Song info ───────────────────────────────────────────────
          title: Text(
            audio.audioTitle,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: audio.movieName != null
              ? Text(
                  audio.movieName!,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,

          // ── Unlike button ───────────────────────────────────────────
          // Pressing the heart here delegates to the provider (optimistic).
          // The Consumer rebuilds immediately without setState().
          // After a successful unlike we remove the item from the local list.
          trailing: IconButton(
            icon: Icon(
              isLiked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isLiked ? Colors.red : Colors.white54,
            ),
            onPressed: () async {
              final userId = await Service().getLoggedInUserId();
              if (userId == null || !mounted) return;
              if (isLiked) {
                final success =
                    await provider.unlikeAudio(audio.id, userId);
                if (success && mounted) {
                  setState(() {
                    _allAudios.removeWhere((a) => a.id == audio.id);
                    _filteredAudios
                        .removeWhere((a) => a.id == audio.id);
                  });
                }
              } else {
                await provider.likeAudio(audio.id, userId);
              }
            },
          ),

          // ── Open player ─────────────────────────────────────────────
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SongPlayerPage(
                  music: audio,
                  musicList: _filteredAudios,
                  // FIX E — onDislike is called when the user presses back.
                  // The old code called removeWhere inside onDislike, which
                  // deleted the song from the list every time the user simply
                  // navigated back — even if they hadn't unliked anything.
                  // Now we just refresh from the server so the list reflects
                  // any actual like/unlike changes made inside the player.
                  onDislike: (_) => _fetchLikedAudios(),
                  onChange: (_) => _fetchLikedAudios(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const BackgroundImage(),
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Liked Songs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Search bar ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style:
                          const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Search songs...',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search,
                            color: Colors.black54),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Content ────────────────────────────────────────
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator())
                      : _error != null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_error!,
                                      style: const TextStyle(
                                          color: Colors.white)),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: _fetchLikedAudios,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : _filteredAudios.isEmpty
                              ? const Center(
                                  child: Text('No liked songs yet',
                                      style: TextStyle(
                                          color: Colors.white70)),
                                )
                              : RefreshIndicator(
                                  onRefresh: _fetchLikedAudios,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(
                                        bottom: 20),
                                    itemCount:
                                        _filteredAudios.length,
                                    itemBuilder: (context, index) =>
                                        _buildAudioItem(
                                            _filteredAudios[index],
                                            index),
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
}