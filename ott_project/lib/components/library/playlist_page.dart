import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/library/audio_playlist.dart';
import 'package:ott_project/components/library/playlist_detail.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/components/music_folder/audio_provider.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:ott_project/service/playlist_service.dart';
import 'package:ott_project/service/service.dart';
import 'package:provider/provider.dart';

class PlayListPage extends StatefulWidget {
  const PlayListPage({super.key});

  @override
  State<PlayListPage> createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {
  // Loaded playlists + their first-song thumbnail (pre-fetched, never re-fetched)
  List<AudioPlaylist> _playlists = [];
  // Cache: playlistId → first audio thumbnail bytes (null = no image)
  final Map<int, Uint8List?> _thumbCache = {};

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPlaylists();
  }

  // ── Fetch playlists then prefetch first-song thumbnails in parallel ───────
  Future<void> _fetchPlaylists() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final int? userId = await Service().getLoggedInUserId();
      if (userId == null) throw Exception('Not logged in');

      final List<AudioPlaylist> playlists =
          await PlaylistService().getPlaylistsByUserId(userId);

      // Prefetch first-audio thumbnail for each playlist IN PARALLEL
      await Future.wait(playlists.map(_prefetchThumb));

      if (!mounted) return;
      setState(() {
        _playlists = playlists;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load playlists';
        _isLoading = false;
      });
    }
  }

  Future<void> _prefetchThumb(AudioPlaylist playlist) async {
    if (_thumbCache.containsKey(playlist.id)) return;
    try {
      if (playlist.audioIds.isEmpty) {
        _thumbCache[playlist.id] = null;
        return;
      }
      // Only fetch the FIRST audio for the cover image
      final audios = await playlist.getAudios();
      if (audios.isEmpty) {
        _thumbCache[playlist.id] = null;
        return;
      }
      await audios.first.fetchImage();
      _thumbCache[playlist.id] = audios.first.thumbnail;
    } catch (_) {
      _thumbCache[playlist.id] = null;
    }
  }

  // ── Thumbnail widget — reads from cache, no network call ─────────────────
  Widget _thumbWidget(int playlistId) {
    final bytes = _thumbCache[playlistId];
    if (bytes != null) {
      return Image.memory(bytes, width: 65, height: 65, fit: BoxFit.cover);
    }
    return Container(
      width: 65,
      height: 65,
      color: Colors.grey[850],
      child: const Icon(Icons.music_note_rounded, color: Colors.white54, size: 30),
    );
  }

  // ── Delete playlist ───────────────────────────────────────────────────────
  Future<void> _deletePlaylist(int playlistId) async {
    final result = await PlaylistService().deletePlaylist(playlistId);
    if (!mounted) return;
    setState(() {
      _playlists.removeWhere((p) => p.id == playlistId);
      _thumbCache.remove(playlistId);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result)));
  }

  // ── Edit playlist dialog ──────────────────────────────────────────────────
  void _showEditDialog(int playlistId,
      {String? initialTitle, String? initialDescription}) {
    final titleCtrl = TextEditingController(text: initialTitle);
    final descCtrl = TextEditingController(text: initialDescription);

    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(180, 50, 50, 50),
          title:
              const Text('Edit Playlist', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogTextField(titleCtrl, 'Title'),
              const SizedBox(height: 12),
              _dialogTextField(descCtrl, 'Description'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                if (titleCtrl.text.isNotEmpty) {
                  await PlaylistService()
                      .updatePlaylist(playlistId, titleCtrl.text, descCtrl.text);
                  if (!mounted) return;
                  Navigator.pop(context);
                  _fetchPlaylists();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Playlist updated')));
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Create playlist dialog ────────────────────────────────────────────────
  void _showCreateDialog(BuildContext context, {int? audioId}) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(180, 50, 50, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title:
              const Text('New Playlist', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogTextField(titleCtrl, 'Title'),
              const SizedBox(height: 12),
              _dialogTextField(descCtrl, 'Description'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty) return;
                Navigator.pop(dialogCtx);

                try {
                  final audioProvider =
                      Provider.of<AudioProvider>(context, listen: false);
                  if (audioId != null) {
                    audioProvider.createPlayListWithAudioId(
                        titleCtrl.text, descCtrl.text, audioId);
                  } else {
                    audioProvider.createPlayList(
                        titleCtrl.text, descCtrl.text);
                  }
                  await Future.delayed(const Duration(milliseconds: 500));
                  await _fetchPlaylists();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Playlist "${titleCtrl.text}" created')));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Error creating playlist'),
                      backgroundColor: Colors.red,
                    ));
                  }
                }
              },
              child:
                  const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white60)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  // ── Single playlist row ───────────────────────────────────────────────────
  Widget _buildPlaylistItem(AudioPlaylist playlist) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlaylistDetailsPage(
              playlist: playlist, playlistId: playlist.id),
        ),
      ).then((_) => _fetchPlaylists()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Thumbnail — from cache, no FutureBuilder
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _thumbWidget(playlist.id),
            ),
            const SizedBox(width: 16),

            // Title + song count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${playlist.audioIds.length} song${playlist.audioIds.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  if (playlist.description.isNotEmpty)
                    Text(
                      playlist.description,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // 3-dot menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              color: Colors.grey[800],
              onSelected: (value) async {
                if (value == 'edit') {
                  final details = await PlaylistService()
                      .getPlaylistById(playlist.id);
                  if (!mounted) return;
                  _showEditDialog(playlist.id,
                      initialTitle: details?['title'],
                      initialDescription: details?['description']);
                } else if (value == 'delete') {
                  _deletePlaylist(playlist.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Edit', style: TextStyle(color: Colors.white)),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              const BackgroundImage(),
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            'Playlists',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // Add playlist button
                          IconButton(
                            icon: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 26),
                            onPressed: () {
                              final currentAudioId =
                                  audioProvider.audioDescriptioncurrently?.id;
                              _showCreateDialog(context,
                                  audioId: currentAudioId);
                            },
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.white12, height: 1),

                    // Content
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _error != null
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.wifi_off,
                                          color: Colors.white38, size: 48),
                                      const SizedBox(height: 12),
                                      Text(_error!,
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: _fetchPlaylists,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Retry'),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white12),
                                      ),
                                    ],
                                  ),
                                )
                              : _playlists.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.playlist_add,
                                              color: Colors.white24, size: 64),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'No playlists yet',
                                            style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Tap + to create one',
                                            style: TextStyle(
                                                color: Colors.white38,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    )
                                  : RefreshIndicator(
                                      onRefresh: _fetchPlaylists,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.only(
                                            top: 8, bottom: 24),
                                        itemCount: _playlists.length,
                                        itemBuilder: (_, i) =>
                                            _buildPlaylistItem(_playlists[i]),
                                      ),
                                    ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}