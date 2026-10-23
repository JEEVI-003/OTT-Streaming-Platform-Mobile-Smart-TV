import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/service/audio_api_service.dart';
import 'package:ott_project/service/audio_service.dart';
import 'package:ott_project/service/service.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/banner/audiobanner.dart';
import 'package:ott_project/tv_ui/music/audiocardtv.dart';
import 'package:ott_project/tv_ui/music/musiccategorytv.dart';
import 'package:ott_project/tv_ui/music/musicplayerTV.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TVMusicScreen extends StatefulWidget {
  const TVMusicScreen({super.key});

  @override
  _TVMusicScreenState createState() => _TVMusicScreenState();
}

class _TVMusicScreenState extends State<TVMusicScreen> {
  final Service service = Service();
  List<AudioDescription> allSongs = [];
  List<AudioContainer> _audioContainers = [];

  Map<int, AudioDescription> _audioDetails = {};
  int _currentPage = 0;

  Map<int, Uint8List?> bannerImages = {};
  List<AudioBannerTV> audiobanners = [];

  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _loadData();

    // ── FIX: register onPlayButtonPress (was completely missing) ─────────────
    FocusManagerService.onPlayButtonPress = () {
      if (!mounted) return;
      if (audiobanners.isEmpty || _audioContainers.isEmpty) return;
      final idx = FocusManagerService.selectedCarouselIndex
          .clamp(0, audiobanners.length - 1);
      final banner = audiobanners[idx];
      final details = _audioDetails[banner.movienameID];
      if (details != null) {
        // Find which container this song belongs to
        for (final container in _audioContainers) {
          final songIdx =
              container.audiolist.indexWhere((s) => s.id == details.id);
          if (songIdx >= 0) {
            _onhandleMusicPlay(container.audiolist[songIdx], container);
            return;
          }
        }
        // Fallback: play from first container
        _onhandleMusicPlay(details, _audioContainers.first);
      }
    };

