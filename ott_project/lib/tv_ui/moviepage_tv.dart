import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ott_project/components/category/category_service.dart';
import 'package:ott_project/components/video_folder/video_container.dart';
import 'package:ott_project/service/movie_service_page.dart';
import 'package:ott_project/service/service.dart';
import 'package:ott_project/service/watch_later_service.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/banner/moviebanner.dart';
import 'package:ott_project/tv_ui/movies/moviecardtv.dart';
import 'package:ott_project/tv_ui/movies/moviecategorytv.dart';
import 'package:ott_project/tv_ui/movies/movieplayertv.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TVMovieScreen extends StatefulWidget {
  const TVMovieScreen({super.key});

  @override
  _TVMovieScreenState createState() => _TVMovieScreenState();
}

class _TVMovieScreenState extends State<TVMovieScreen> {
  final Service service = Service();
  List<VideoDescription> allMovies = [];

  List<VideoContainer> _videoContainers = [];
  Map<int, bool> videoWatchlistState = {};
  Map<int, VideoDescription> _videoDetails = {};
  int _currentPage = 0;
  late ScrollController _scrollController;

  Map<int, Uint8List?> bannerImages = {};
  List<VideoBanner> videobanners = [];

  final CarouselSliderController _carouselController = CarouselSliderController();
  bool isWatchlisted = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadData();
    _loadWatchlistStatus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });

    // Register page-specific callbacks for Movies page
    FocusManagerService.onPlayButtonPress = () {
      if (mounted && videobanners.isNotEmpty) {
        final idx = FocusManagerService.selectedCarouselIndex
            .clamp(0, videobanners.length - 1);
        _handlePlayButtonPress(context, videobanners[idx]);
      }
    };

    FocusManagerService.onWatchLaterPress = () {
      if (mounted && videobanners.isNotEmpty) {
        final idx = FocusManagerService.selectedCarouselIndex
            .clamp(0, videobanners.length - 1);
        _toggleWatchLater(videobanners[idx].videoId);
      }
    };

    FocusManagerService.onSeeMoreSelect = (int index) {
      if (mounted && index >= 0 && index < _videoContainers.length) {
        _onSeeMorePressed(_videoContainers[index]);
      }
    };

    FocusManagerService.onCategorySelect = (int categoryIndex, int movieIndex) {
      FocusManagerService.isSeeMoreFocused = false;
      if (!mounted) return;
      if (categoryIndex >= 0 && categoryIndex < _videoContainers.length) {
        final selectedContainer = _videoContainers[categoryIndex];
        if (movieIndex >= 0 &&
            movieIndex < selectedContainer.videoDescriptions.length) {
          _handleMovieplay(
              selectedContainer.videoDescriptions[movieIndex], selectedContainer);
        }
      }
    };
  }

  Future<void> _loadData() async {
    await Future.wait([loadMovies(), _loadBannerDetails()]);
  }

  Future<void> loadMovies() async {
    try {
      final videoContainers = await MovieService.fetchVideoContainer();
      allMovies = videoContainers
          .expand((container) => container.videoDescriptions)
          .toList();
      if (mounted) {
        setState(() {
          _videoContainers = videoContainers;
        });
      }
    } catch (e) {
      debugPrint('Error fetching movies: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load movies. Please try again.')),
        );
      }
    }
  }

  Future<void> _loadBannerDetails() async {
    try {
      final fetchedBanners = await MovieService.fetchAllVideoBanners();
      final detailsMap = <int, VideoDescription>{};
      final imageMap = <int, Uint8List?>{};

      for (var banner in fetchedBanners) {
        try {
          if (!detailsMap.containsKey(banner.videoId)) {
            final details = await MovieService.fetchMovieDetail(banner.videoId);
            detailsMap[banner.videoId] = details;
          }
          final image = await MovieService.fetchVideoBannerImage(banner.videoId);
          imageMap[banner.videoId] = image;
        } catch (e) {
          debugPrint('Error fetching details for video ${banner.videoId}: $e');
        }
      }

      if (mounted) {
        if (!listEquals(videobanners, fetchedBanners) ||
            _videoDetails.length != detailsMap.length ||
            bannerImages.length != imageMap.length) {
          setState(() {
            videobanners = fetchedBanners;
            _videoDetails = detailsMap;
            bannerImages = imageMap;
          });
          _loadWatchlistStatus();
        }
      }
    } catch (e) {
      debugPrint('Error loading banner details: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return FocusScope(
      canRequestFocus: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          controller: FocusManagerService.scrollController,
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page title banner (distinct from Home) ─────────────────────
              Padding(
                padding: EdgeInsets.only(
                  top: screenSize.height * 0.1,
                  left: 20,
                  bottom: 4,
                ),
                child: Text(
                  'Movies',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 143, 228, 0),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // ── Carousel + Hero ────────────────────────────────────────────
              Stack(
                children: [
                  SizedBox(
                    height: screenSize.height * 0.55,
                    child: _buildCarouselSlider(screenSize),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildHeroSection(screenSize),
                  ),
                ],
              ),
              _buildMovieCategories(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselSlider(Size screenSize) {
    FocusManagerService.updateCarouselLength(videobanners.length);
    if (videobanners.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.0),
        border: Border.all(
          width: 2,
          color: FocusManagerService.isCarouselFocused
              ? Colors.white
              : Colors.transparent,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: !FocusManagerService.isCarouselFocused,
              enlargeCenterPage: true,
              viewportFraction: 1.0,
              height: screenSize.height * 1.5,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentPage = index;
                  FocusManagerService.selectedCarouselIndex = index;
                });
              },
            ),
            carouselController: _carouselController,
            items: videobanners.map((banner) {
              final image = bannerImages[banner.videoId];
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  image: image != null
                      ? DecorationImage(
                          image: MemoryImage(image),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: image == null ? Colors.grey[900] : null,
                ),
                child: image == null
                    ? const Center(
                        child: Icon(Icons.movie, color: Colors.white54, size: 60))
                    : null,
              );
            }).toList(),
          ),
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: AnimatedSmoothIndicator(
                activeIndex: _currentPage,
                count: videobanners.length,
                effect: ScrollingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotScale: 1.5,
                  activeDotColor: Colors.white,
                  dotColor: Colors.grey.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Size screenSize) {
    if (videobanners.isEmpty) return const SizedBox.shrink();
    final idx = _currentPage.clamp(0, videobanners.length - 1);
    final banner = videobanners[idx];
    final details = _videoDetails[banner.videoId];
    final isInWatchlist = videoWatchlistState[banner.videoId] ?? false;

    return Container(
      height: screenSize.height * 0.5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 10,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details?.videoTitle ?? 'Loading...',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        AnimatedScale(
                          scale: FocusManagerService.selectedButtonIndex == 0 &&
                                  FocusManagerService.isButtonFocused
                              ? 1.125
                              : 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: ElevatedButton(
                            onPressed: () =>
                                _handlePlayButtonPress(context, banner),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FocusManagerService
                                              .selectedButtonIndex ==
                                          0 &&
                                      FocusManagerService.isButtonFocused
                                  ? const Color.fromARGB(255, 143, 228, 0)
                                  : const Color.fromARGB(255, 193, 39, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(
                              details?.videoAccessType == true
                                  ? 'Subscription'
                                  : 'Play Now',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        AnimatedScale(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          scale: FocusManagerService.isButtonFocused &&
                                  FocusManagerService.selectedButtonIndex == 1
                              ? 1.12
                              : 1,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _toggleWatchLater(banner.videoId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FocusManagerService
                                          .isButtonFocused &&
                                      FocusManagerService.selectedButtonIndex ==
                                          1
                                  ? const Color.fromARGB(255, 143, 228, 0)
                                  : const Color.fromARGB(135, 0, 0, 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isInWatchlist
                                      ? Icons.remove_circle_outline
                                      : Icons.add_circle_outline,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isInWatchlist
                                      ? 'Remove from Watchlist'
                                      : 'Add to Watchlist',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (details != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          // FIX: guard null duration → no NaN crash
                          'Duration: ${details.mainVideoDuration ?? 'N/A'}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePlayButtonPress(BuildContext context, VideoBanner banner) async {
    final details = _videoDetails[banner.videoId];
    if (details == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie details not available.')),
      );
      return;
    }
    if (details.videoAccessType == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This movie requires a subscription.')),
      );
      return;
    }

    final previousFocusState = _captureFocusState();
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => TVMoviesPlayerPage(
          categoryId: details.categoryList.isNotEmpty
              ? details.categoryList.first
              : 0,
          videoDescriptions: [details],
          initialIndex: 0,
        ),
      ),
    ).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusManagerService.currentPage = 1;
        FocusManagerService.restoreFocusState(previousFocusState);
      });
    });
  }

  Future<void> _loadWatchlistStatus() async {
    try {
      final currentUser = await service.getLoggedInUserId();
      if (currentUser != null && videobanners.isNotEmpty) {
        final watchLaterService = WatchLaterService();
        for (var banner in videobanners) {
          final isInWatchList =
              await watchLaterService.isInWatchList(banner.videoId, currentUser);
          if (mounted) {
            setState(() {
              videoWatchlistState[banner.videoId] = isInWatchList;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading watchlist status: $e');
    }
  }

  Future<void> _toggleWatchLater(int videoId) async {
    try {
      final currentUser = await service.getLoggedInUserId();
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to add to watchlist.')),
          );
        }
        return;
      }

      final watchLaterService = WatchLaterService();
      final isCurrentlyInWatchlist = videoWatchlistState[videoId] ?? false;

      setState(() {
        videoWatchlistState[videoId] = !isCurrentlyInWatchlist;
      });

      if (isCurrentlyInWatchlist) {
        await watchLaterService.removeWatchLater(videoId, currentUser);
      } else {
        await watchLaterService.addToWatchLater(videoId, currentUser);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCurrentlyInWatchlist
                ? 'Removed from watchlist.'
                : 'Added to watchlist.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling watchlist: $e');
      setState(() {
        videoWatchlistState[videoId] =
            !(videoWatchlistState[videoId] ?? false);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update watchlist.')),
        );
      }
    }
  }

  Widget _buildMovieCategories() {
    if (_videoContainers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No movies found',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }
    return Column(
      children: _videoContainers.map((container) {
        int categoryLength = container.videoDescriptions.length;
        int categoryIndex = _videoContainers.indexOf(container);
        FocusManagerService.updateCategoryLength(categoryIndex, categoryLength);

        final ScrollController rowScrollController = ScrollController();
        if (FocusManagerService.isSeeMoreFocused &&
            FocusManagerService.selectedSeeMoreIndex == categoryIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (rowScrollController.hasClients) {
              rowScrollController.jumpTo(0.0);
            }
          });
        }

        return Focus(
          autofocus: false,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      container.value,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Focus(
                      autofocus: false,
                      canRequestFocus: false,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        scale: FocusManagerService.isSeeMoreFocused &&
                                FocusManagerService.selectedSeeMoreIndex ==
                                    categoryIndex
                            ? 1.12
                            : 1,
                        child: ElevatedButton(
                          autofocus: false,
                          onPressed: () => _onSeeMorePressed(container),
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                            backgroundColor: (FocusManagerService
                                        .isSeeMoreFocused &&
                                    FocusManagerService.selectedSeeMoreIndex ==
                                        categoryIndex)
                                ? const Color.fromARGB(255, 143, 228, 0)
                                : Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text('See more',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: rowScrollController,
                    itemCount: container.videoDescriptions.length,
                    itemBuilder: (context, index) {
                      final movie = container.videoDescriptions[index];
                      final isSelected =
                          FocusManagerService.isCategoryFocused &&
                              FocusManagerService.focusedCategoryIndex ==
                                  categoryIndex &&
                              FocusManagerService.selectedCategoryIndex == index;

                      if (isSelected) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (rowScrollController.hasClients) {
                            final double scrollPosition =
                                (index * 160.0).clamp(
                              0.0,
                              rowScrollController.position.maxScrollExtent,
                            );
                            rowScrollController.animateTo(
                              scrollPosition,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        });
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Transform.scale(
                          scale: isSelected ? 1.1 : 1,
                          child: AnimatedContainer(
                            curve: Curves.easeOut,
                            duration: const Duration(milliseconds: 200),
                            padding: isSelected
                                ? const EdgeInsets.all(0.0)
                                : EdgeInsets.zero,
                            decoration: BoxDecoration(
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.white, width: 2.0)
                                  : null,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.3),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: TVMoviesCard(
                              movie: movie,
                              initialIndex: index,
                              categoryList: movie.categoryList,
                              onTap: () =>
                                  _handleMovieplay(movie, container),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleMovieplay(VideoDescription movie, VideoContainer container) {
    final categoryId =
        CategoryService().getCategoryId(movie.categoryList, container.value);
    final previousFocusState = _captureFocusState();

    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(
          builder: (context) => TVMoviesPlayerPage(
            categoryId: categoryId,
            videoDescriptions: container.videoDescriptions,
            initialIndex: container.videoDescriptions.indexOf(movie),
          ),
        ))
        .then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusManagerService.currentPage = 1;
        FocusManagerService.restoreFocusState(previousFocusState);
      });
    });
  }

  void _onSeeMorePressed(VideoContainer container) {
    final previousFocusState = _captureFocusState();
    FocusManagerService.unfocusAll();

    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(
          builder: (context) => TVCategoryBasedMovie(
            categoryName: container.value,
            videoDescriptions: container.videoDescriptions,
          ),
        ))
        .then((_) {
      FocusManagerService.currentPage = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusManagerService.currentPage = 1;
        FocusManagerService.restoreFocusState(previousFocusState);
      });
    });
  }

  Map<String, dynamic> _captureFocusState() => {
        'isSidebarFocused': FocusManagerService.isSidebarFocused,
        'selectedSidebarIndex': FocusManagerService.selectedSidebarIndex,
        'isTopRowFocused': FocusManagerService.isTopRowFocused,
        'selectedTopRowIndex': FocusManagerService.selectedTopRowIndex,
        'isCarouselFocused': FocusManagerService.isCarouselFocused,
        'selectedCarouselIndex': FocusManagerService.selectedCarouselIndex,
        'isCategoryFocused': FocusManagerService.isCategoryFocused,
        'focusedCategoryIndex': FocusManagerService.focusedCategoryIndex,
        'selectedCategoryIndex': FocusManagerService.selectedCategoryIndex,
        'isSeeMoreFocused': FocusManagerService.isSeeMoreFocused,
        'selectedSeeMoreIndex': FocusManagerService.selectedSeeMoreIndex,
        'isButtonFocused': FocusManagerService.isButtonFocused,
        'selectedButtonIndex': FocusManagerService.selectedButtonIndex,
        'isWatchlistMoviesFocused':
            FocusManagerService.isWatchlistMoviesFocused,
        'selectedWatchlistMovieIndex':
            FocusManagerService.selectedWatchlistMovieIndex,
        'scrollPosition': FocusManagerService.scrollController.hasClients
            ? FocusManagerService.scrollController.offset
            : 0.0,
        'currentPage': 1,
      };
}