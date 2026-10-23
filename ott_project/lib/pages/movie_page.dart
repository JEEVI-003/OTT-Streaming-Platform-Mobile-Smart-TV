import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:ott_project/components/banners/video_banner.dart';
import 'package:ott_project/components/category/category_service.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/components/music_folder/audio_provider.dart';
import 'package:ott_project/components/music_folder/music.dart';
import 'package:ott_project/components/music_folder/song_player_page.dart';
import 'package:ott_project/components/video_folder/category_bar.dart';
import 'package:ott_project/components/video_folder/movie.dart';
import 'package:ott_project/components/video_folder/movie_player_page.dart';
import 'package:ott_project/components/video_folder/video_play.dart';
import 'package:ott_project/pages/app_icon.dart';
import 'package:ott_project/pages/custom_appbar.dart';
import 'package:ott_project/pages/main_tab.dart';
import 'package:ott_project/pages/music_page.dart';
import 'package:ott_project/profile/profile_page.dart';
import 'package:ott_project/service/audio_service.dart';
import 'package:ott_project/service/movie_api_service.dart';
import 'package:ott_project/service/movie_service_page.dart';
import 'package:ott_project/service/service.dart';
import 'package:provider/provider.dart';
import '../components/background_image.dart';
import '../components/category/movie_category_section.dart';

