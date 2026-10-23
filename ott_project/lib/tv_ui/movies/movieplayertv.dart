import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ott_project/components/category/category_service.dart';
import 'package:ott_project/components/video_folder/cast_crew.dart';
import 'package:ott_project/components/video_folder/video_container.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/service/movie_api_service.dart';
import 'package:ott_project/service/movie_service_page.dart';
import 'package:ott_project/service/watch_later_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:ott_project/tv_ui/components/tvlayout.dart';
import 'package:ott_project/tv_ui/FocusManager/videoplayer_focusmanager.dart';
import 'package:video_player/video_player.dart';
import 'package:ott_project/service/service.dart';

class TVMoviesPlayerPage extends StatefulWidget {
  final int categoryId;
  final List<VideoDescription> videoDescriptions;
  final int initialIndex;

  const TVMoviesPlayerPage({
    Key? key,
    required this.categoryId,
    required this.videoDescriptions,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _TVMoviesPlayerPageState createState() => _TVMoviesPlayerPageState();
}

class _TVMoviesPlayerPageState extends State<TVMoviesPlayerPage> {
  VideoPlayerController? _videoController;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _showSettings = false;
  double _playbackSpeed = 1.0;
  double _volume = 1.0;
  bool _showSpeedOptions = false;
  late MovieApiService _apiService;

  Map<int, bool> videoWatchlistState = {};
  final Service service = Service();
  late CategoryService categoryService;
  VideoDescription? _movieDetails;
  List<CastCrew> castCrew = [];
  List<String> _categoryNames = [];
  late VideoFocusManager _videoFocusManager;
  bool _isFullScreen = false;
  bool _isPlaying = false;
  int selectedIndex = FocusManagerService.selectedSidebarIndex;
  Uint8List? _cachedThumbnail;

  // Prevents double-pop
  bool _isPopping = false;

  // FIX: Private keyboard focus node — must NOT be globalFocusNode.
  // While this page is on top, this node exclusively handles key events.
  // On dispose, we re-focus the correct caller node (gridFocusNode or
  // globalFocusNode) so the page underneath resumes input handling.
  final FocusNode _playerKeyboardFocusNode =
      FocusNode(debugLabel: 'moviePlayerKeyboard');

  void _onSidebarSelected(int index) {
    setState(() {
      selectedIndex = index;
      FocusManagerService.selectedSidebarIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    FocusManagerService.currentPage = 1;
    _apiService = MovieApiService();
    categoryService = CategoryService();

    _videoFocusManager = VideoFocusManager(
      onSeek: (bool forward) => _seekVideo(forward ? 10 : -10),
      onUserInteraction: _resetControlsVisibility,
      onPlayPause: _togglePlayPause,
      onFullScreen: _toggleFullScreen,
      onToggleSettings: _toggleSettings,
      onPlaybackSpeedSelected: _onPlaybackspeedoptions,
      onChangePlaybackSpeed: _changePlaybackSpeed,
      onPlayMovie: _handlePlayMovie,
      onAddToWatchLater: () {
        if (_movieDetails != null) _toggleWatchLater(_movieDetails!.id);
      },
      isFullScreen: () => _isFullScreen,
      isMoviePlaying: () => _videoController?.value.isPlaying ?? false,
      onBack: _handleBackNavigation,
    );

    FocusManagerService.videoFocusManager = _videoFocusManager;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Claim keyboard focus for this page only
      _playerKeyboardFocusNode.requestFocus();

      if (widget.videoDescriptions.isNotEmpty &&
          widget.initialIndex < widget.videoDescriptions.length) {
        await _fetchVideoScreenDetails(
          widget.videoDescriptions[widget.initialIndex].id,
          widget.categoryId,
        );
      }
    });
  }

  Future<void> _initializeVideoPlayer(int videoId) async {
    try {
      final String videoStreamUrl =
          await MovieService.fetchVideoStreamUrl(videoId);

      final controller =
          VideoPlayerController.networkUrl(Uri.parse(videoStreamUrl));
      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      controller.setLooping(false);
      controller.setVolume(_volume);
      controller.setPlaybackSpeed(_playbackSpeed);
      controller.addListener(_onControllerUpdate);

      setState(() {
        _videoController = controller;
        _isPlaying = false;
      });

      _resetControlsVisibility();
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _startVideoPlayback() {
    if (!(_videoController?.value.isInitialized ?? false)) return;
    setState(() => _isPlaying = true);
    _updateWakelockState();
    _videoController!.play();
  }

  void _updateWakelockState() {
    if (_isPlaying) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  Future<void> _fetchVideoScreenDetails(int videoId, int categoryId) async {
    try {
      final movieDetails =
          await _apiService.fetchVideoScreenDetails(videoId, categoryId);
      if (movieDetails == null) return;

      final List<CastCrew> castList = movieDetails.castAndCrewList.isNotEmpty
          ? (await _apiService.fetchCastAndCrew(movieDetails.castAndCrewList))
              .cast<CastCrew>()
          : [];

      await CategoryService().loadCategories();
      final categoryNames =
          categoryService.getCategoryNames(movieDetails.categoryList);

      if (movieDetails.thumbnailImage != null) {
        _cachedThumbnail = await movieDetails.thumbnailImage;
      }

      await _initializeVideoPlayer(videoId);

      if (!mounted) return;
      setState(() {
        _movieDetails = movieDetails;
        castCrew = castList;
        _categoryNames = categoryNames;
      });

      // FIX: Re-assert focus after heavy async work — network calls can
      // cause Flutter to shift focus away from our private node.
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _playerKeyboardFocusNode.requestFocus());
    } catch (e) {
      debugPrint('Error fetching video screen details: $e');
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
        if (_isPlaying) WakelockPlus.enable();
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        _showControls = true;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playerKeyboardFocusNode.requestFocus();
      _resetControlsVisibility();
    });
  }

  void _togglePlayPause() {
    if (!(_videoController?.value.isInitialized ?? false)) return;
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _isPlaying = false;
      } else {
        _videoController!.play();
        _isPlaying = true;
      }
      _updateWakelockState();
    });
    _resetControlsVisibility();
  }

