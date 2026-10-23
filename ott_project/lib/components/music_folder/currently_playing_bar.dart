import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/components/music_folder/audio_provider.dart';
import 'package:provider/provider.dart';

class CurrentlyPlayingBar extends StatefulWidget {
  final VoidCallback onTap;
  final AudioDescription? audioCurrentlyPlaying;

  const CurrentlyPlayingBar({
    super.key,
    required this.audioCurrentlyPlaying,
    required this.onTap,
  });

  @override
  State<CurrentlyPlayingBar> createState() => _CurrentlyPlayingBarState();
}

class _CurrentlyPlayingBarState extends State<CurrentlyPlayingBar> {
  Uint8List? thumbnail;

  @override
  void initState() {
    super.initState();
    _loadThumbnailImage();
  }

  @override
  void didUpdateWidget(CurrentlyPlayingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioCurrentlyPlaying?.id !=
        widget.audioCurrentlyPlaying?.id) {
      _loadThumbnailImage();
    }
  }

  Future<void> _loadThumbnailImage() async {
    if (widget.audioCurrentlyPlaying == null) return;
    try {
      final image =
          await widget.audioCurrentlyPlaying!.thumbnailImage;
      if (mounted) setState(() => thumbnail = image);
    } catch (e) {
      debugPrint('CurrentlyPlayingBar: error loading thumbnail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioCurrentlyPlaying == null) {
      return const SizedBox.shrink();
    }

    return Consumer<AudioProvider>(
      builder: (context, provider, _) {
        return Container(
          height: 70,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 190, 104, 105),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              child: Row(
                children: [
                  // ── Thumbnail ───────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: thumbnail != null
                        ? Image.memory(
                            thumbnail!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey,
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey,
                          ),
                  ),

                  const SizedBox(width: 12),

                  // ── Song info ────────────────────────────────────
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.audioCurrentlyPlaying!.audioTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Now Playing',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Controls ─────────────────────────────────────
                  // FIX I — The original called playPreviousMusic / playPauseMusic /
                  // playNextMusic which are the Music-model flow methods.
                  // SongPlayerPage and MusicPlayerPage both use the AudioDescription
                  // flow (playSong/playPauseSong/playNextSong). Using the wrong
                  // methods here operated on music_playlist (which is empty after
                  // the AudioDescription flow starts), causing the song to stop
                  // abruptly and the bar controls to appear frozen after navigation.
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous,
                            color: Colors.white),
                        iconSize: 24,
                        onPressed: provider.playPreviousSong,
                      ),
                      IconButton(
                        icon: Icon(
                          provider.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        iconSize: 28,
                        onPressed: provider.playPauseSong,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next,
                            color: Colors.white),
                        iconSize: 24,
                        onPressed: provider.playNextSong,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}