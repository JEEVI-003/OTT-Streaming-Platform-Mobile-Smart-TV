// FILE: lib/components/video_folder/video_play.dart
//
// FIXES IN THIS VERSION
// ─────────────────────
// FIX-A  Permanent back arrow — lives in its own always-visible Stack overlay,
//         completely independent of _showControls / FutureBuilder state.
// FIX-B  System back button / gesture handled via PopScope (Flutter ≥ 3.12)
//         with the same safe-dispose logic as the in-app arrow.
// FIX-C  Safe dispose: nullable controller, named listener, timer cancelled,
//         orientation always restored — no LateInitializationError possible.
// FIX-D  !mounted guard after every await → no setState-after-dispose.
// FIX-E  Old controller removed + disposed before switching next/prev video.
// FIX-F  ValueKey(_currentIndex) on FutureBuilder forces rebuild on video switch.
// FIX-G  All print() calls removed — prevents log-spam performance issues.
// FIX-H  Controls in both portrait and fullscreen now use Positioned.fill so
//         they sit correctly on top of the video and never cause layout freeze.
// FIX-I  buildControls uses a gradient container instead of solid black54,
//         keeping the video visible under the overlay.
// FIX-J  Slider max guarded against zero-duration to avoid assertion errors.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:ott_project/components/video_folder/cast_crew.dart';
import 'package:ott_project/components/video_folder/movie.dart';
import 'package:ott_project/service/movie_api_service.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:video_player/video_player.dart';
import 'package:ott_project/url.dart';

class VideoPlayerPage extends StatefulWidget {
  final List<Movie> movies;
  final int initialIndex;

