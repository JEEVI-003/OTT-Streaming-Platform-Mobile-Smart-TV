import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ott_project/components/library/audio_playlist.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/components/music_folder/audio_provider.dart' as ap;
import 'package:ott_project/service/audio_api_service.dart';
import 'package:ott_project/service/playlist_service.dart';
import 'package:ott_project/service/service.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/FocusManager/musicplayer_focusmanager.dart';
import 'package:ott_project/tv_ui/LibraryScreen/storagedata.dart';
import 'package:ott_project/tv_ui/components/tvlayout.dart';
import 'package:ott_project/tv_ui/music/playlistTvwidget.dart';

class TVMusicPlayerPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final List<AudioDescription> audioDescriptions;
  final int initialIndex;

  const TVMusicPlayerPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.audioDescriptions,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _TVMusicPlayerPageState createState() => _TVMusicPlayerPageState();
}

class _TVMusicPlayerPageState extends State<TVMusicPlayerPage> {
  late final AudioPlayer _audioPlayer;
  late final AudioApiService _audioApiService;
  late final MusicPlayerFocusManager _focusManager;
  final PlaylistService _playlistService = PlaylistService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  int _selectedSongIndex = 0;
  String? _audioUrl;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  bool _isShuffleOn = false;
  ap.RepeatMode _repeatMode = ap.RepeatMode.off;
  bool _isLiked = false;
  int? _currentUserId;
  List<String> _likedSongIds = [];
  List<AudioPlaylist> _audioPlaylists = [];
  int _selectedIndex = FocusManagerService.selectedSidebarIndex;

  // FIX: Dedicated keyboard focus node for this page.
  // Same rationale as movieplayertv.dart — must NOT share with the global
  // node so TVMainPage's listener is suspended while we are on top.
  final FocusNode _playerKeyboardFocusNode =
      FocusNode(debugLabel: 'musicPlayerKeyboard');

