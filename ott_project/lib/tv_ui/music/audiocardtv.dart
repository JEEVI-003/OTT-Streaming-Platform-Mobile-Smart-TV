import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';

class TVAudioCard extends StatefulWidget {
  final AudioDescription audio;
  final int initialIndex;
  final VoidCallback onTap;

  const TVAudioCard({
    Key? key,
    required this.audio,
    required this.initialIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _TVAudioCardState createState() => _TVAudioCardState();
}

class _TVAudioCardState extends State<TVAudioCard> {
  Uint8List? _thumbnail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  void _loadThumbnail() async {
    final image = await widget.audio.thumbnailImage;
    if (mounted) {
      setState(() {
        _thumbnail = image;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _isLoading
                  ? Container(
                      color: Colors.grey[850],
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white54, strokeWidth: 2),
                      ),
                    )
                  : (_thumbnail != null
                      ? Image.memory(
                          _thumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
                        )
                      : _buildErrorPlaceholder()),
              // Gradient overlay
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
              // Title
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  widget.audio.audioTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.9),
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.music_note, color: Colors.white38, size: 40),
      ),
    );
  }
}