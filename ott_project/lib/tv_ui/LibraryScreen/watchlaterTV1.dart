import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ott_project/components/library/watch_later.dart';
import 'package:ott_project/components/video_folder/video_container.dart';

import 'package:ott_project/service/movie_service_page.dart';
import 'package:ott_project/service/watch_later_service.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/movies/moviecardtv.dart';
import 'package:ott_project/tv_ui/movies/movieplayertv.dart';

class TVWatchlistscreen1 extends StatefulWidget {
  final int userId;
  const TVWatchlistscreen1({super.key, required this.userId});

  @override
  State<TVWatchlistscreen1> createState() => _TVWatchlistscreen1State();
}

class _TVWatchlistscreen1State extends State<TVWatchlistscreen1> {
  late StreamController<List<WatchLater>> watchlaterController;
  final Map<int, VideoDescription> _videoCache = {}; // Cache for video details
  int _totalWatchlistMovies = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    watchlaterController = StreamController<List<WatchLater>>();
    _initializeData();
    
    FocusManagerService.onWatchlistMovieSelect = (int movieIndex) {
      if (mounted && movieIndex >= 0 && movieIndex < _totalWatchlistMovies) {
        final videoId = _videoCache.keys.elementAt(movieIndex);
        final selectedMovie = _videoCache[videoId];
        if (selectedMovie != null) {
          _onMoviePlay(selectedMovie, movieIndex);
        }
      }
    };
  }

  Future<void> _initializeData() async {
    try {
      final watchLaterVideos = await WatchLaterService().getWatchLaterVideos(widget.userId);
      setState(() {
        _totalWatchlistMovies = watchLaterVideos.length;
      });
      
      // Pre-fetch all video details
      await _prefetchVideoDetails(watchLaterVideos);
      
      watchlaterController.add(watchLaterVideos);
      FocusManagerService.updateWatchlistMoviesCount(watchLaterVideos.length);
    } catch (e) {
      watchlaterController.addError('Failed to load videos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _prefetchVideoDetails(List<WatchLater> watchLaterVideos) async {
    for (final video in watchLaterVideos) {
      if (!_videoCache.containsKey(video.videoId)) {
        try {
          final videoDetail = await MovieService.fetchMovieDetail(video.videoId);
          _videoCache[video.videoId] = videoDetail;
        } catch (e) {
          // Handle error or leave cache empty for this video
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return StreamBuilder(
      stream: watchlaterController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
              style: TextStyle(color: Colors.white)),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No videos available in your watchlist',
              style: TextStyle(color: Colors.white)),
          );
        }

        final watchLaterVideos = snapshot.data!;
        return Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.015,
            left: MediaQuery.of(context).size.width * 0.01,
          ),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 0.8,
            ),
            itemCount: watchLaterVideos.length,
            itemBuilder: (context, index) {
              final video = watchLaterVideos[index];
              final videoDetails = _videoCache[video.videoId];
              
              if (videoDetails == null) {
                return Center(child: Icon(Icons.broken_image, color: Colors.white));
              }

              final isFocused = FocusManagerService.isWatchlistMoviesFocused &&
                  FocusManagerService.selectedWatchlistMovieIndex == index;
              
              return Card(
                color: isFocused ? Colors.blue : null,
                child: TVMoviesCard(
                  movie: videoDetails,
                  initialIndex: index,
                  categoryList: videoDetails.categoryList,
                  onTap: () => _onMoviePlay(videoDetails, index),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _onMoviePlay(VideoDescription videoDetails, int index) {
    if (videoDetails.categoryList.isEmpty) return;
    
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => TVMoviesPlayerPage(
          videoDescriptions: [videoDetails],
          categoryId: videoDetails.categoryList.first,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  void dispose() {
    watchlaterController.close();
    super.dispose();
  }
}