  @override
  void initState() {
    super.initState();
    FocusManagerService.currentPage = 3;
    _initializeServices();
    _setupAudioPlayer();
    _loadInitialData();

    // Request focus on our private node after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playerKeyboardFocusNode.requestFocus();
    });
  }

  void _initializeServices() {
    _audioPlayer = AudioPlayer();
    _audioApiService = AudioApiService();
    _focusManager = MusicPlayerFocusManager(
      onLikeSelect: _toggleLike,
      onPlayButtonSelect: _togglePlayPause,
      onPlaylistSelect: _showCreatePlaylistOption,
      onNextSongSelect: _playNextSong,
      onPreviousSongSelect: _playPreviousSong,
      onBack: _handleBack,
      onRepeatSelect: _toggleRepeat,
      onShuffleSelect: _toggleShuffle,
      totalSongs: widget.audioDescriptions.length,
      onMusicListSelect: _playSong,
    );

    // FIX: Wire focus-change notifications so D-pad moves trigger a rebuild.
    // Without this, updateFocusState() mutates boolean flags but nothing
    // calls setState() → the focus highlight never moves visually.
    _focusManager.onStateChanged = () {
      if (mounted) setState(() {});
    };

    FocusManagerService.musicPlayerFocusManager = _focusManager;
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _currentPosition = position);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _totalDuration = duration);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (_repeatMode == ap.RepeatMode.all) {
        Future.delayed(
            const Duration(milliseconds: 500),
            () => _playSong(_selectedSongIndex));
      } else {
        _playNextSong();
      }
    });
  }

  Future<void> _loadInitialData() async {
    await _getCurrentUserId();
    await _loadLikedStatus();
    await _fetchUserPlaylists();
    _selectedSongIndex = widget.initialIndex;
    _playSong(_selectedSongIndex);
  }

  Future<void> _getCurrentUserId() async {
    _currentUserId = await Service().getLoggedInUserId();
  }

  Future<void> _loadLikedStatus() async {
    if (_currentUserId == null) return;
    try {
      final likedSongs =
          await _audioApiService.getLikedSongs(_currentUserId!);
      if (mounted) {
        setState(() {
          _likedSongIds = likedSongs.map((id) => id.toString()).toList();
          _isLiked = _likedSongIds.contains(
              widget.audioDescriptions[_selectedSongIndex].id.toString());
        });
      }
    } catch (e) {
      debugPrint('Error loading liked status: $e');
    }
  }

  Future<void> _fetchUserPlaylists() async {
    try {
      final userIdStr = await _secureStorage.read(key: 'userId');
      if (userIdStr == null) return;
      final userId = int.parse(userIdStr);
      final playlists = await _playlistService.getPlaylistsByUserId(userId);
      if (mounted) setState(() => _audioPlaylists = playlists);
    } catch (e) {
      debugPrint('Failed to fetch playlists: $e');
    }
  }

  void _playSong(int index) async {
    if (!mounted || index < 0 || index >= widget.audioDescriptions.length)
      return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.release();
      final song = widget.audioDescriptions[index];
      final url =
          await _audioApiService.fetchAudioStreamUrl(song.audioFileName!);
      if (url == null) return;
      await _audioPlayer.play(UrlSource(url));
      await _audioPlayer.resume();
      if (mounted) {
        setState(() {
          _selectedSongIndex = index;
          _audioUrl = url;
          _isPlaying = true;
          _isLiked = _likedSongIds.contains(song.id.toString());
        });
      }
    } catch (e) {
      debugPrint('Error playing song: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error playing song')),
        );
      }
    }
  }

  void _playNextSong() {
    if (_selectedSongIndex < widget.audioDescriptions.length - 1) {
      _playSong(_selectedSongIndex + 1);
    } else {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  void _playPreviousSong() {
    if (_selectedSongIndex > 0) _playSong(_selectedSongIndex - 1);
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _seekTo(Duration position) {
    _audioPlayer.seek(position);
    setState(() => _currentPosition = position);
  }

  Future<void> _toggleLike() async {
    if (_currentUserId == null) {
      _showLoginAlert();
      return;
    }
    final currentSongId =
        widget.audioDescriptions[_selectedSongIndex].id;
    bool success = false;
    if (_isLiked) {
      success =
          await _audioApiService.unlikeAudio(currentSongId, _currentUserId!);
    } else {
      success =
          await _audioApiService.likeAudio(currentSongId, _currentUserId!);
    }
    if (success && mounted) {
      setState(() {
        _isLiked = !_isLiked;
        if (_isLiked) {
          _likedSongIds.add(currentSongId.toString());
        } else {
          _likedSongIds.remove(currentSongId.toString());
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              _isLiked ? 'Song added to likes' : 'Song removed from likes')));
    }
  }

  void _toggleShuffle() {
    setState(() => _isShuffleOn = !_isShuffleOn);
  }

  void _toggleRepeat() {
    setState(() {
      _repeatMode =
          _repeatMode == ap.RepeatMode.off ? ap.RepeatMode.all : ap.RepeatMode.off;
    });
  }

  // FIX: _handleBack now schedules re-focus on the global node so the main
  // page regains keyboard control immediately after we pop.
  void _handleBack() {
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _onSidebarSelected(int index) {
    FocusManagerService.selectedSidebarIndex = index;
    FocusManagerService.focusedSidebarIndex = index;
    FocusManagerService.currentPage = index;
    FocusManagerService.setZone(TVFocusZone.sidebar);
    Navigator.pop(context);
  }

  void _showCreatePlaylistOption() {
    if (_currentUserId == null) {
      _showLoginAlert();
      return;
    }
    final currentSongId =
        widget.audioDescriptions[_selectedSongIndex].id;
    showDialog(
      context: context,
      builder: (context) {
        return PlaylistOptionsPopup(
          currentSongId: currentSongId,
          currentUserId: _currentUserId,
          playlistService: _playlistService,
          focusManager: _focusManager,
          showCreateDialog: () => _showCreatePlaylistDialog(context),
          onClose: () => _focusManager.playlistFocusNode.unfocus(),
        );
      },
    );
  }

  void _showLoginAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please log in to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final currentSongId =
        widget.audioDescriptions[_selectedSongIndex].id;

    _focusManager.openDialog();
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CreatePlaylistDialog(
          titleController: titleController,
          descController: descController,
          onCreate: () async {
            await _playlistService.createPlayListWithAudioId(
              description: descController.text,
              userId: _currentUserId!,
              title: titleController.text,
              audioId: currentSongId,
            );
            await _fetchUserPlaylists();
            final playlists =
                await _playlistService.getPlaylistsByUserId(_currentUserId!);
            PlaylistData.instance.updatePlaylists(playlists.length);
            Navigator.pop(context);
            _focusManager.closeDialog();
            _focusManager.updateFocusState(isPlaylistButton: true);
            _playerKeyboardFocusNode.requestFocus();
          },
          onCancel: () {
            Navigator.pop(context);
            _focusManager.closeDialog();
            _focusManager.updateFocusState(isPlaylistButton: true);
            _playerKeyboardFocusNode.requestFocus();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();

    // FIX: Only dispose the focus manager's internal nodes here.
    // Do NOT dispose FocusManagerService.musicPlayerFocusManager's globalFocusNode
    // via the service reference — it may have already been replaced by another page.
    _focusManager.globalFocusNode.dispose();
    _focusManager.playlistFocusNode.dispose();
    FocusManagerService.musicPlayerFocusManager = null;

    _playerKeyboardFocusNode.dispose();

    // FIX: Re-hand keyboard focus back to the main page so TV navigation
    // resumes the frame after this page is popped.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManagerService.globalFocusNode.requestFocus();
    });

    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final selectedSong = widget.audioDescriptions[_selectedSongIndex];
    final screenSize = MediaQuery.of(context).size;

    // FIX: Use PopScope to intercept system/hardware back key and restore
    // focus on the main page properly.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: TVLayout(
        onSidebarSelected: _onSidebarSelected,
        selectedIndex: _selectedIndex,
        // FIX: KeyboardListener uses _playerKeyboardFocusNode (not the global
        // node) so this page exclusively handles keys while on top.
        child: KeyboardListener(
          focusNode: _playerKeyboardFocusNode,
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent) {
              // Hardware back key / Escape always navigates back
              if (event.logicalKey == LogicalKeyboardKey.escape ||
                  event.logicalKey == LogicalKeyboardKey.goBack ||
                  event.logicalKey == LogicalKeyboardKey.browserBack) {
                _handleBack();
                return;
              }
            }
            _focusManager.handleKeyEvent(event);
          },
          autofocus: true,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _buildSongInfoSection(selectedSong, screenSize),
                    _buildSongListSection(screenSize),
                  ],
                ),
              ),
              _buildPlayerControls(selectedSong, screenSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfoSection(AudioDescription song, Size screenSize) {
    return Expanded(
      flex: 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.categoryName,
            style: TextStyle(
              fontSize: screenSize.width * 0.035,
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            height: screenSize.width * 0.2,
            width: screenSize.width * 0.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: song.thumbnail != null
                  ? DecorationImage(
                      image: MemoryImage(song.thumbnail!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.grey[800],
            ),
            child: song.thumbnail == null
                ? const Center(
                    child:
                        Icon(Icons.image, color: Colors.white54, size: 50),
                  )
                : null,
          ),
          SizedBox(height: screenSize.height * 0.015),
          Text(
            song.audioTitle,
            style: TextStyle(
              fontSize: screenSize.width * 0.02,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "(${song.movieName})",
            style: TextStyle(
              fontSize: screenSize.width * 0.02,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenSize.height * 0.015),
          _buildActionButtons(screenSize),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Size screenSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _toggleLike,
          icon: Icon(
            _isLiked
                ? Icons.thumb_up_alt_rounded
                : Icons.thumb_up_alt_outlined,
            color: _isLiked ? Colors.red : Colors.white,
          ),
          label: const Text("Like",
              style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _focusManager.isLikeButtonFocused
                ? const Color.fromARGB(255, 143, 228, 0)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.01,
              vertical: screenSize.height * 0.01,
            ),
            shadowColor: Colors.black26,
            elevation: 4,
          ),
        ),
        SizedBox(width: screenSize.width * 0.015),
        ElevatedButton.icon(
          onPressed: _showCreatePlaylistOption,
          icon: const Icon(Icons.add_circle, color: Colors.white),
          label: const Text("Play list",
              style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _focusManager.isaddPlaylistButtonFocused
                ? const Color.fromARGB(255, 143, 228, 0)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.02,
              vertical: screenSize.height * 0.01,
            ),
            shadowColor: Colors.black26,
            elevation: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildSongListSection(Size screenSize) {
    return Expanded(
      flex: 5,
      child: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: ListView.builder(
          itemCount: widget.audioDescriptions.length,
          itemBuilder: (context, index) {
            final song = widget.audioDescriptions[index];
            return GestureDetector(
              onTap: () => _playSong(index),
              child: Container(
                margin: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.01),
                padding: EdgeInsets.symmetric(
                  vertical: screenSize.height * 0.015,
                  horizontal: screenSize.width * 0.02,
                ),
                decoration: BoxDecoration(
                  color: _focusManager.isMusicListFocused &&
                          _focusManager.selectedMusicIndex == index
                      ? const Color.fromARGB(115, 255, 255, 255)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${index + 1}. ${song.audioTitle}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenSize.width * 0.018,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.005),
                        Text(
                          "${song.audioTitle} - (${song.movieName})",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: screenSize.width * 0.018,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      song.audioDuration!,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: screenSize.width * 0.016,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerControls(AudioDescription song, Size screenSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.01,
        horizontal: screenSize.width * 0.02,
      ),
      color: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          SizedBox(
            height: screenSize.height * 0.02,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: screenSize.height * 0.005,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: screenSize.width * 0.008,
                ),
              ),
              child: Slider(
                activeColor: _focusManager.isSliderFocused
                    ? const Color.fromARGB(255, 143, 228, 0)
                    : const Color.fromARGB(255, 255, 2, 2),
                inactiveColor: Colors.grey,
                value: _currentPosition.inSeconds
                    .toDouble()
                    .clamp(
                      0,
                      _totalDuration.inSeconds.toDouble() > 0
                          ? _totalDuration.inSeconds.toDouble()
                          : 1,
                    ),
                min: 0,
                max: _totalDuration.inSeconds > 0
                    ? _totalDuration.inSeconds.toDouble()
                    : 1,
                onChanged: (value) =>
                    _seekTo(Duration(seconds: value.toInt())),
              ),
            ),
          ),
          _buildControlButtons(song, screenSize),
        ],
      ),
    );
  }

  Widget _buildControlButtons(AudioDescription song, Size screenSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: screenSize.width * 0.025,
              backgroundImage: song.thumbnail != null
                  ? MemoryImage(song.thumbnail!)
                  : null,
            ),
            SizedBox(width: screenSize.width * 0.01),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.audioTitle,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.018,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${widget.categoryName} - ${song.movieName}',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.016,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildControlButton(
                  icon: _isShuffleOn
                      ? Icons.shuffle_on
                      : Icons.shuffle,
                  size: screenSize.width * 0.03,
                  color: _focusManager.isShuffleFocused
                      ? const Color.fromARGB(255, 143, 228, 0)
                      : (_isShuffleOn ? Colors.blue : Colors.white),
                  onPressed: _toggleShuffle,
                ),
                _buildControlButton(
                  icon: Icons.skip_previous,
                  size: screenSize.width * 0.03,
                  color: _focusManager.isPreviousSongFocused
                      ? const Color.fromARGB(255, 143, 228, 0)
                      : Colors.white,
                  onPressed:
                      _selectedSongIndex > 0 ? _playPreviousSong : null,
                ),
                _buildControlButton(
                  icon: _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: screenSize.width * 0.05,
                  color: _focusManager.isPlayButtonFocused
                      ? const Color.fromARGB(255, 143, 228, 0)
                      : Colors.white,
                  onPressed: _togglePlayPause,
                ),
                _buildControlButton(
                  icon: Icons.skip_next,
                  size: screenSize.width * 0.03,
                  color: _focusManager.isNextSongFocused
                      ? const Color.fromARGB(255, 143, 228, 0)
                      : Colors.white,
                  onPressed:
                      _selectedSongIndex < widget.audioDescriptions.length - 1
                          ? _playNextSong
                          : null,
                ),
                _buildControlButton(
                  icon: _repeatMode == ap.RepeatMode.off
                      ? Icons.repeat
                      : Icons.repeat_on,
                  size: screenSize.width * 0.03,
                  color: _focusManager.isRepeatFocus
                      ? const Color.fromARGB(255, 143, 228, 0)
                      : (_repeatMode == ap.RepeatMode.off
                          ? Colors.white
                          : Colors.blue),
                  onPressed: _toggleRepeat,
                ),
              ],
            ),
          ),
        ),
        Text(
          '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
          style: TextStyle(
            color: Colors.grey,
            fontSize: screenSize.width * 0.015,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: size, color: color),
      onPressed: onPressed,
    );
  }
}

