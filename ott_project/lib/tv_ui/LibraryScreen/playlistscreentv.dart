import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ott_project/components/library/audio_playlist.dart';
import 'package:ott_project/service/playlist_service.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/LibraryScreen/TvplaylistDetail.dart';

class TVPlayListPage extends StatefulWidget {
  final int userId;
  const TVPlayListPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<TVPlayListPage> createState() => _TVPlayListPageState();
}

class _TVPlayListPageState extends State<TVPlayListPage> {
  List<AudioPlaylist> _playlists = [];
  bool _isLoading = true;
  final Map<int, Uint8List?> _playlistImageCache = {};

  @override
  void initState() {
    super.initState();
    _fetchPlaylists();
    _setupPlaylistSelectionHandler();
    FocusManagerService.globalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    FocusManagerService.globalFocusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  void _setupPlaylistSelectionHandler() {
    FocusManagerService.onMyPlaylistSelect = (int playlistIndex) {
      if (playlistIndex >= 0 && playlistIndex < _playlists.length && mounted) {
        _navigateToPlaylistDetails(_playlists[playlistIndex]);
      }
    };
  }

  Future<void> _fetchPlaylists() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final playlists =
          await PlaylistService().getPlaylistsByUserId(widget.userId);
      await _preloadPlaylistImages(playlists);
      if (mounted) {
        setState(() {
          _playlists = playlists;
          FocusManagerService.updatePlaylistCount(playlists.length);
        });
      }
    } catch (e) {
      debugPrint('Error fetching playlists: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _preloadPlaylistImages(List<AudioPlaylist> playlists) async {
    for (final playlist in playlists) {
      if (_playlistImageCache.containsKey(playlist.id)) continue;
      try {
        final audios = await playlist.getAudios();
        if (audios.isNotEmpty) {
          final image = await audios[0].thumbnailImage;
          _playlistImageCache[playlist.id] = image;
        }
      } catch (e) {
        debugPrint('Error loading image for playlist ${playlist.id}: $e');
      }
    }
  }

  // ── FIXED: image now fills the full card with no empty space ──────────────
  Widget _buildPlaylistCard(AudioPlaylist playlist, bool isFocused) {
    final cachedImage = _playlistImageCache[playlist.id];
    return Card(
      color: isFocused ? Colors.blue.shade700 : Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge, // clips image to card rounded corners
      child: GestureDetector(
        onTap: () => _navigateToPlaylistDetails(playlist),
        child: Stack(
          fit: StackFit.expand, // Stack fills entire card
          children: [
            // Image fills full card — no fixed width/height
            cachedImage != null
                ? Image.memory(
                    cachedImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildMusicPlaceholder(),
                  )
                : _buildMusicPlaceholder(),

            // Dark gradient for readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 8,
              right: 40,
              child: Text(
                playlist.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            // Focus border
            if (isFocused)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 143, 228, 0),
                        width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            Positioned(
              bottom: 4,
              right: 4,
              child: _buildPopupMenuButton(playlist),
            ),
          ],
        ),
      ),
    );
  }

  // ── FIXED: no fixed width/height — fills whatever space is given ──────────
  Widget _buildMusicPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.music_note_rounded, color: Colors.white, size: 50),
      ),
    );
  }

  PopupMenuButton<Map<String, dynamic>> _buildPopupMenuButton(
      AudioPlaylist playlist) {
    return PopupMenuButton<Map<String, dynamic>>(
      color: Colors.grey[700],
      onSelected: (value) =>
          _handlePopupMenuSelection(value, playlist.id),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: {'action': 'edit'},
          child: Text('Edit', style: TextStyle(color: Colors.white)),
        ),
        const PopupMenuItem(
          value: {'action': 'delete'},
          child: Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
    );
  }

  Future<void> _handlePopupMenuSelection(
      Map<String, dynamic> value, int playlistId) async {
    final action = value['action'];
    if (action == 'edit') {
      final details = await PlaylistService().getPlaylistById(playlistId);
      if (details != null && mounted) {
        _showEditPlaylistDialog(
          context,
          playlistId: playlistId,
          initialTitle: details['title'] ?? '',
          initialDescription: details['description'] ?? '',
        );
      }
    } else if (action == 'delete' && mounted) {
      await _deletePlaylist(playlistId);
    }
  }

  Future<void> _deletePlaylist(int playlistId) async {
    final result = await PlaylistService().deletePlaylist(playlistId);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
      await _fetchPlaylists();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePlaylistDialog(context),
        backgroundColor: const Color.fromARGB(255, 143, 228, 0),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Create Playlist',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Library',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Playlists',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _playlists.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.queue_music,
                                  color: Colors.white54, size: 64),
                              const SizedBox(height: 16),
                              const Text('No playlists yet',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18)),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _showCreatePlaylistDialog(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 143, 228, 0),
                                  foregroundColor: Colors.black,
                                ),
                                icon: const Icon(Icons.add),
                                label:
                                    const Text('Create your first playlist'),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.02,
                            left: MediaQuery.of(context).size.width * 0.01,
                          ),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: _playlists.length,
                            itemBuilder: (context, index) {
                              final isFocused =
                                  FocusManagerService.isMyPlaylistFocused &&
                                      FocusManagerService
                                              .selectedMyPlaylistIndex ==
                                          index;
                              return _buildPlaylistCard(
                                  _playlists[index], isFocused);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPlaylistDetails(AudioPlaylist playlist) {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(
          builder: (context) => TVPlaylistDetailsPage(
            playlist: playlist,
            playlistId: playlist.id,
          ),
        ))
        .then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusManagerService.currentPage = 0;
        if (mounted) _fetchPlaylists();
      });
    });
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(220, 30, 30, 50),
          title: const Text('Create Playlist',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Playlist name',
                    hintStyle: TextStyle(color: Colors.white60),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Description (optional)',
                    hintStyle: TextStyle(color: Colors.white60),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 143, 228, 0),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a playlist name')),
                  );
                  return;
                }
                try {
                  await PlaylistService().createPlayList(
                    title: title,
                    description: descriptionController.text.trim(),
                    userId: widget.userId,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Playlist created successfully!')),
                    );
                    await _fetchPlaylists();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Create',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPlaylistDialog(
    BuildContext context, {
    required int playlistId,
    required String initialTitle,
    required String initialDescription,
  }) {
    final titleController = TextEditingController(text: initialTitle);
    final descriptionController =
        TextEditingController(text: initialDescription);

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(220, 30, 30, 50),
          title: const Text('Edit Playlist',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.white60),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    hintStyle: TextStyle(color: Colors.white60),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 143, 228, 0),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  await PlaylistService().updatePlaylist(
                      playlistId, title, descriptionController.text.trim());
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Playlist updated successfully')),
                    );
                    await _fetchPlaylists();
                  }
                }
              },
              child: const Text('Save',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}