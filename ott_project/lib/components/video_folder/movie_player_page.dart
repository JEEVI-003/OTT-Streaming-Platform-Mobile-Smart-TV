import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:ott_project/components/video_folder/cast_crew.dart';
import 'package:ott_project/components/video_folder/video_container.dart';
import 'package:ott_project/service/movie_api_service.dart';
import 'package:ott_project/service/movie_service_page.dart';
import 'package:ott_project/service/service.dart';
import 'package:ott_project/service/watch_later_service.dart';
import 'package:ott_project/url.dart';

import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'package:video_player/video_player.dart';

class MoviesPlayerPage extends StatefulWidget {
  final List<VideoDescription> videoDescriptions;
  final int initialIndex;
  final int categoryId;

  const MoviesPlayerPage({
    super.key,
    required this.videoDescriptions,
    required this.categoryId,
    this.initialIndex = 0,
  });

  @override
  _MoviesPlayerPageState createState() => _MoviesPlayerPageState();
}

class _MoviesPlayerPageState extends State<MoviesPlayerPage> {
  // Nullable controller so dispose() never throws LateInitializationError
  VideoPlayerController? _controller;

  // Future stored as a field; ValueKey(_currentIndex) on
  // FutureBuilder forces it to rebuild when the index changes.
  late Future<void> _initializeVideoPlayerFuture;

  late int _currentIndex;
  List<CastCrew> castCrew = [];
  List<VideoDescription> suggestedMovies = [];
  late MovieApiService _apiService;
  late WatchLaterService _watchLater;

  // Nullable so _buildMovieDetails() can guard before assigned.
  VideoDescription? _movieDetails;

  bool isFullScreen = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool isInWatchList = false;
  bool isAddingtoWatchList = false;

  // Nullable int so "userId == null" guard actually fires.
  int? userId;

  // Tracks whether the listener has been attached to prevent
  // double-listener memory leaks on next/previous switch.
  bool _listenerAttached = false;