// ── CreatePlaylistDialog ──────────────────────────────────────────────────────

class CreatePlaylistDialog extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final VoidCallback onCreate;
  final VoidCallback onCancel;

  const CreatePlaylistDialog({
    Key? key,
    required this.titleController,
    required this.descController,
    required this.onCreate,
    required this.onCancel,
  }) : super(key: key);

  @override
  _CreatePlaylistDialogState createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  int _currentFocusIndex = 0;
  late final FocusNode _titleFocusNode;
  late final FocusNode _descFocusNode;
  late final FocusNode _createFocusNode;
  late final FocusNode _cancelFocusNode;
  // FIX: single keyboard listener node for the dialog
  late final FocusNode _keyboardFocusNode;
  String? _titleErrorText;

  @override
  void initState() {
    super.initState();
    _titleFocusNode = FocusNode();
    _descFocusNode = FocusNode();
    _createFocusNode = FocusNode();
    _cancelFocusNode = FocusNode();
    _keyboardFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
      _titleFocusNode.requestFocus();
      setState(() => _currentFocusIndex = 0);
    });
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descFocusNode.dispose();
    _createFocusNode.dispose();
    _cancelFocusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _updateFocus(int index) {
    setState(() => _currentFocusIndex = index);
    switch (index) {
      case 0:
        _titleFocusNode.requestFocus();
        break;
      case 1:
        _descFocusNode.requestFocus();
        break;
      case 2:
        _createFocusNode.requestFocus();
        break;
      case 3:
        _cancelFocusNode.requestFocus();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is! KeyDownEvent) return;
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          if (_currentFocusIndex == 0) _updateFocus(1);
          else if (_currentFocusIndex == 1) _updateFocus(2);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          if (_currentFocusIndex == 1) _updateFocus(0);
          else if (_currentFocusIndex == 2 || _currentFocusIndex == 3)
            _updateFocus(1);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          if (_currentFocusIndex == 3) _updateFocus(2);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          if (_currentFocusIndex == 2) _updateFocus(3);
        } else if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.select) {
          if (_currentFocusIndex == 2) {
            if (widget.titleController.text.trim().isEmpty) {
              setState(() => _titleErrorText = 'Title cannot be empty');
              _updateFocus(0);
            } else {
              widget.onCreate();
            }
          } else if (_currentFocusIndex == 3) {
            widget.onCancel();
          }
        }
      },
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            width: screenSize.width * 0.5,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF070708), Color(0xFF1D1B53)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create New Playlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  focusNode: _titleFocusNode,
                  controller: widget.titleController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Playlist Name',
                    errorText: _titleErrorText,
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 56, 241, 105)),
                    ),
                  ),
                  onChanged: (_) {
                    if (_titleErrorText != null) {
                      setState(() => _titleErrorText = null);
                    }
                  },
                ),
                const SizedBox(height: 15),
                TextField(
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => _updateFocus(2),
                  focusNode: _descFocusNode,
                  controller: widget.descController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 56, 241, 105)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      focusNode: _createFocusNode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentFocusIndex == 2
                            ? Colors.green
                            : const Color.fromARGB(255, 193, 39, 45),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (widget.titleController.text.trim().isEmpty) {
                          setState(
                              () => _titleErrorText = 'Title cannot be empty');
                          _updateFocus(0);
                        } else {
                          widget.onCreate();
                        }
                      },
                      child: const Text('Create',
                          style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      focusNode: _cancelFocusNode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentFocusIndex == 3
                            ? Colors.green
                            : Colors.grey[800],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: widget.onCancel,
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}