    // ── FIX: register onWatchLaterPress (was completely missing) ─────────────
    FocusManagerService.onWatchLaterPress = () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Use the Liked Music section to save songs.'),
          duration: Duration(seconds: 2),
        ),
      );
    };

    // ── Category / See-more callbacks ────────────────────────────────────────
    FocusManagerService.onSeeMoreSelect = (int index) {
      if (mounted && index >= 0 && index < _audioContainers.length) {
        _onSeeMorePressed(_audioContainers[index]);
      }
    };

    FocusManagerService.onCategorySelect = (int categoryIndex, int songIndex) {
      FocusManagerService.isSeeMoreFocused = false;
      if (!mounted) return;
      if (categoryIndex >= 0 && categoryIndex < _audioContainers.length) {
        final container = _audioContainers[categoryIndex];
        if (songIndex >= 0 && songIndex < container.audiolist.length) {
          _onhandleMusicPlay(container.audiolist[songIndex], container);
        }
      }
    };
  }

  Future<void> _loadData() async {
    await Future.wait([loadSongs(), _loadBannerDetails()]);
  }

  Future<void> loadSongs() async {
    try {
      final audioContainers = await AudioService.fetchAudioContainer();
      if (audioContainers.isEmpty) {
        debugPrint('No audio containers received.');
        return;
      }

      // Fetch movie names for all songs in parallel per container
      final List<AudioDescription> updatedSongs = [];
      for (var container in audioContainers) {
        for (var song in container.audiolist) {
          try {
            final details = await AudioApiService().fetchAudioDetails(song.id);
            song.movieName = details.movieName;
            updatedSongs.add(song);
          } catch (e) {
            debugPrint('Error fetching movie name for song ${song.id}: $e');
            updatedSongs.add(song); // still add even without movie name
          }
        }
      }

      if (mounted) {
        setState(() {
          _audioContainers = audioContainers;
          allSongs = updatedSongs;
        });
      }
    } catch (e) {
      debugPrint('Error fetching audio: $e');
    }
  }

  Future<void> _loadBannerDetails() async {
    try {
      final fetchedBanners =
          await AudioApiService().fetchAllAudioBannerTV();
      final detailsMap = <int, AudioDescription>{};
      final imageMap = <int, Uint8List?>{};

      for (var banner in fetchedBanners) {
        try {
          final details =
              await AudioApiService().fetchAudioDetails(banner.movienameID);
          detailsMap[banner.movienameID] = details;

          final image =
              await AudioApiService().fetchMusicBanner(banner.movienameID);
          imageMap[banner.movienameID] = image;
        } catch (e) {
          debugPrint(
              'Error fetching details for audio ${banner.movienameID}: $e');
        }
      }

      if (mounted) {
        setState(() {
          audiobanners = fetchedBanners;
          _audioDetails = detailsMap;
          bannerImages = imageMap;
        });
      }
    } catch (e) {
      debugPrint('Error loading banner details: $e');
    }
  }

  @override
  void dispose() {
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
              // ── Page title ─────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(
                  top: screenSize.height * 0.1,
                  left: 20,
                  bottom: 4,
                ),
                child: Text(
                  'Music',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 143, 228, 0),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // ── Carousel ───────────────────────────────────────────────────
              SizedBox(
                height: screenSize.height * 0.55,
                child: _buildCarouselSlider(screenSize),
              ),
              // ── Music categories ───────────────────────────────────────────
              _buildMusicCategories(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselSlider(Size screenSize) {
    FocusManagerService.updateCarouselLength(audiobanners.length);

    // FIX: guard empty state — previously checked allSongs (wrong) causing
    // the spinner to show even after songs loaded if banners were empty.
    if (audiobanners.isEmpty) {
      return Center(
        child: allSongs.isEmpty
            ? const CircularProgressIndicator()
            : const Text('No banners available',
                style: TextStyle(color: Colors.white54)),
      );
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
            items: audiobanners.map((banner) {
              final image = bannerImages[banner.movienameID];
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
                        child: Icon(Icons.music_note,
                            color: Colors.white54, size: 60))
                    : null,
              );
            }).toList(),
          ),
          if (audiobanners.length > 1)
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: AnimatedSmoothIndicator(
                  activeIndex: _currentPage.clamp(0, audiobanners.length - 1),
                  count: audiobanners.length,
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

  Widget _buildMusicCategories() {
    if (_audioContainers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No music found',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Column(
      children: _audioContainers.map((container) {
        final int categoryLength = container.audiolist.length;
        final int categoryIndex = _audioContainers.indexOf(container);
        FocusManagerService.updateCategoryLength(categoryIndex, categoryLength);

        final rowScrollController = ScrollController();

        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    container.categoryName,
                    style: const TextStyle(fontSize: 25, color: Colors.white),
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
                        onPressed: () {
                          FocusManagerService.isSeeMoreFocused = true;
                          FocusManagerService.selectedSeeMoreIndex =
                              categoryIndex;
                          _onSeeMorePressed(container);
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 25,
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
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: rowScrollController,
                  itemCount: container.audiolist.length,
                  itemBuilder: (context, index) {
                    final song = container.audiolist[index];
                    final isSelected =
                        FocusManagerService.isCategoryFocused &&
                            FocusManagerService.focusedCategoryIndex ==
                                categoryIndex &&
                            FocusManagerService.selectedCategoryIndex == index;

                    // Auto-scroll the focused card into view
                    if (isSelected) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (rowScrollController.hasClients) {
                          final double pos = (index * 160.0).clamp(
                            0.0,
                            rowScrollController.position.maxScrollExtent,
                          );
                          rowScrollController.animateTo(
                            pos,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      });
                    }

                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10),
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
                          child: TVAudioCard(
                            onTap: () =>
                                _onhandleMusicPlay(song, container),
                            audio: song,
                            initialIndex: index,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _onhandleMusicPlay(AudioDescription song, AudioContainer container) {
    final int categoryIndex = _audioContainers.indexOf(container);
    final previousFocusState = _captureFocusState();

    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(
          builder: (context) => TVMusicPlayerPage(
            categoryId: categoryIndex,
            categoryName: container.categoryName,
            audioDescriptions: container.audiolist,
            initialIndex: container.audiolist.indexOf(song),
          ),
        ))
        .then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // FIX: restore to Music page (index 2), not 0
        FocusManagerService.currentPage = 2;
        FocusManagerService.globalFocusNode.requestFocus();
        FocusManagerService.restoreFocusState(previousFocusState);
      });
    });
  }

  void _onSeeMorePressed(AudioContainer container) {
    final int categoryIndex = _audioContainers.indexOf(container);
    final previousFocusState = _captureFocusState();

    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(
          builder: (context) => TVCategoryBasedSong(
            categoryId: categoryIndex,
            categoryName: container.categoryName,
            audioDescriptions: container.audiolist,
          ),
        ))
        .then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // FIX: restore to Music page (index 2), not 0
        FocusManagerService.currentPage = 2;
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
        'currentPage': 2, // Music is always page 2
      };
}