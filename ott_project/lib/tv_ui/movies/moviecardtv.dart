import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ott_project/components/video_folder/video_container.dart';

class TVMoviesCard extends StatefulWidget {
  final VideoDescription movie;
  final int initialIndex;
  final VoidCallback onTap;
  final List<int> categoryList;

  const TVMoviesCard({
    Key? key,
    required this.movie,
    required this.initialIndex,
    required this.onTap,
    required this.categoryList,
  }) : super(key: key);

  @override
  _TVMoviesCardState createState() => _TVMoviesCardState();
}

class _TVMoviesCardState extends State<TVMoviesCard> {
  Uint8List? imageData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    final data = await widget.movie.thumbnailImage;
    if (mounted) {
      setState(() {
        imageData = data;
        isLoading = false;
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
              isLoading
                  ? _buildPlaceholder()
                  : (imageData != null
                      ? Image.memory(
                          imageData!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
                        )
                      : _buildErrorPlaceholder()),
              _buildGradientOverlay(),
              _buildTitleText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[850],
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.movie, color: Colors.white38, size: 40),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
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
    );
  }

  Widget _buildTitleText() {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Text(
        widget.movie.videoTitle,
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
    );
  }
}