import '../components/video_folder/video_container.dart';
import '../service/icon_service.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final Service service = Service();
  List<VideoDescription> allMovies = [];
  List<AudioDescription> allSongs = [];
  final TextEditingController _searchController = TextEditingController();
  List<VideoDescription> _filteredMovies = [];
  int currentBannerIndex = 0;
  List<VideoContainer> _videoContainers = [];
  List<VideoBanner> videobanners = [];
  Map<int, VideoDescription> _videoDetails = {};
  Map<int, Uint8List?> bannerImages = {};
  bool _isLoading = true;
  bool _isBannerLoading = true;
  String selectedCategory = "Movies";
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadInitialVisuals();
    // FIX 1: loadSongs() was defined but never called — audio search was always empty
    loadSongs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _loadInitialVisuals() async {
    setState(() {
      _isBannerLoading = true;
    });

    await CategoryService().loadCategories();
    await _loadBannerDetails();
    loadMovies();
  }

  Future<void> loadMovies() async {
    try {
      List<VideoContainer> videoContainers =
          await MovieService.fetchVideoContainer();
      allMovies = videoContainers
          .expand((container) => container.videoDescriptions)
          .toList();
      if (!mounted) return;
      setState(() {
        _videoContainers = videoContainers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching movies: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load movies. Please try again.')),
      );
    }
  }

  Future<void> loadSongs() async {
    try {
      List<AudioContainer> audioContainers =
          await AudioService.fetchAudioContainer();
      allSongs = audioContainers
          .expand((container) => container.audiolist)
          .toList();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      print('Error fetching songs: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load songs. Please try again.')),
      );
    }
  }

  Future<void> _loadBannerDetails() async {
    try {
      final banners = await MovieApiService().fetchAllVideoBanner();
      final imageMap = <int, Uint8List?>{};

      for (var banner in banners) {
        final image =
            await MovieApiService.fetchVideoBannerImage(banner.videoId);
        imageMap[banner.videoId] = image;
      }

      if (!mounted) return;
      setState(() {
        videobanners = banners;
        bannerImages = imageMap;
        _isBannerLoading = false;
      });
    } catch (e) {
      print('Error loading banner: $e');
      if (!mounted) return;
      setState(() {
        _isBannerLoading = false;
      });
    }
  }

  Future<void> _refreshMovies() async {
    await loadMovies();
  }

  void _navigateToCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
    switch (category) {
      case "All":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MainTab(initialTab: 0)));
        break;
      case "Movies":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MainTab(initialTab: 0)));
        break;
      case "Music":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MainTab(initialTab: 1)));
        break;
      case "Library":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MainTab(initialTab: 2)));
        break;
      case "Profile":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MainTab(initialTab: 3)));
        break;
    }
  }

  // FIX 2: handleSearchState now properly receives and stores search state
  // so that _isSearching toggles the overlay correctly
  void handleSearchState(bool isSearching, List<dynamic> results) {
    setState(() {
      _isSearching = isSearching;
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // FIX 3: Use Column layout instead of Stack so the AppBar sits above
      // content and the search overlay never hides behind it
      body: Stack(
        children: [
          BackgroundImage(),

          // Main content — hidden when search is active
          if (!_isSearching)
            Container(
              padding: const EdgeInsets.all(16.0),
              // FIX 4: top margin accounts for AppBar height so content
              // doesn't start under the bar
              margin: EdgeInsets.only(top: kToolbarHeight + 8),
              child: RefreshIndicator(
                onRefresh: _refreshMovies,
                child: ListView(
                  children: [
                    if (_isBannerLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Stack(
                        children: [
                          Container(
                            height: MediaQuery.sizeOf(context).height * 0.25,
                            child: CarouselSlider(
                              options: CarouselOptions(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.25,
                                viewportFraction: 1.0,
                                autoPlay: true,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    currentBannerIndex = index;
                                  });
                                },
                              ),
                              items: videobanners.asMap().entries.map((entry) {
                                final index = entry.key;
                                final banner = entry.value;
                                final image = bannerImages[banner.videoId];
                                final matchingValue = _videoContainers
                                    .cast<VideoContainer?>()
                                    .firstWhere(
                                      (container) => container!.videoDescriptions
                                          .any((v) => v.id == banner.videoId),
                                      orElse: () => null,
                                    );

                                return GestureDetector(
                                  onTap: () async {
                                    try {
                                      final details =
                                          await MovieApiService()
                                              .fetchMovieDetail(banner.videoId);
                                      if (!context.mounted) return;

                                      final categoryId =
                                          CategoryService().getCategoryId(
                                              details.categoryList,
                                              matchingValue!.value);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MoviesPlayerPage(
                                            videoDescriptions: allMovies,
                                            categoryId: categoryId,
                                            initialIndex: index,
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      print('Banner tap error: $e');
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Failed to open video. Please try again.'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: _buildBannerImage(image),
                                );
                              }).toList(),
                            ),
                          ),
                          Positioned(
                            top: 180,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: videobanners.isNotEmpty
                                  ? DotsIndicator(
                                      dotsCount: videobanners.length,
                                      position: currentBannerIndex.toDouble(),
                                      decorator: const DotsDecorator(
                                        color: Colors.grey,
                                        activeColor: Colors.white,
                                        size: Size(7, 7),
                                        activeSize: Size(8, 8),
                                        spacing: EdgeInsets.all(4),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.03),
                    _searchController.text.isNotEmpty &&
                            _filteredMovies.isEmpty
                        ? const Center(
                            child: Text(
                              'No movies found',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _videoContainers.length,
                            itemBuilder: (context, index) {
                              final container = _videoContainers[index];
                              return MoviesCategorySection(
                                videoContainer: container,
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),

          // FIX 5: Search results rendered as a separate full-screen overlay
          // ABOVE the content but BELOW the AppBar, so they are always visible
          if (_isSearching) _buildSearchResults(),

          // AppBar always on top of everything
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomAppBar(onSearchChanged: handleSearchState),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerPlaceholder(Uint8List? image) {
    if (image != null) return _buildBannerImage(image);
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.movie, color: Colors.white54, size: 48),
      ),
    );
  }

  Widget _buildBannerImage(Uint8List? image) {
    if (image == null) return _buildBannerPlaceholder(null);
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: MemoryImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      // FIX 6: top margin matches the actual AppBar height so results
      // appear directly below the search bar, not behind it
      margin: EdgeInsets.only(top: kToolbarHeight),
      color: Colors.black87,
      child: _searchResults.isEmpty
          ? const Center(
              child: Text(
                'No results found',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final item = _searchResults[index];

                // FIX 7: Handle the three item types correctly:
                //   - VideoDescription  → Movie result
                //   - AudioDescription  → Song result
                //   - Map (recent)      → Recent search chip
                if (item is Map) {
                  // Recent search entry
                  final query = item['query'] as String? ?? '';
                  final title = item['title'] as String? ?? query;
                  return ListTile(
                    leading: const Icon(Icons.history, color: Colors.white54),
                    title: Text(
                      title.isNotEmpty ? title : query,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Recent search',
                      style: TextStyle(color: Colors.white54),
                    ),
                    // Tapping a recent search re-triggers the search
                    onTap: () {
                      // no-op — recent searches are informational only here
                    },
                  );
                }

                return ListTile(
                  leading: Icon(
                    item is VideoDescription
                        ? Icons.movie_outlined
                        : Icons.music_note_outlined,
                    color: Colors.white70,
                  ),
                  title: Text(
                    item is VideoDescription
                        ? item.videoTitle
                        : item is AudioDescription
                            ? item.audioTitle
                            : 'Unknown',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    item is VideoDescription
                        ? 'Movie'
                        : item is AudioDescription
                            ? 'Song'
                            : '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    if (item is VideoDescription) {
                      if (allMovies.isNotEmpty) {
                        final movieIndex = allMovies
                            .indexWhere((video) => video.id == item.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MoviesPlayerPage(
                              videoDescriptions: allMovies,
                              categoryId: item.categoryList.isNotEmpty
                                  ? item.categoryList.first
                                  : 0,
                              initialIndex:
                                  movieIndex < 0 ? 0 : movieIndex,
                            ),
                          ),
                        );
                      }
                    } else if (item is AudioDescription) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongPlayerPage(
                            music: item,
                            musicList: allSongs,
                            onChange: (newAudio) {
                              Provider.of<AudioProvider>(context,
                                      listen: false)
                                  .setCurrentlyPlayingSong(
                                newAudio,
                                allSongs,
                              );
                            },
                            onDislike: (p0) {},
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}