import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/library/watch_later.dart';
import 'package:ott_project/components/video_folder/movie_player_page.dart';
import 'package:ott_project/components/video_folder/video_container.dart';
import 'package:ott_project/service/movie_api_service.dart';
import 'package:ott_project/service/watch_later_service.dart';

class WatchListPage extends StatefulWidget {
  final int userId;
  const WatchListPage({super.key, required this.userId});

  @override
  State<WatchListPage> createState() => _WatchListPageState();
}

class _WatchListPageState extends State<WatchListPage> {
  List<WatchLater> _allVideos = [];
  List<WatchLater> _filteredVideos = [];

  // Cache: videoId → VideoDescription (never fetch twice)
  final Map<int, VideoDescription?> _videoCache = {};

  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();
  final MovieApiService _movieApi = MovieApiService();

  @override
  void initState() {
    super.initState();
    _loadWatchLater();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Search: filter from local list, zero network calls ───────────────────
  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filteredVideos = q.isEmpty
          ? List.from(_allVideos)
          : _allVideos
              .where((v) => v.videoTitle.toLowerCase().contains(q))
              .toList();
    });
  }

  // ── Load all watch-later videos + prefetch details in parallel ───────────
  Future<void> _loadWatchLater() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<WatchLater> videos =
          await WatchLaterService().getWatchLaterVideos(widget.userId);

      // Fetch all video details IN PARALLEL
      await Future.wait(videos.map((v) => _fetchAndCache(v.videoId)));

      if (!mounted) return;
      setState(() {
        _allVideos = videos;
        _filteredVideos = List.from(videos);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load Watch Later';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAndCache(int videoId) async {
    if (_videoCache.containsKey(videoId)) return;
    try {
      final video = await _movieApi.fetchMovieDetail(videoId);
      // Pre-fetch thumbnail so it's ready instantly when UI renders
      await video.fetchImage();
      _videoCache[videoId] = video;
    } catch (_) {
      _videoCache[videoId] = null;
    }
  }

  // ── Remove from watch later ───────────────────────────────────────────────
  Future<void> _removeVideo(WatchLater video) async {
    try {
      await WatchLaterService().removeWatchLater(video.videoId, widget.userId);
      setState(() {
        _allVideos.removeWhere((v) => v.videoId == video.videoId);
        _filteredVideos.removeWhere((v) => v.videoId == video.videoId);
        _videoCache.remove(video.videoId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${video.videoTitle}" from Watch Later'),
            backgroundColor: Colors.grey[900],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove video'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Single video row — YouTube style ─────────────────────────────────────
  Widget _buildVideoItem(WatchLater video) {
    final VideoDescription? details = _videoCache[video.videoId];

    return InkWell(
      onTap: details == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MoviesPlayerPage(
                    videoDescriptions: [details],
                    categoryId: details.categoryList.isNotEmpty
                        ? details.categoryList.first
                        : 0,
                  ),
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Thumbnail (black box, no image) ───────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  // Black background — no network image shown
                  Container(
                    width: 120,
                    height: 72,
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white24,
                        size: 32,
                      ),
                    ),
                  ),
                  // Duration badge (if available)
                  if (details?.mainVideoDuration != null &&
                      details!.mainVideoDuration.isNotEmpty)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          details.mainVideoDuration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Title + meta ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.videoTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (details != null) ...[
                    Text(
                      details.productionCompany.isNotEmpty
                          ? details.productionCompany
                          : 'Media Jungle',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (details.rating.isNotEmpty)
                      Text(
                        '⭐ ${details.rating}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                  ] else
                    const Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                ],
              ),
            ),

            // ── 3-dot menu ─────────────────────────────────────────────────
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white54),
              color: Colors.grey[900],
              onSelected: (value) {
                if (value == 'remove') _removeVideo(video);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Remove from Watch Later',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const BackgroundImage(),
          SafeArea(
            child: Column(
              children: [
                // ── App bar ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Watch Later',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (!_isLoading && _allVideos.isNotEmpty)
                        Text(
                          '${_filteredVideos.length} video${_filteredVideos.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13),
                        ),
                    ],
                  ),
                ),

                // ── Search bar ────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search watch later...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.white38),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),
                const Divider(color: Colors.white12, height: 1),

                // ── Content ───────────────────────────────────────────────
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
                                    onPressed: _loadWatchLater,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white12),
                                  ),
                                ],
                              ),
                            )
                          : _filteredVideos.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.video_library_outlined,
                                          color: Colors.white24, size: 64),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchController.text.isEmpty
                                            ? 'No videos saved yet'
                                            : 'No results found',
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _loadWatchLater,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(
                                        top: 8, bottom: 24),
                                    itemCount: _filteredVideos.length,
                                    itemBuilder: (context, index) =>
                                        _buildVideoItem(_filteredVideos[index]),
                                  ),
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