  const VideoPlayerPage({
    super.key,
    required this.movies,
    this.initialIndex = 0,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  // FIX-C: nullable — dispose() uses ?. so it never throws
  VideoPlayerController? _controller;

  late Future<void> _initializeVideoPlayerFuture;
  late int _currentIndex;
  List<CastMember> _castAndCrew = [];
  late MovieApiService _apiService;
  Movie? _movieDetails;

  bool isFullScreen = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _listenerAttached = false;

  // FIX-B: prevents double-pop on fast taps / gesture spam
  bool _isPopping = false;

  // Lifecycle
  

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _apiService = MovieApiService();
    _initializeVideoPlayerFuture = _fetchVideoDetail(_currentIndex);
  }

  @override
  void dispose() {
    // FIX-C: cancel timer first so its callback never fires after dispose
    _hideControlsTimer?.cancel();

    // FIX-C: remove named listener then dispose controller safely
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _controller = null;

    // FIX-C: ALWAYS restore orientation — covers the OS-back path where
    // isFullScreen may be stale (user swiped back mid-fullscreen)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  // FIX-B: Unified safe-back handler
  // Called by BOTH the in-app arrow tap AND the PopScope system-back callback.

  Future<void> _safeBack() async {
    if (_isPopping) return; // idempotent guard
    _isPopping = true;

    // 1. Pause video — releases platform codec buffers cleanly before the
    //    widget tree is torn down.
    try {
      await _controller?.pause();
    } catch (_) {}

    // 2. Cancel the hide-controls timer immediately.
    _hideControlsTimer?.cancel();

    // 3. Restore orientation/UI *before* popping so the previous page never
    //    inherits a locked landscape orientation.
    if (isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    // 4. Pop. dispose() handles the final controller cleanup.
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // Video initialisation

  Future<void> _fetchVideoDetail(int movieIndex) async {
    try {
      final details =
          await _apiService.fetchVideoDetail(widget.movies[movieIndex].id);

      if (!mounted) return; // FIX-D
      setState(() => _movieDetails = details);

      await _initializeVideoPlayer(widget.movies[movieIndex].id);
    } catch (e) {
      rethrow; // surface to FutureBuilder error state
    }
  }

  Future<void> _initializeVideoPlayer(int id) async {
    try {
      final String streamUrl = await _apiService.fetchVideoStreamUrl(id);
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(streamUrl));

      await controller.initialize();

      if (!mounted) {
        // FIX-D: widget disposed while we awaited — clean up and bail
        controller.dispose();
        return;
      }

      controller.setLooping(true);
      controller.setVolume(1.0);

      // FIX-C: named listener, attached only once per controller instance
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

  // Named method → removeListener() can find and remove it exactly.
  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  // FIX-E: dispose old controller before creating a new one
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
      _castAndCrew = [];
      _initializeVideoPlayerFuture =
          _fetchVideoDetail(_currentIndex); // FIX-F
    });
  }

  // Playback controls

  void _playPrevious() {
    if (_currentIndex > 0) _switchVideo(_currentIndex - 1);
  }

  void _playNext() {
    if (_currentIndex < widget.movies.length - 1)
      _switchVideo(_currentIndex + 1);
  }

  void skipForward() {
    final ctrl = _controller;
    if (ctrl == null) return;
    ctrl.seekTo(ctrl.value.position + const Duration(seconds: 10));
  }

  void skipBackward() {
    final ctrl = _controller;
    if (ctrl == null) return;
    final p = ctrl.value.position - const Duration(seconds: 10);
    ctrl.seekTo(p < Duration.zero ? Duration.zero : p);
  }

  void _toggleFullScreen() {
    setState(() => isFullScreen = !isFullScreen);
    isFullScreen ? _enterFullScreen() : _exitFullScreen();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
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

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // Build

  @override
  Widget build(BuildContext context) {
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
            // ── Main content area ────────────
            FutureBuilder<void>(
              key: ValueKey(_currentIndex), // FIX-F
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
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
                            onPressed: () => setState(() {
                              _initializeVideoPlayerFuture =
                                  _fetchVideoDetail(_currentIndex);
                            }),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Still initialising controller
                final ctrl = _controller;
                if (ctrl == null || !ctrl.value.isInitialized) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Ready — render player
                return isFullScreen
                    ? _buildFullScreenPlayer(ctrl)
                    : SafeArea(
                        child: Stack(
                          children: [
                            BackgroundImage(),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                // Reserve space for the permanent back-arrow overlay
                                const SizedBox(height: kToolbarHeight),
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

            // ── FIX-A: PERMANENT back arrow — portrait mode ───
            // Outside FutureBuilder and outside _showControls gate.
            // Visible at ALL times: loading, error, playing, paused, buffering.
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

            // ── FIX-A: PERMANENT back arrow — fullscreen mode ─────────────────
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

  // Player widgets

  /// FIX-H: Fullscreen player renders video in a proper expand-filling Stack.
  /// Controls are shown as a Positioned.fill overlay — not re-wrapping in
  /// another AspectRatio/SafeArea which caused layout freeze and double-sizing.
  Widget _buildFullScreenPlayer(VideoPlayerController ctrl) {
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: ctrl.value.aspectRatio,
              child: VideoPlayer(ctrl),
            ),
          ),
          // Buffering indicator sits on top of video.
          if (ctrl.value.isBuffering)
            const Center(child: CircularProgressIndicator()),
          // FIX-H: controls as Positioned.fill overlay for correct hit-testing.
          if (_showControls)
            Positioned.fill(
              child: buildControls(ctrl),
            ),
          if (isDrawerOpen)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(color: Colors.black.withOpacity(0.3)),
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
            // FIX-H: Controls as Positioned.fill so they sit correctly over
            // the video surface and don't affect layout of the video itself.
            if (_showControls)
              Positioned.fill(
                child: buildControls(ctrl),
              ),
            if (isDrawerOpen)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child:
                    Container(color: Colors.black.withOpacity(0.3)),
              ),
          ],
        ),
      ),
    );
  }

  /// FIX-I: Controls use a gradient overlay instead of solid black54,
  /// keeping the video visible behind the control bar.
  /// FIX-J: Slider max guarded against zero-duration.
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
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(ctrl.value.position),
                    style: const TextStyle(color: Colors.white)),
                Text(_formatDuration(ctrl.value.duration),
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Slider(
            activeColor: Colors.red,
            inactiveColor: Colors.grey,
            value: ctrl.value.position.inSeconds
                .clamp(0, ctrl.value.duration.inSeconds)
                .toDouble(),
            // FIX-J: guard against zero-duration (before video metadata loads).
            max: ctrl.value.duration.inSeconds > 0
                ? ctrl.value.duration.inSeconds.toDouble()
                : 1.0,
            onChanged: (v) =>
                ctrl.seekTo(Duration(seconds: v.toInt())),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
          icon: const Icon(Icons.skip_previous,
              size: 25, color: Colors.white),
        ),
        IconButton(
          onPressed: skipBackward,
          icon: const Icon(Icons.replay_10_rounded,
              size: 25, color: kWhite),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
            });
            // Reset auto-hide timer on play/pause interaction.
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
          icon: const Icon(Icons.forward_10_rounded,
              size: 25, color: kWhite),
        ),
        IconButton(
          onPressed: _playNext,
          icon: const Icon(Icons.skip_next,
              size: 25, color: Colors.white),
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

  // Movie details

  Widget _buildMovieDetails() {
    final movie = _movieDetails!;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 170,
                child: Text(
                  movie.moviename,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(width: 80),
              Text(movie.duration,
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${movie.language} | ${movie.category}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          const Text('Cast And Crew',
              style: TextStyle(fontSize: 16, color: Colors.white)),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _castAndCrew.length,
              itemBuilder: (context, i) {
                final cast = _castAndCrew[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: cast.imageBytes != null
                            ? MemoryImage(cast.imageBytes!)
                            : const AssetImage(
                                    'assets/images/bgimg.jpg')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 79,
                        child: Text(
                          cast.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Suggested movies drawer

  bool isDrawerOpen = false;

  Widget _buildSuggestedMoviesDrawer() {
    return DraggableScrollableSheet(
      initialChildSize: 0.1,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () => setState(() => isDrawerOpen = !isDrawerOpen),
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
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
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
                                const Color.fromARGB(255, 65, 65, 100),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add_box_outlined,
                              color: Colors.white),
                          label: const Text('Add To Watchlist',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 65, 65, 100),
                          ),
                        ),
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
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(
                        5,
                        (index) => Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/images/bgimg.jpg',
                                  width: 130,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('Movie Name',
                                  style:
                                      TextStyle(color: Colors.white),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
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

  // Share helpers


  void _showShareOptions(BuildContext context) {
    final movie = _movieDetails;
    if (movie == null) return;
    final shareUrl = '$baseUrl/GetvideoDetail/${movie.id}';
    final shareText =
        'Check out "${movie.moviename}" on Our Movie App!';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.messenger_outline,
                color: Colors.white),
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
            leading: const Icon(Icons.link, color: Colors.white),
            title: const Text('Copy link',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: shareUrl));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Link copied to clipboard')));
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _shareViaWhatsApp(
      String shareText, String shareUrl) async {
    final uri = Uri.parse(
        'whatsapp://send?text=${Uri.encodeComponent('$shareText $shareUrl')}');
    try {
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri);
      } else {
        throw 'WhatsApp not installed';
      }
    } catch (_) {
      await Clipboard.setData(
          ClipboardData(text: '$shareText $shareUrl'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Couldn't open WhatsApp. Link copied to clipboard.")));
      }
    }
  }

  Future<void> _launchUrlWithFallback(
      String url, String fallbackUrl) async {
    try {
      if (!await url_launcher.launchUrl(Uri.parse(url))) {
        if (!await url_launcher.launchUrl(Uri.parse(fallbackUrl))) {
          throw 'Could not launch';
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Failed to open app. Please try another sharing method.')));
      }
    }
  }
}