  // Prevents double-pop on fast taps / gesture spam.
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _apiService = MovieApiService();
    _watchLater = WatchLaterService();
    _initializeVideoPlayerFuture = _fetchVideoScreenDetails(
      widget.videoDescriptions[_currentIndex].id,
      widget.categoryId,
    );
    fetchSuggestedMovies();
    _initializeUserWatchList();
  }

  // ---------------------------------------------------------------------------
  // Video initialisation
  // ---------------------------------------------------------------------------

  Future<void> _fetchVideoScreenDetails(int videoId, int categoryId) async {
    try {
      final details =
          await _apiService.fetchVideoScreenDetails(videoId, categoryId);

      if (!mounted) return;
      setState(() {
        _movieDetails = details;
      });

      if (details.castAndCrewList.isNotEmpty) {
        final crew =
            await _apiService.fetchCastAndCrew(details.castAndCrewList);
        if (!mounted) return;
        setState(() {
          castCrew = crew;
        });
      }

      await _initializeVideoPlayer(details.id);
    } catch (e) {
      // Rethrow so FutureBuilder shows the error state.
      rethrow;
    }
  }

  Future<void> _initializeVideoPlayer(int videoId) async {
    try {
      final String streamUrl =
          await _apiService.fetchVideoStreamUrl(videoId);

      // Use networkUrl() (non-deprecated API).
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(streamUrl));

      await controller.initialize();

      if (!mounted) {
        // Widget was disposed while we awaited — clean up and bail.
        controller.dispose();
        return;
      }

      controller.setLooping(true);
      controller.setVolume(1.0);

      // Attach listener only once per controller instance.
      if (!_listenerAttached) {
        controller.addListener(_onControllerUpdate);
        _listenerAttached = true;
      }

      setState(() {
        _controller = controller;
        _showControls = true;
      });

      _startHideControlsTimer();
      controller.play();
    } catch (e) {
      rethrow;
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  // Centralised switch that disposes old controller first.
  Future<void> _switchVideo(int newIndex) async {
    _listenerAttached = false;
    final old = _controller;
    _controller = null;
    old?.removeListener(_onControllerUpdate);
    await old?.dispose();

    if (!mounted) return;

    setState(() {
      _currentIndex = newIndex;
      _movieDetails = null;
      castCrew = [];
      _initializeVideoPlayerFuture = _fetchVideoScreenDetails(
        widget.videoDescriptions[_currentIndex].id,
        widget.categoryId,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Safe back navigation
  // ---------------------------------------------------------------------------

  Future<void> _safeBack() async {
    if (_isPopping) return;
    _isPopping = true;

    try {
      await _controller?.pause();
    } catch (_) {}

    _hideControlsTimer?.cancel();

    if (isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // ---------------------------------------------------------------------------
  // Playback controls
  // ---------------------------------------------------------------------------

  void _playPrevious() {
    if (_currentIndex > 0) {
      _switchVideo(_currentIndex - 1);
    }
  }

  void _playNext() {
    if (_currentIndex < widget.videoDescriptions.length - 1) {
      _switchVideo(_currentIndex + 1);
    }
  }

  void skipForward() {
    final ctrl = _controller;
    if (ctrl == null) return;
    final newPosition = ctrl.value.position + const Duration(seconds: 10);
    ctrl.seekTo(newPosition);
  }

  void skipBackward() {
    final ctrl = _controller;
    if (ctrl == null) return;
    final newPosition = ctrl.value.position - const Duration(seconds: 10);
    ctrl.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  // ---------------------------------------------------------------------------
  // Suggested movies
  // ---------------------------------------------------------------------------

  Future<void> fetchSuggestedMovies() async {
    try {
      final videoContainers = await MovieService.fetchVideoContainer();
      final matchingContainers = videoContainers.firstWhere(
        (container) => container.categoryId == widget.categoryId,
        orElse: () => throw Exception('No matching category found'),
      );
      final movies = matchingContainers.videoDescriptions;
      for (var movie in movies) {
        await movie.fetchImage();
      }
      if (!mounted) return;
      setState(() {
        suggestedMovies = movies.take(5).toList();
      });
    } catch (e) {
      // Silently ignore — suggested movies are non-critical.
    }
  }

  // ---------------------------------------------------------------------------
  // Watch-later
  // ---------------------------------------------------------------------------

  Future<void> _initializeUserWatchList() async {
    try {
      final currentUser = await Service().getLoggedInUserId();
      if (!mounted) return;
      if (currentUser != null) {
        setState(() {
          userId = currentUser;
        });
        await _checkWatchLaterStatus();
      }
    } catch (e) {
      // Non-critical — silently ignore.
    }
  }

  Future<void> _checkWatchLaterStatus() async {
    final uid = userId;
    if (uid == null || _movieDetails == null) return;
    try {
      final watchList = await _watchLater.getWatchLaterVideos(uid);
      if (!mounted) return;
      setState(() {
        isInWatchList =
            watchList.any((item) => item.videoId == _movieDetails!.id);
      });
    } catch (e) {
      // Non-critical — silently ignore.
    }
  }

  Future<void> _toggleWatchLater() async {
    if (isAddingtoWatchList) return;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please log in to use watchlist feature'),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ),
      );
      return;
    }
    if (_movieDetails == null) return;

    setState(() {
      isAddingtoWatchList = true;
    });
    try {
      if (isInWatchList) {
        await _watchLater.removeWatchLater(_movieDetails!.id, userId!);
      } else {
        await _watchLater.addToWatchLater(_movieDetails!.id, userId!);
      }
      if (!mounted) return;
      setState(() {
        isInWatchList = !isInWatchList;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isInWatchList
              ? 'Added to your watchlist'
              : 'Removed from your watchlist'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update your watchlist'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAddingtoWatchList = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _controller = null;
    // Always restore orientation and system UI on dispose.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Fullscreen helpers
  // ---------------------------------------------------------------------------

  void _toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
    });
    if (isFullScreen) {
      _enterFullScreen();
    } else {
      _exitFullScreen();
    }
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  // ---------------------------------------------------------------------------
  // Controls visibility
  // FIX: Removed _toggleControlsVisibility which used Future.delayed (leaks
  // after dispose). All control toggling now goes through _toggleControls
  // backed by a properly-cancelled Timer.
  // ---------------------------------------------------------------------------

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Utility
  // ---------------------------------------------------------------------------

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  // ---------------------------------------------------------------------------
  // Share
  // ---------------------------------------------------------------------------

  void _showShareOptions(BuildContext context) {
    final movie = _movieDetails;
    if (movie == null) return;
    final String shareUrl = '$baseUrl/GetvideoDetail/${movie.id}';
    final String shareText =
        'Check out "${movie.videoTitle}" on Our Movie App!';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading:
                    const Icon(Icons.messenger_outline, color: Colors.white),
                title: const Text('Send in Messenger',
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  await _launchUrlWithFallback(
                      'fb-messenger://share/?link=$shareUrl',
                      'https://www.messenger.com/share/?link=$shareUrl');
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.whatsapp,
                    color: Colors.white),
                title: const Text('Share on WhatsApp',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _shareViaWhatsApp(shareText, shareUrl);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.link, color: Colors.white),
                title: const Text('Copy link',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: shareUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Link copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareViaWhatsApp(
      String shareText, String shareUrl) async {
    final String whatsappUrl =
        'whatsapp://send?text=${Uri.encodeComponent('$shareText $shareUrl')}';
    try {
      final Uri whatsappUri = Uri.parse(whatsappUrl);
      if (await url_launcher.canLaunchUrl(whatsappUri)) {
        await url_launcher.launchUrl(whatsappUri);
      } else {
        throw 'WhatsApp is not installed';
      }
    } catch (e) {
      await Clipboard.setData(
          ClipboardData(text: '$shareText $shareUrl'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Couldn't open WhatsApp. Link copied to clipboard.")),
        );
      }
    }
  }

  Future<void> _launchUrlWithFallback(
      String url, String fallbackUrl) async {
    try {
      bool launched = await url_launcher.launchUrl(Uri.parse(url));
      if (!launched) {
        launched =
            await url_launcher.launchUrl(Uri.parse(fallbackUrl));
        if (!launched) throw 'Could not launch $fallbackUrl';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Failed to open app. Please try another sharing method.')),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // PopScope intercepts the Android system back button AND back gesture.
    // canPop: false — Flutter will NOT auto-pop; we drive the pop ourselves.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (isFullScreen) {
          setState(() => isFullScreen = false);
          _exitFullScreen();
          return;
        }
        _safeBack();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Main content area
            FutureBuilder<void>(
              // ValueKey forces FutureBuilder to rebuild on index change.
              key: ValueKey(_currentIndex),
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load video.\n${snapshot.error}',
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _initializeVideoPlayerFuture =
                                    _fetchVideoScreenDetails(
                                  widget.videoDescriptions[_currentIndex].id,
                                  widget.categoryId,
                                );
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Guard: controller must be ready before rendering player.
                final ctrl = _controller;
                if (ctrl == null || !ctrl.value.isInitialized) {
                  return const Center(child: CircularProgressIndicator());
                }

                // FIX: _buildFullScreenPlayer no longer calls _buildVideoPlayer
                // (which wraps in SafeArea + AspectRatio again causing layout
                // issues). Fullscreen renders the video directly in an expand-
                // filling Stack and shows controls as a proper overlay.
                return isFullScreen
                    ? _buildFullScreenPlayer(ctrl)
                    : SafeArea(
                        child: Stack(
                          children: [
                            BackgroundImage(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 10),
                                _buildVideoPlayer(ctrl),
                                if (_movieDetails != null)
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: _buildMovieDetails(),
                                    ),
                                  ),
                              ],
                            ),
                            _buildSuggestedMoviesDrawer(),
                          ],
                        ),
                      );
              },
            ),

            // Permanent back arrow — always visible, outside FutureBuilder.
            if (!isFullScreen)
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _safeBack,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Permanent back arrow — fullscreen mode.
            if (isFullScreen)
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          setState(() => isFullScreen = false);
                          _exitFullScreen();
                          _safeBack();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Player widgets
  // ---------------------------------------------------------------------------

  /// FIX: Fullscreen player now renders the video in a proper expand-filling
  /// Stack. Controls overlay is shown as an AnimatedOpacity layer on top.
  /// Previously this called _buildVideoPlayer() which re-wrapped in SafeArea
  /// and AspectRatio — causing "UI freeze" and layout overflow in fullscreen.
  Widget _buildFullScreenPlayer(VideoPlayerController ctrl) {
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video fills the entire screen in fullscreen mode.
          Center(
            child: AspectRatio(
              aspectRatio: ctrl.value.aspectRatio,
              child: VideoPlayer(ctrl),
            ),
          ),
          // Buffering indicator.
          if (ctrl.value.isBuffering)
            const Center(child: CircularProgressIndicator()),
          // Controls overlay — shown/hidden on tap.
          if (_showControls)
            Positioned.fill(
              child: buildControls(ctrl),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(VideoPlayerController ctrl) {
    return Center(
      child: AspectRatio(
        aspectRatio: ctrl.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              onTap: _toggleControls,
              child: VideoPlayer(ctrl),
            ),
            if (ctrl.value.isBuffering)
              const Center(child: CircularProgressIndicator()),
            // FIX: Controls rendered as Positioned.fill so they always sit on
            // top of the video surface and don't accidentally intercept taps
            // when hidden.
            if (_showControls)
              Positioned.fill(
                child: buildControls(ctrl),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildControls(VideoPlayerController ctrl) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black54,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(ctrl.value.position),
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  _formatDuration(ctrl.value.duration),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Slider(
            activeColor: Colors.red,
            inactiveColor: Colors.grey,
            value: ctrl.value.position.inSeconds
                .clamp(0, ctrl.value.duration.inSeconds)
                .toDouble(),
            max: ctrl.value.duration.inSeconds > 0
                ? ctrl.value.duration.inSeconds.toDouble()
                : 1.0,
            onChanged: (value) {
              ctrl.seekTo(Duration(seconds: value.toInt()));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLeftControls(ctrl),
                _buildRightControls(),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLeftControls(VideoPlayerController ctrl) {
    return Row(
      children: [
        IconButton(
          onPressed: _playPrevious,
          icon: const Icon(Icons.skip_previous, size: 25, color: Colors.white),
        ),
        IconButton(
          onPressed: skipBackward,
          icon: const Icon(Icons.replay_10_rounded, size: 25, color: kWhite),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              if (ctrl.value.isPlaying) {
                ctrl.pause();
              } else {
                ctrl.play();
              }
            });
            // Reset auto-hide timer on play/pause.
            _startHideControlsTimer();
          },
          icon: Icon(
            ctrl.value.isPlaying ? Icons.pause : Icons.play_arrow,
            size: 25,
            color: kWhite,
          ),
        ),
        IconButton(
          onPressed: skipForward,
          icon: const Icon(Icons.forward_10_rounded, size: 25, color: kWhite),
        ),
        IconButton(
          onPressed: _playNext,
          icon: const Icon(Icons.skip_next, size: 25, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildRightControls() {
    return Row(
      children: [
        IconButton(
          onPressed: _toggleFullScreen,
          icon: Icon(
            isFullScreen
                ? Icons.fullscreen_exit_rounded
                : Icons.fullscreen_rounded,
            size: 25,
            color: kWhite,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Movie details
  // ---------------------------------------------------------------------------

  Widget _buildMovieDetails() {
    final movie = _movieDetails!;
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
          Text(
            movie.videoTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
          Text(
            '${movie.mainVideoDuration}',
            style: const TextStyle(color: Colors.grey),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
          const Text(
            'Cast And Crew',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.12,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: castCrew.length,
              itemBuilder: (context, index) {
                final cast = castCrew[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: cast.image != null
                            ? MemoryImage(cast.image!)
                            : const AssetImage('assets/icon/thupaki.png')
                                as ImageProvider,
                      ),
                      SizedBox(
                          height:
                              MediaQuery.sizeOf(context).height * 0.01),
                      SizedBox(
                        width: 79,
                        child: Text(
                          cast.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
          const Text(
            'Description',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          Text(
            '${movie.description}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Watch-later button
  // ---------------------------------------------------------------------------

  Widget _buildWatchLaterButton() {
    if (userId == null) {
      return ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/login'),
        icon: const Icon(Icons.login, color: Colors.white),
        label: const Text('Login to Add',
            style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 65, 65, 100)),
      );
    }
    return ElevatedButton.icon(
      onPressed: isAddingtoWatchList ? null : _toggleWatchLater,
      icon: Icon(
        isInWatchList ? Icons.check : Icons.add_box_outlined,
        color: Colors.white,
      ),
      label: Text(
        isInWatchList ? 'Remove from Watchlater' : 'Add To Watchlater',
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 65, 65, 100)),
    );
  }

  // ---------------------------------------------------------------------------
  // Suggested movies drawer
  // ---------------------------------------------------------------------------

  bool isDrawerOpen = false;

  Widget _buildSuggestedMoviesDrawer() {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.15,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () {
            setState(() {
              isDrawerOpen = !isDrawerOpen;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showShareOptions(context),
                          icon: const Icon(Icons.share_rounded,
                              color: Colors.white),
                          label: const Text('Share',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 65, 65, 100)),
                        ),
                        _buildWatchLaterButton(),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Suggestion Movie',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(
                        suggestedMovies.length,
                        (index) => Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MoviesPlayerPage(
                                        videoDescriptions:
                                            widget.videoDescriptions,
                                        categoryId: widget.categoryId,
                                        initialIndex: index,
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FutureBuilder<Uint8List?>(
                                    future:
                                        suggestedMovies[index].thumbnailImage,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey);
                                      }
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        return SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: Image.memory(snapshot.data!,
                                              fit: BoxFit.fill),
                                        );
                                      }
                                      return Image.asset(
                                          'assets/icon/media_jungle.png');
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.sizeOf(context).height *
                                      0.02),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.sizeOf(context).width *
                                        0.02),
                                child: Text(
                                  suggestedMovies[index].videoTitle,
                                  style: const TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
