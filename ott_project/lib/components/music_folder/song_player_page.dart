import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ott_project/components/library/audio_playlist.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/components/music_folder/audio_provider.dart' as ap;
import 'package:ott_project/components/library/liked_songs_page.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:ott_project/service/service.dart';
import 'package:provider/provider.dart';
import '../background_image.dart';
import 'music_listen_again.dart';
import 'recently_played.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongPlayerPage extends StatefulWidget {
  final AudioDescription music;
  final Function(AudioDescription) onChange;
  final List<AudioDescription> musicList;
  final Function(AudioDescription) onDislike;

  const SongPlayerPage({
    Key? key,
    required this.music,
    this.musicList = const [],
    required this.onChange,
    required this.onDislike,
  }) : super(key: key);

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  int? currentUserId;

  // NOTE: No local AudioPlayer, no local duration/position, no local isLiked.
  // All of these come from Consumer<ap.AudioProvider> below.
  // Creating a second AudioPlayer here was the root cause of:
  //   - Two simultaneous audio streams playing
  //   - setState() on unmounted widget → UI freeze after back navigation
  //   - Local liked state that never synced with LikedSongsPage

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<ap.AudioProvider>(context, listen: false);
    provider.loadPlaylistsFromLocal();
    provider.fetchUserPlaylists();

    // Load the user ID first, then use it to populate the provider's liked set.
    // FIX B — The original called _checkLikedStatus() immediately in initState
    // while likedSongIds was still empty (not yet loaded from API), which forced
    // isLiked = false right away — causing the auto-dislike bug.
    // Now we load the provider's central set which is already populated (or we
    // wait for it), and read isLiked() only inside Consumer where it's reactive.
    _getCurrentUserId().then((_) {
      if (currentUserId != null && mounted) {
        provider.loadLikedSongs(currentUserId!);
      }
    });

    // Start playback after the first frame so the widget tree is fully built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ap.AudioProvider>(context, listen: false)
            .setCurrentlyPlayingSong(widget.music, widget.musicList);
      }
    });
  }

  // FIX G+H — No dispose() override needed because we have no local AudioPlayer
  // and no local stream subscriptions to cancel. The provider's player persists
  // across pages (correct behaviour — music continues playing in the background bar).

  Future<void> _getCurrentUserId() async {
    final id = await Service().getLoggedInUserId();
    if (mounted) setState(() => currentUserId = id);
  }

  // FIX B+C — _toggleLike now delegates entirely to the provider.
  // The provider holds the single source of truth for liked state and handles
  // optimistic update + rollback internally. No local isLiked bool, no race
  // condition, no auto-dislike.
  Future<void> _toggleLike() async {
    if (currentUserId == null) return;
    final provider = Provider.of<ap.AudioProvider>(context, listen: false);
    final id = provider.audioDescriptioncurrently?.id ?? widget.music.id;
    final currentlyLiked = provider.isLiked(id);

    bool success;
    if (currentlyLiked) {
      success = await provider.unlikeAudio(id, currentUserId!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Song removed from likes')));
      }
    } else {
      success = await provider.likeAudio(id, currentUserId!);
      if (success && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Song added to likes')));
      }
    }

    if (success) widget.onChange(widget.music);
  }

  // FIX — Back button does NOT stop audio.
  // Music should keep playing behind the CurrentlyPlayingBar.
  // The old code had dispose() commented out but also attached listeners to a
  // local player that was never disposed, leaking native resources.
  void _handleBack() {
    widget.onDislike(widget.music);
    Navigator.pop(context);
    // Do NOT call audioPlayer.stop() here — the provider's player continues.
  }

  String formatTime(Duration d) {
    String pad(int n) => n.toString().padLeft(2, '0');
    final h = pad(d.inHours);
    final m = pad(d.inMinutes.remainder(60));
    final s = pad(d.inSeconds.remainder(60));
    return [if (d.inHours > 0) h, m, s].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Consumer<ap.AudioProvider>(
        builder: (context, provider, _) {
          final currentAudio = provider.audioDescriptioncurrently;

          if (currentAudio == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final isPlaying = provider.isPlaying;
          final duration = provider.duration;
          final position = provider.position;

          // FIX A — Read from the central liked set; updates everywhere instantly.
          final isLiked = provider.isLiked(currentAudio.id);

          IconData repeatIcon;
          Color repeatColor;
          switch (provider.repeatModeSong) {
            case ap.RepeatMode.off:
              repeatIcon = Icons.repeat;
              repeatColor = Colors.white;
              break;
            case ap.RepeatMode.all:
              repeatIcon = Icons.repeat;
              repeatColor = Colors.green;
              break;
            case ap.RepeatMode.one:
              repeatIcon = Icons.repeat_one;
              repeatColor = Colors.green;
              break;
          }

          return SafeArea(
            child: Stack(
              children: [
                const BackgroundImage(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── AppBar ────────────────────────────────────────────
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      leading: IconButton(
                        onPressed: _handleBack,
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () => _showDrawer(context),
                          icon: const Icon(Icons.more_vert_rounded,
                              color: Colors.white),
                        ),
                      ],
                    ),

                    // ── Album art ─────────────────────────────────────────
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[800],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: currentAudio.thumbnail != null
                            ? Image.memory(currentAudio.thumbnail!,
                                fit: BoxFit.fill)
                            : currentAudio.bannerthumbnail != null
                                ? Image.memory(currentAudio.bannerthumbnail!,
                                    fit: BoxFit.fill)
                                : Image.asset(
                                    'assets/icon/media_jungle.png'),
                      ),
                    ),

                    SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.02),

                    // ── Title ─────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        currentAudio.audioTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

                    SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.02),

                    // ── Like / Playlist / Share ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: _toggleLike,
                          icon: Icon(
                            isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isLiked ? Colors.red : Colors.white,
                            size: 30,
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              _showCreatePlaylistOption(context),
                          icon: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: Colors.white,
                              size: 30),
                        ),
                        IconButton(
                          onPressed: () =>
                              Share.share(currentAudio.audioTitle),
                          icon: const Icon(Icons.share_rounded,
                              color: Colors.white, size: 30),
                        ),
                      ],
                    ),

                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Text('Like',
                                style: TextStyle(color: Colors.white)),
                            Text('Playlist',
                                style: TextStyle(color: Colors.white)),
                            Text('Share',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.02),

                    // ── Seek bar ──────────────────────────────────────────
                    Slider(
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds
                          .toDouble()
                          .clamp(0, duration.inSeconds.toDouble()),
                      onChanged: (v) =>
                          provider.seekTo(Duration(seconds: v.toInt())),
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey,
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatTime(position),
                              style:
                                  const TextStyle(color: Colors.white)),
                          Text(formatTime(duration),
                              style:
                                  const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),

                    SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.02),

                    // ── Playback controls ─────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: provider.toggleShuffleSong,
                          icon: Icon(Icons.shuffle_rounded,
                              color: provider.isShuffleOn
                                  ? Colors.green
                                  : Colors.white,
                              size: 40),
                        ),
                        IconButton(
                          onPressed: provider.playPreviousSong,
                          icon: const Icon(Icons.skip_previous_rounded,
                              color: Colors.white, size: 40),
                        ),
                        IconButton(
                          onPressed: provider.playPauseSong,
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_filled_rounded,
                            color: Colors.white,
                            size: 45,
                          ),
                        ),
                        IconButton(
                          onPressed: provider?.playNextSong,
                          icon: const Icon(Icons.skip_next_rounded,
                              color: Colors.white, size: 40),
                        ),
                        IconButton(
                          onPressed: provider.toggleRepeatSong,
                          icon: Icon(repeatIcon,
                              color: repeatColor, size: 40),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('LYRICS',
                              style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('RELATED',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Bottom sheets ─────────────────────────────────────────────────────────

  void _showDrawer(BuildContext context) {
    final provider = Provider.of<ap.AudioProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.8),
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white),
              title: const Text('Add to Playlist',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showCreatePlaylistOption(context);
                provider.fetchPlaylists();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded,
                  color: Color.fromARGB(255, 229, 191, 191)),
              title: const Text('Share',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Share.share(widget.music.audioTitle);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePlaylistOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.8),
      builder: (ctx) {
        final provider = Provider.of<ap.AudioProvider>(ctx, listen: false);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.white),
                  title: const Text('Create Playlist',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreatePlaylistDialog(context);
                    provider.fetchPlaylists();
                  },
                ),
                ...provider.aplaylists.map((playlist) {
                  final inPlaylist =
                      playlist.audioIds.any((id) => id == widget.music.id);
                  return ListTile(
                    leading: const Icon(Icons.playlist_play_rounded,
                        color: Colors.white),
                    title: Text(playlist.title,
                        style:
                            const TextStyle(color: Colors.white)),
                    trailing: inPlaylist
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: inPlaylist
                        ? null
                        : () {
                            provider.addAudiosToPlaylist(
                                playlist, widget.music.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Added to ${playlist.title}')),
                            );
                          },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, {int? audioId}) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          backgroundColor: const Color.fromARGB(69, 178, 174, 174),
          title: const Text('New playlist',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.white60),
                    enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.white60)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.02),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    hintStyle: TextStyle(color: Colors.white60),
                    enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.white60)),
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;
                try {
                  final provider =
                      Provider.of<ap.AudioProvider>(ctx, listen: false);
                  provider.createPlayListWithAudioId(
                      title, descCtrl.text.trim(), widget.music.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Playlist "$title" created')),
                  );
                } catch (e) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Failed: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text('Create',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}