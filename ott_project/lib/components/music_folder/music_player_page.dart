import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/components/music_folder/audio_provider.dart';
import 'package:ott_project/components/library/liked_songs_page.dart';
import 'package:ott_project/components/music_folder/listen_again.dart';
import 'package:ott_project/components/music_folder/recently_played_manager.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:ott_project/components/music_folder/audio.dart';
import 'package:ott_project/service/service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../background_image.dart';

class MusicPlayerPage extends StatefulWidget {
  final AudioDescription audio;
  final Function(AudioDescription) onChange;
  final List<AudioDescription> audioList;
  final Function(AudioDescription) onDislike;

  const MusicPlayerPage({
    Key? key,
    required this.audio,
    this.audioList = const [],
    required this.onChange,
    required this.onDislike,
  }) : super(key: key);

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  int? currentUserId;

  // NOTE: No local AudioPlayer, no local duration/position, no local isLiked.
  //
  // FIX D — The original created `late AudioPlayer audioPlayer` and attached
  // duration/position listeners, but never disposed it. An undisposed AudioPlayer
  // holds native platform channels open, and its event listeners keep calling
  // setState() on the dead widget after navigation — freezing subsequent pages.
  //
  // FIX G/H — All playback state now comes from Consumer<AudioProvider>.
  // The provider's single AudioPlayer is shared across all pages.

  @override
  void initState() {
    super.initState();

    // Load liked songs into the provider's central set so the heart is correct
    // on open without a race condition.
    _getCurrentUserId().then((_) {
      if (currentUserId != null && mounted) {
        Provider.of<AudioProvider>(context, listen: false)
            .loadLikedSongs(currentUserId!);
      }
    });

    // Start playback (if coming from a list).
    // For MusicPlayerPage the caller typically already called
    // setCurrentlyPlayingSong() before navigating, so we just ensure
    // the provider has the right song set.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.audioList.isNotEmpty) {
        Provider.of<AudioProvider>(context, listen: false)
            .setCurrentlyPlayingSong(widget.audio, widget.audioList);
      }
    });
  }

  // FIX D — dispose() is correctly implemented (not commented out).
  // We have no local resources to clean up (no local AudioPlayer),
  // so a simple super.dispose() is sufficient.
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getCurrentUserId() async {
    final id = await Service().getLoggedInUserId();
    if (mounted) setState(() => currentUserId = id);
  }

  // FIX A+B — Like/unlike delegates to provider; no local isLiked bool,
  // no race condition, no auto-dislike.
  Future<void> _toggleLike() async {
    if (currentUserId == null) return;
    final provider = Provider.of<AudioProvider>(context, listen: false);
    final id = provider.audioDescriptioncurrently?.id ?? widget.audio.id;
    final currentlyLiked = provider.isLiked(id);

    bool success;
    if (currentlyLiked) {
      success = await provider.unlikeAudio(id, currentUserId!);
      if (success && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Song removed')));
      }
    } else {
      success = await provider.likeAudio(id, currentUserId!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Song added to likes')));
        widget.onChange(widget.audio);
      }
    }
  }

  // Back button — does not stop audio (music continues in the background bar).
  void _handleBack() {
    widget.onDislike(widget.audio);
    Navigator.pop(context);
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
    return Consumer<AudioProvider>(
      builder: (context, provider, _) {
        final currentAudio = provider.audioDescriptioncurrently;

        if (currentAudio == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isPlaying = provider.isPlaying;
        final duration = provider.duration;
        final position = provider.position;

        // FIX A — Read from the central liked set; reactive everywhere.
        final isLiked = provider.isLiked(currentAudio.id);

        IconData repeatIcon;
        Color repeatColor;
        switch (provider.repeatModeSong) {
          case RepeatMode.off:
            repeatIcon = Icons.repeat;
            repeatColor = Colors.white;
            break;
          case RepeatMode.all:
            repeatIcon = Icons.repeat;
            repeatColor = Colors.green;
            break;
          case RepeatMode.one:
            repeatIcon = Icons.repeat_one;
            repeatColor = Colors.green;
            break;
        }

        return Stack(
          children: [
            const BackgroundImage(),
            Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              appBar: AppBar(
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
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Album art ───────────────────────────────────────
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
                      height: MediaQuery.sizeOf(context).height * 0.04),

                  // ── Title ──────────────────────────────────────────
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

                  const SizedBox(height: 20),

                  // ── Like / Playlist / Share ─────────────────────────
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
                        onPressed: () {},
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

                  const SizedBox(height: 20),

                  // ── Seek bar ────────────────────────────────────────
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

                  const SizedBox(height: 10),

                  // ── Playback controls ───────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        // FIX I — was toggleShuffle (legacy Audio flow).
                        // MusicPlayerPage shows AudioDescription songs,
                        // so use the AudioDescription shuffle/repeat/controls.
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
                        onPressed: provider.playNextSong,
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
            ),
          ],
        );
      },
    );
  }

  // ── Bottom sheets ───────────────────────────────────────────────────────────

  void _showDrawer(BuildContext context) {
    final provider = Provider.of<AudioProvider>(context, listen: false);
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
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.share_rounded, color: Colors.white),
              title: const Text('Share',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
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
        final provider = Provider.of<AudioProvider>(ctx, listen: false);
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
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_outline_rounded,
                      color: Colors.white),
                  title: const Text('Liked Songs',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    if (currentUserId != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LikedSongsPage(
                                  userId: currentUserId!)));
                    }
                  },
                ),
                ...provider.aplaylists.map((playlist) {
                  final inPlaylist = playlist.audioIds
                      .any((id) => id == widget.audio.id);
                  return ListTile(
                    leading: const Icon(Icons.playlist_play_rounded,
                        color: Colors.white),
                    title: Text(playlist.title,
                        style:
                            const TextStyle(color: Colors.white)),
                    trailing: inPlaylist
                        ? const Icon(Icons.check,
                            color: Colors.green)
                        : null,
                    onTap: inPlaylist
                        ? null
                        : () {
                            provider.addAudiosToPlaylist(
                                playlist, widget.audio.id);
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
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(119, 68, 66, 66),
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
                const SizedBox(height: 10),
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
                final provider =
                    Provider.of<AudioProvider>(ctx, listen: false);
                final targetAudioId = audioId ?? widget.audio.id;
                provider.createPlayListWithAudioId(
                    title, descCtrl.text.trim(), targetAudioId);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Playlist "$title" created')),
                );
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