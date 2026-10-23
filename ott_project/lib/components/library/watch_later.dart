import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/video_folder/movie_player_page.dart';
import 'package:ott_project/service/movie_api_service.dart';
import 'package:ott_project/service/watch_later_service.dart';
import 'package:ott_project/components/video_folder/video_container.dart';
class WatchLater {
  final int videoId;
  final String videoTitle;

  WatchLater({required this.videoId, required this.videoTitle});

  factory WatchLater.fromJson(Map<String, dynamic> json) {
    return WatchLater(
      videoId: json['videoId'],
      videoTitle: json['videoTitle'],
    );
  }
}

class WatchListPage extends StatefulWidget {
  final int userId;

  const WatchListPage({super.key, required this.userId});

  @override
  State<WatchListPage> createState() => _WatchListPageState();
}

class _WatchListPageState extends State<WatchListPage> {
  late StreamController<List<WatchLater>> watchController;

  final MovieApiService _movieApiService = MovieApiService();
  final TextEditingController _searchController = TextEditingController();

  /// Cache to avoid multiple API calls
  final Map<int, VideoDescription?> videoCache = {};

  List<WatchLater> _allVideos = [];

  @override
  void initState() {
    super.initState();
    watchController = StreamController<List<WatchLater>>();
    _loadWatchLater();

    _searchController.addListener(() {
      _filterVideos(_searchController.text);
    });
  }

  @override
  void dispose() {
    watchController.close();
    _searchController.dispose();
    super.dispose();
  }

  /// LOAD DATA FROM API
  Future<void> _loadWatchLater() async {
    try {
      final videos =
          await WatchLaterService().getWatchLaterVideos(widget.userId);

      _allVideos = videos;
      watchController.add(videos);
    } catch (e) {
      watchController.addError("Failed to load watchlist");
    }
  }

  /// SEARCH FILTER
  void _filterVideos(String query) {
    if (query.isEmpty) {
      watchController.add(_allVideos);
      return;
    }

    final filtered = _allVideos.where((video) {
      return video.videoTitle.toLowerCase().contains(query.toLowerCase());
    }).toList();

    watchController.add(filtered);
  }

  /// FETCH VIDEO DETAILS (CACHED)
  Future<VideoDescription?> fetchVideoDetails(int videoId) async {
    if (videoCache.containsKey(videoId)) return videoCache[videoId];

    try {
      final video = await _movieApiService.fetchMovieDetail(videoId);
      videoCache[videoId] = video;
      return video;
    } catch (_) {
      return null;
    }
  }

  /// SINGLE ITEM UI
  Widget _videoItem(WatchLater video) {
    return FutureBuilder<VideoDescription?>(
      future: fetchVideoDetails(video.videoId),
      builder: (context, snapshot) {
        final details = snapshot.data;

        return GestureDetector(
          onTap: details == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MoviesPlayerPage(
                        videoDescriptions: [details],
                        categoryId: details.categoryList.first,
                      ),
                    ),
                  );
                },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                /// THUMBNAIL
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: details != null
                      ? FutureBuilder<Uint8List?>(
                          future: details.thumbnailImage,
                          builder: (context, snap) {
                            if (snap.connectionState == ConnectionState.done &&
                                snap.hasData) {
                              return Image.memory(
                                snap.data!,
                                width: 90,
                                height: 60,
                                fit: BoxFit.cover,
                              );
                            }
                            return Container(
                              width: 90,
                              height: 60,
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 90,
                          height: 60,
                          color: Colors.grey[800],
                          child: const Icon(Icons.movie, color: Colors.white),
                        ),
                ),

                const SizedBox(width: 14),

                /// TITLE
                Expanded(
                  child: Text(
                    video.videoTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Icon(Icons.play_arrow, color: Colors.white54)
              ],
            ),
          ),
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
                /// TOP BAR
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),

                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: "Search ...",
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// TITLE
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Watch Later",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// LIST
                Expanded(
                  child: StreamBuilder<List<WatchLater>>(
                    stream: watchController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            "Failed to load watchlist",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      final videos = snapshot.data ?? [];

                      if (videos.isEmpty) {
                        return const Center(
                          child: Text(
                            "No videos in Watch Later",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _loadWatchLater,
                        child: ListView.builder(
                          itemCount: videos.length,
                          itemBuilder: (context, index) =>
                              _videoItem(videos[index]),
                        ),
                      );
                    },
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