  void _onPlaybackspeedoptions() {
    setState(() => _showSpeedOptions = !_showSpeedOptions);
  }

  void _toggleSettings() {
    setState(() => _showSettings = !_showSettings);
  }

  void _resetControlsVisibility() {
    if (!mounted) return;
    setState(() => _showControls = true);
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _seekVideo(int seconds) {
    final ctrl = _videoController;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    final newPosition = ctrl.value.position + Duration(seconds: seconds);
    ctrl.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _handleBackNavigation() {
    if (_isPopping) return;

    if (_isFullScreen) {
      setState(() => _isFullScreen = false);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _playerKeyboardFocusNode.requestFocus());
      return;
    }

    _isPopping = true;
    try {
      _videoController?.pause();
    } catch (_) {}

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();

    // FIX: Null the global reference FIRST so TVMainPage's guard
    // (videoFocusManager != null → return) stops blocking immediately.
    FocusManagerService.videoFocusManager = null;

    _videoController?.removeListener(_onControllerUpdate);
    _videoController?.dispose();
    _videoController = null;

    _playerKeyboardFocusNode.dispose();

    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // FIX: Re-focus the correct node for whoever is now on top of the stack.
    //
    // Stack: TVMainPage → TVMoviesPlayerPage
    //   → re-focus globalFocusNode
    //
    // Stack: TVMainPage → TVCategoryBasedMovie → TVMoviesPlayerPage
    //   → re-focus gridFocusNode (TVCategoryBasedMovie's node)
    //
    // TVCategoryBasedMovie registers its FocusNode in
    // FocusManagerService.gridFocusNode. Prefer that if available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gridNode = FocusManagerService.gridFocusNode;
      if (gridNode != null) {
        gridNode.requestFocus();
      } else {
        FocusManagerService.globalFocusNode.requestFocus();
      }
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Loading state is ALSO wrapped in KeyboardListener so back/escape
    // always works, even while movie data is being fetched over the network.
    if (_movieDetails == null) {
      return KeyboardListener(
        focusNode: _playerKeyboardFocusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape ||
                event.logicalKey == LogicalKeyboardKey.goBack ||
                event.logicalKey == LogicalKeyboardKey.browserBack) {
              _handleBackNavigation();
            }
          }
        },
        child: TVLayout(
          onSidebarSelected: _onSidebarSelected,
          selectedIndex: selectedIndex,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF070708), Color(0xFF1D1B53)],
              ),
            ),
            child: Stack(
              children: [
                const Center(child: CircularProgressIndicator()),
                Positioned(
                  top: 20,
                  left: 20,
                  child: IconButton(
                    onPressed: _handleBackNavigation,
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isWatchlisted = videoWatchlistState[_movieDetails!.id] ?? false;

    // PopScope: canPop:false — we control all pops ourselves to avoid double-pop.
    final playerContent = PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF070708), Color(0xFF1D1B53)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width,
                height: _isFullScreen
                    ? MediaQuery.of(context).size.height
                    : MediaQuery.of(context).size.height * 0.5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _isPlaying && _videoController != null
                        ? AspectRatio(
                            aspectRatio: _isFullScreen
                                ? _videoController!.value.aspectRatio
                                : 16 / 9,
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: VideoPlayer(_videoController!),
                            ),
                          )
                        : ClipRect(
                            child: _cachedThumbnail != null
                                ? Image.memory(_cachedThumbnail!,
                                    fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.white),
                                    ),
                                  ),
                          ),
                    if (!_isPlaying)
                      Positioned(
                        bottom: 5,
                        left: 5,
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: _handlePlayMovie,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(5)),
                                backgroundColor:
                                    _videoFocusManager.isPlayMovieFocused()
                                        ? const Color.fromARGB(
                                            255, 143, 228, 0)
                                        : const Color.fromARGB(
                                            255, 193, 39, 45),
                              ),
                              child: Text(
                                _movieDetails?.videoAccessType == true
                                    ? 'Subscription'
                                    : 'Play Now',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 5),
                            ElevatedButton(
                              onPressed: () async {
                                if (_movieDetails != null) {
                                  await _toggleWatchLater(
                                      _movieDetails!.id);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _videoFocusManager
                                        .isAddToWatchLaterFocused()
                                    ? const Color.fromARGB(
                                        255, 143, 228, 0)
                                    : const Color.fromARGB(135, 0, 0, 0),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.add_circle_outline,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    isWatchlisted
                                        ? 'Remove from watchlater'
                                        : 'Add to watchlater',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Back button — always visible
                    Positioned(
                      top: 20,
                      left: 20,
                      child: IconButton(
                        onPressed: _handleBackNavigation,
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 30),
                      ),
                    ),
                    if (_showControls && _isPlaying) _buildVideoControls(),
                  ],
                ),
              ),
              if (!_isFullScreen) Expanded(child: _buildMovieDetails()),
            ],
          ),
        ),
      ),
    );

    return KeyboardListener(
      focusNode: _playerKeyboardFocusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape ||
              event.logicalKey == LogicalKeyboardKey.goBack ||
              event.logicalKey == LogicalKeyboardKey.browserBack) {
            _handleBackNavigation();
            return;
          }
        }
        _videoFocusManager.handleKeyEvent(event);
      },
      child: _isFullScreen
          ? playerContent
          : TVLayout(
              child: playerContent,
              onSidebarSelected: _onSidebarSelected,
              selectedIndex: selectedIndex,
            ),
    );
  }

  Widget _buildMovieDetails() {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _movieDetails!.videoTitle,
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.height * 0.04,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.005),
                    Text(
                      _categoryNames.isNotEmpty
                          ? _categoryNames.join(" / ")
                          : "Unknown",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize:
                              MediaQuery.of(context).size.height * 0.02),
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.02),
                    Row(
                      children: [
                        Text(
                          'Duration : ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.03,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _movieDetails!.mainVideoDuration,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.03,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.02),
                    Row(
                      children: [
                        Text(
                          "Description:  ",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.025,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _movieDetails!.description,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.025,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.02),
                  ],
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cast & Crew',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.height * 0.03,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                      height:
                          MediaQuery.of(context).size.height * 0.02),
                  castCrew.length > 3
                      ? SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 0.3,
                          width:
                              MediaQuery.of(context).size.width * 0.3,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (_) => true,
                            child: GridView.builder(
                              controller:
                                  _videoFocusManager.scrollController,
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 45.0,
                                mainAxisSpacing: 40.0,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: castCrew.length,
                              itemBuilder: (context, index) {
                                final cast = castCrew[index];
                                return SizedBox.expand(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: MediaQuery.of(context)
                                                .size
                                                .height *
                                            0.04,
                                        backgroundImage: cast.image !=
                                                null
                                            ? MemoryImage(cast.image!)
                                            : const AssetImage(
                                                    'assets/icon/thupaki.png')
                                                as ImageProvider,
                                      ),
                                      SizedBox(
                                          height:
                                              MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                      SizedBox(
                                        width: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.12,
                                        child: Text(
                                          cast.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 0.15,
                          width:
                              MediaQuery.of(context).size.width * 0.3,
                          child: ListView.builder(
                            controller:
                                _videoFocusManager.scrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: castCrew.length,
                            itemBuilder: (context, index) {
                              final cast = castCrew[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.only(right: 12.0),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.05,
                                      backgroundImage: cast.image != null
                                          ? MemoryImage(cast.image!)
                                          : const AssetImage(
                                                  'assets/icon/thupaki.png')
                                              as ImageProvider,
                                    ),
                                    SizedBox(
                                        height: MediaQuery.of(context)
                                                .size
                                                .height *
                                            0.01),
                                    SizedBox(
                                      width: MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.15,
                                      child: Text(
                                        cast.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePlayMovie() async {
    if (_movieDetails == null) return;
    if (!(_videoController?.value.isInitialized ?? false)) {
      await _initializeVideoPlayer(_movieDetails!.id);
    }
    _startVideoPlayback();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _playerKeyboardFocusNode.requestFocus());
  }

  Future<void> _toggleWatchLater(int videoId) async {
    if (_movieDetails == null) return;
    try {
      final currentUser = await service.getLoggedInUserId();
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please log in to add to watchlist.')),
          );
        }
        return;
      }

      final watchLaterService = WatchLaterService();
      final isInWatchList =
          await watchLaterService.isInWatchList(videoId, currentUser);

      if (isInWatchList) {
        await watchLaterService.removeWatchLater(videoId, currentUser);
        if (mounted) {
          setState(() => videoWatchlistState[videoId] = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from watchlist.')),
          );
        }
      } else {
        await watchLaterService.addToWatchLater(videoId, currentUser);
        if (mounted) {
          setState(() => videoWatchlistState[videoId] = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to watchlist.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error toggling watchlist: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update watchlist.')),
        );
      }
    }
  }

  Widget _buildVideoControls() {
    if (!(_videoController?.value.isInitialized ?? false)) {
      return const SizedBox();
    }

    final maxVal = _videoController!.value.duration.inSeconds > 0
        ? _videoController!.value.duration.inSeconds.toDouble()
        : 1.0;
    final curVal = _videoController!.value.position.inSeconds
        .clamp(0, _videoController!.value.duration.inSeconds)
        .toDouble();

    return Stack(
      children: [
        Container(
          color: Colors.black54,
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _togglePlayPause,
                        icon: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: _videoFocusManager.isPlayButtonFocused()
                              ? Colors.blue
                              : Colors.white,
                          size: 30,
                        ),
                      ),
                      Text(
                        "${_formatDuration(_videoController!.value.position)} / ${_formatDuration(_videoController!.value.duration)}",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _toggleFullScreen,
                        icon: Icon(
                          _isFullScreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color:
                              _videoFocusManager.isFullScreenFocused()
                                  ? Colors.blue
                                  : Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.more_vert_outlined,
                          color: _videoFocusManager.isSettingsFocused()
                              ? Colors.blue
                              : Colors.white,
                          size: 30,
                        ),
                        onPressed: _toggleSettings,
                      ),
                    ],
                  ),
                ],
              ),
              Slider(
                activeColor: _videoFocusManager.isSliderFocused()
                    ? Colors.blue
                    : Colors.red,
                inactiveColor: Colors.white30,
                min: 0.0,
                max: maxVal,
                value: curVal,
                onChangeStart: (_) {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  }
                },
                onChanged: (value) {
                  setState(() {
                    _videoController!
                        .seekTo(Duration(seconds: value.toInt()));
                  });
                },
                onChangeEnd: (value) {
                  if (!_videoController!.value.isPlaying && _isPlaying) {
                    _videoController!.play();
                  }
                  _resetControlsVisibility();
                },
              ),
            ],
          ),
        ),
        if (_showSettings) _buildSettingsMenu(),
      ],
    );
  }

  Widget _buildSettingsMenu() {
    return Positioned(
      bottom: 50,
      right: 20,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80, right: 20),
        child: Container(
          width: 150,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 8),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.arrow_back,
                    color: _videoFocusManager.getSettingsIndex() == 0
                        ? Colors.blue
                        : Colors.white,
                    size: 10),
                title: Text("Back",
                    style: TextStyle(
                        color: _videoFocusManager.getSettingsIndex() == 0
                            ? Colors.blue
                            : Colors.white,
                        fontSize: 10)),
                onTap: () {
                  setState(() {
                    _showSettings = false;
                    _showSpeedOptions = false;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.speed,
                    color: _videoFocusManager.getSettingsIndex() == 1
                        ? Colors.blue
                        : Colors.white,
                    size: 10),
                title: Text("Playback Speed",
                    style: TextStyle(
                        color: _videoFocusManager.getSettingsIndex() == 1
                            ? Colors.blue
                            : Colors.white,
                        fontSize: 10)),
                onTap: _onPlaybackspeedoptions,
              ),
              if (_showSpeedOptions) _buildSpeedOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedOptions() {
    const speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        controller: _videoFocusManager.scrollController,
        child: Column(
          children: List.generate(speeds.length, (index) {
            return ListTile(
              title: Text(
                speeds[index] == 1.0 ? "Normal" : "${speeds[index]}x",
                style: TextStyle(
                  color: _videoFocusManager.getSubMenuIndex() == index
                      ? Colors.blue
                      : Colors.white,
                  fontSize: 10,
                ),
              ),
              onTap: () => _changePlaybackSpeed(speeds[index]),
            );
          }),
        ),
      ),
    );
  }

  void _changePlaybackSpeed(double speed) {
    if (_videoController == null) return;
    setState(() {
      _playbackSpeed = speed;
      _videoController!.setPlaybackSpeed(_playbackSpeed);
      _showSpeedOptions = false;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}