import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ott_project/components/library/watch_later.dart';
import 'package:ott_project/components/video_folder/video_container.dart';

import 'package:ott_project/service/movie_service_page.dart';
import 'package:ott_project/service/watch_later_service.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/movies/moviecardtv.dart';
import 'package:ott_project/tv_ui/movies/movieplayertv.dart';
import 'package:ott_project/tv_ui/LibraryScreen/storagedata.dart';

class TVWatchlistscreen extends StatefulWidget {
  final int userId;
  const TVWatchlistscreen({super.key, required this.userId});

  @override
  State<TVWatchlistscreen> createState() => _TVWatchlistscreenState();
}

class _TVWatchlistscreenState extends State<TVWatchlistscreen> {
  late StreamController<List<WatchLater>> watchlaterController;
  final Map<int, VideoDescription> _videoCache = {};
  int _totalWatchlistMovies = 0;
  List<int> watchlistVideoIds = [];
  bool _isLoading = true;

  // White focus border — consistent with movie-page focus style
  static const Color _focusBorderColor = Colors.white;
  static const double _focusBorderWidth = 3.0;

  @override
  void initState() {
    super.initState();
    watchlaterController = StreamController<List<WatchLater>>();
    // Rebuild on focus change so D-pad highlight moves correctly
    FocusManagerService.globalFocusNode.addListener(_onFocusChange);
    _loadWatchLater();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadWatchLater() async {
    try {
      List<WatchLater> watchLaterVideos =
          await WatchLaterService().getWatchLaterVideos(widget.userId);

      watchlistVideoIds =
          watchLaterVideos.map((video) => video.videoId).toList();

      // Pre-fetch all video details
      await _prefetchVideoDetails(watchLaterVideos);

      setState(() {
        _totalWatchlistMovies = watchLaterVideos.length;
        WatchLaterData.instance.updateWatchlistMovies(_totalWatchlistMovies);
      });

      watchlaterController.add(watchLaterVideos);
      FocusManagerService.updateWatchlistMoviesCount(watchLaterVideos.length);

      // FIX: Register selection callback after video cache is ready
      FocusManagerService.onWatchlistMovieSelect = (int movieIndex) async {
        if (movieIndex < 0 || movieIndex >= watchlistVideoIds.length) return;

        final videoId = watchlistVideoIds[movieIndex];
        final selectedMovie = _videoCache[videoId];

        if (selectedMovie != null) {
          _onMoviePlay(selectedMovie, movieIndex);
        }
      };
    } catch (e) {
      watchlaterController.addError('Failed to load videos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _prefetchVideoDetails(List<WatchLater> videos) async {
    for (final video in videos) {
      if (!_videoCache.containsKey(video.videoId)) {
        try {
          final videoDetail =
              await MovieService.fetchMovieDetail(video.videoId);
          _videoCache[video.videoId] = videoDetail;
        } catch (e) {
          debugPrint('Error fetching video ${video.videoId}: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Library',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Watch Later',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder(
                stream: watchlaterController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No videos available in your watchlist',
                            style: TextStyle(color: Colors.white)));
                  }

                  final watchLaterVideos = snapshot.data!;
                  return Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                      left: MediaQuery.of(context).size.width * 0.01,
                    ),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: watchLaterVideos.length,
                      itemBuilder: (context, index) {
                        final video = watchLaterVideos[index];
                        final videoDetails = _videoCache[video.videoId];

                        if (videoDetails == null) {
                          return const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.white));
                        }

                        // FIX: isFocused evaluated every build — reflects D-pad
                        // position because _onFocusChange triggers setState.
                        final isFocused =
                            FocusManagerService.isWatchlistMoviesFocused &&
                                FocusManagerService
                                        .selectedWatchlistMovieIndex ==
                                    index;

                        return GestureDetector(
                          onTap: () => _onMoviePlay(videoDetails, index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOut,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              // FIX: White focus border — consistent with
                              // movie-page style
                              border: isFocused
                                  ? Border.all(
                                      color: _focusBorderColor,
                                      width: _focusBorderWidth,
                                    )
                                  : Border.all(
                                      color: Colors.transparent,
                                      width: _focusBorderWidth),
                              boxShadow: isFocused
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.25),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : [],
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(isFocused ? 6 : 8),
                              child: Card(
                                margin: EdgeInsets.zero,
                                color: isFocused
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.grey.shade900,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        isFocused ? 6 : 8)),
                                child: TVMoviesCard(
                                  movie: videoDetails,
                                  initialIndex: index,
                                  categoryList: videoDetails.categoryList,
                                  onTap: () =>
                                      _onMoviePlay(videoDetails, index),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMoviePlay(VideoDescription videoDetails, int index) {
    if (videoDetails.categoryList.isEmpty) return;

    Navigator.of(context, rootNavigator: true)
        .push(
      MaterialPageRoute(
        builder: (context) => TVMoviesPlayerPage(
          videoDescriptions: [videoDetails],
          categoryId: videoDetails.categoryList.first,
          initialIndex: index,
        ),
      ),
    )
        .then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusManagerService.currentPage = 0;
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    FocusManagerService.globalFocusNode.removeListener(_onFocusChange);
    // Clear handler so stale closure is not called after dispose
    FocusManagerService.onWatchlistMovieSelect = null;
    watchlaterController.close();
    super.dispose();
  }
}