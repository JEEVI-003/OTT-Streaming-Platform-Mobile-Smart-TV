import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ott_project/components/library/audio_playlist.dart';
import 'package:ott_project/components/music_folder/audio.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/components/music_folder/music.dart';
import 'package:ott_project/components/music_folder/playlist.dart';
import 'package:ott_project/components/music_folder/recently_played.dart';
import 'package:ott_project/components/music_folder/recently_played_manager.dart';
import 'package:ott_project/service/audio_api_service.dart';
import 'package:ott_project/service/playlist_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../service/service.dart';
import '../library/likedSongsDTO.dart';

enum RepeatMode { off, all, one }

/// Which playlist flow is currently active.
/// Used by onPlayerComplete to route to the correct handler.
enum _ActiveFlow { audioDescription, music, legacyAudio, none }

class AudioProvider with ChangeNotifier {
  // ─────────────────────────────────────────────────────────────────────────
  // SINGLE AudioPlayer for the whole app.
  // Player pages must NOT create their own AudioPlayer instances — doing so
  // causes two simultaneous streams, leaked native resources, and setState()
  // calls on unmounted widgets that freeze the UI after navigation.
  // ─────────────────────────────────────────────────────────────────────────
  final AudioPlayer audioPlayer = AudioPlayer();

  bool isPlaying = false;
  String? audioUrl;
  int currentIndex = -1;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool _isShuffleOn = false;
  bool _isRepeatOn = false; // kept for legacy compat
  bool get isShuffleOn => _isShuffleOn;
  bool get isRepeatOn => _isRepeatOn;

  _ActiveFlow _activeFlow = _ActiveFlow.none;

  final RecentlyPlayedManager _recentlyPlayedManager = RecentlyPlayedManager();
  final RecentlyPlayed _recentlyPlayed = RecentlyPlayed();
  final _secureStorage = FlutterSecureStorage();
  final PlaylistService playlistService;

  // ─────────────────────────────────────────────────────────────────────────
  // FIX A — Central liked-songs set.
  //
  // Previously each player page held its own `bool isLiked` loaded
  // independently from the API, so they never stayed in sync with each other.
  // Now every screen reads provider.isLiked(id) through a Consumer<AudioProvider>
  // and the whole app shares one source of truth.
  // ─────────────────────────────────────────────────────────────────────────
  final Set<int> _likedAudioIds = {};

  bool isLiked(int audioId) => _likedAudioIds.contains(audioId);

  /// Call once after login / when a page that shows hearts opens.
  Future<void> loadLikedSongs(int userId) async {
    try {
      final ids = await AudioApiService().getLikedSongs(userId);
      _likedAudioIds
        ..clear()
        ..addAll(ids);
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider.loadLikedSongs error: $e');
    }
  }

  /// Optimistic like — flips the set immediately, rolls back on API failure.
  Future<bool> likeAudio(int audioId, int userId) async {
    _likedAudioIds.add(audioId);
    notifyListeners();
    try {
      final success = await AudioApiService().likeAudio(audioId, userId);
      if (!success) {
        _likedAudioIds.remove(audioId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _likedAudioIds.remove(audioId);
      notifyListeners();
      return false;
    }
  }

  /// Optimistic unlike — flips the set immediately, rolls back on API failure.
  Future<bool> unlikeAudio(int audioId, int userId) async {
    _likedAudioIds.remove(audioId);
    notifyListeners();
    try {
      final success = await AudioApiService().unlikeAudio(audioId, userId);
      if (!success) {
        _likedAudioIds.add(audioId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _likedAudioIds.add(audioId);
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AudioDescription flow  (SongPlayerPage + CurrentlyPlayingBar)
  // ─────────────────────────────────────────────────────────────────────────
  AudioDescription? _audioDescriptioncurrently;
  AudioDescription? get audioDescriptioncurrently => _audioDescriptioncurrently;
  List<AudioDescription> audio_playlist = [];
  List<AudioDescription> originalaudioPlaylist = [];
  List<AudioPlaylist> audioPlaylists = [];
  List<AudioPlaylist> get aplaylists => audioPlaylists;

  // ─────────────────────────────────────────────────────────────────────────
  // Music flow  (Music model)
  // ─────────────────────────────────────────────────────────────────────────
  Music? _musiccurrentlyPlaying;
  Music? get musiccurrentlyPlaying => _musiccurrentlyPlaying;
  List<Music> music_playlist = [];
  List<Music> _originalmusicPlaylist = [];
  List<MusicPlaylist> musicplaylists = [];
  List<MusicPlaylist> get mplaylists => musicplaylists;

  // ─────────────────────────────────────────────────────────────────────────
  // Legacy Audio flow  (Audio model — kept for backward compatibility)
  // ─────────────────────────────────────────────────────────────────────────
  Audio? _currentlyPlaying;
  Audio? get currentlyPlaying => _currentlyPlaying;
  List<Audio> playList = [];
  List<Audio> _originalPlaylist = [];
  List<Playlist> _playlists = [];
  List<Playlist> get playlists => _playlists;

  // ─────────────────────────────────────────────────────────────────────────
  // Repeat modes — separate per flow
  // ─────────────────────────────────────────────────────────────────────────
  RepeatMode _repeatModeSong = RepeatMode.off;
  RepeatMode get repeatModeSong => _repeatModeSong;

  RepeatMode _repeatMode = RepeatMode.off;
  RepeatMode get repeatMode => _repeatMode;

  Map<String, Uint8List> _decodedImages = {};

  // ─────────────────────────────────────────────────────────────────────────
  // Constructor
  // ─────────────────────────────────────────────────────────────────────────
  AudioProvider(this.playlistService) {
    loadMusicPlaylists();

    audioPlayer.onDurationChanged.listen((d) {
      duration = d;
      notifyListeners();
    });

    audioPlayer.onPositionChanged.listen((p) {
      position = p;
      notifyListeners();
    });

    // FIX — Route completion to the correct flow.
    // The original always called handleAudioCompletion() (AudioDescription flow)
    // even when Music or legacy Audio was active, causing RangeError crashes
    // from accessing the wrong list, which froze the UI.
    audioPlayer.onPlayerComplete.listen((_) {
      isPlaying = false;
      notifyListeners();
      switch (_activeFlow) {
        case _ActiveFlow.audioDescription:
          _onAudioDescriptionComplete();
          break;
        case _ActiveFlow.music:
          _onMusicComplete();
          break;
        case _ActiveFlow.legacyAudio:
          _onLegacyAudioComplete();
          break;
        case _ActiveFlow.none:
          break;
      }
    });
  }

  // =========================================================================
  // AudioDescription flow
  // =========================================================================

  Future<void> setCurrentlyPlayingSong(
      AudioDescription audioDescription,
      List<AudioDescription> newPlaylist) async {
    if (newPlaylist.isEmpty) {
      debugPrint('AudioProvider: playlist is empty');
      return;
    }
    _activeFlow = _ActiveFlow.audioDescription;
    _audioDescriptioncurrently = audioDescription;
    audio_playlist = List.from(newPlaylist);
    currentIndex =
        audio_playlist.indexWhere((a) => a.id == audioDescription.id);
    if (currentIndex == -1) {
      debugPrint('AudioProvider: audio not found in playlist');
      return;
    }
    await _saveCurrentlyPlayingSong();
    notifyListeners();
    await playSong();
  }

  void updateCurrentlyPlayingSong(AudioDescription a) {
    _audioDescriptioncurrently = a;
    notifyListeners();
  }

  Future<void> playSong() async {
    if (currentIndex < 0 || currentIndex >= audio_playlist.length) {
      debugPrint('AudioProvider.playSong: invalid index $currentIndex');
      return;
    }
    try {
      final current = audio_playlist[currentIndex];
      audioUrl =
          await AudioApiService().fetchAudioStreamUrl(current.audioFileName!);
      await audioPlayer.stop();
      await audioPlayer.play(UrlSource(audioUrl!));
      isPlaying = true;
      updateCurrentlyPlayingSong(current);
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider.playSong error: $e');
    }
  }

  // Also kept as prepareSong() alias so existing call sites still compile.
  Future<void> prepareSong() => playSong();

  void playPauseSong() async {
    try {
      if (isPlaying) {
        await audioPlayer.pause();
        isPlaying = false;
      } else {
        if (audioUrl == null && _audioDescriptioncurrently != null) {
          await playSong();
          return;
        }
        await audioPlayer.resume();
        isPlaying = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider.playPauseSong error: $e');
    }
  }

  Future<void> playNextSong() async {
    if (_repeatModeSong == RepeatMode.one) {
      await playSong();
      return;
    }
    if (currentIndex < audio_playlist.length - 1) {
      currentIndex++;
    } else if (_repeatModeSong == RepeatMode.all || _isShuffleOn) {
      currentIndex = 0;
    } else {
      debugPrint('AudioProvider: end of playlist');
      return;
    }
    updateCurrentlyPlayingSong(audio_playlist[currentIndex]);
    await playSong();
    // FIX J — removed _recentlyPlayedManager.addRecentlyPlayed(playList[currentIndex])
    // playList is the legacy Audio list; calling it here caused RangeError crashes
    // when playList was empty, which froze the UI after returning from the player.
  }

  Future<void> playPreviousSong() async {
    if (_repeatModeSong == RepeatMode.one) {
      await playSong();
      return;
    }
    if (currentIndex > 0) {
      currentIndex--;
    } else if (_repeatModeSong == RepeatMode.all || _isShuffleOn) {
      currentIndex = audio_playlist.length - 1;
    } else {
      debugPrint('AudioProvider: beginning of playlist');
      return;
    }
    updateCurrentlyPlayingSong(audio_playlist[currentIndex]);
    await playSong();
    // FIX J — same as playNextSong above
  }

  void _onAudioDescriptionComplete() async {
    if (_repeatModeSong == RepeatMode.one) {
      await playSong();
    } else if (_repeatModeSong == RepeatMode.all ||
        _isShuffleOn ||
        currentIndex < audio_playlist.length - 1) {
      await playNextSong();
    } else {
      isPlaying = false;
      notifyListeners();
    }
  }

  // Public alias for any existing call sites.
  void handleAudioCompletion() => _onAudioDescriptionComplete();

  // FIX — Use .id comparison, not object identity.
  // indexOf() compares references, which always returns -1 after a shuffle
  // creates a new list (every element is a different reference to the same object).
  void toggleShuffleSong() {
    _isShuffleOn = !_isShuffleOn;
    if (_isShuffleOn) {
      originalaudioPlaylist = List.from(audio_playlist);
      audio_playlist.shuffle();
      currentIndex = audio_playlist
          .indexWhere((a) => a.id == _audioDescriptioncurrently?.id);
    } else {
      audio_playlist = List.from(originalaudioPlaylist);
      currentIndex = audio_playlist
          .indexWhere((a) => a.id == _audioDescriptioncurrently?.id);
    }
    notifyListeners();
  }

  void toggleRepeatSong() {
    switch (_repeatModeSong) {
      case RepeatMode.off:
        _repeatModeSong = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatModeSong = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatModeSong = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  Future<void> _saveCurrentlyPlayingSong() async {
    final prefs = await SharedPreferences.getInstance();
    if (_audioDescriptioncurrently != null) {
      prefs.setString('currentlyPlayingSong',
          jsonEncode(_audioDescriptioncurrently!.toJson()));
      prefs.setInt('currentIndex', currentIndex);
      prefs.setString('songPlayList',
          jsonEncode(audio_playlist.map((a) => a.toJson()).toList()));
    }
  }

  Future<void> loadCurrentlyPlayingSong() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('currentIndex');
    final audioJson = prefs.getString('currentlyPlayingSong');
    final playListJson = prefs.getString('songPlayList');

    if (audioJson != null) {
      _audioDescriptioncurrently =
          AudioDescription.fromJson(jsonDecode(audioJson));
      notifyListeners();
    }
    if (savedIndex != null) currentIndex = savedIndex;
    if (playListJson != null) {
      audio_playlist = (jsonDecode(playListJson) as List)
          .map((m) => AudioDescription.fromJson(m))
          .toList();
    }
    if (currentIndex < 0 || currentIndex >= audio_playlist.length) {
      debugPrint('AudioProvider.loadCurrentlyPlayingSong: invalid index');
      currentIndex = -1;
    }
    notifyListeners();
  }

  // =========================================================================
  // Music flow
  // =========================================================================

  Future<void> musicsetCurrentlyPlaying(
      Music music, List<Music> musicPlaylist) async {
    if (musicPlaylist.isEmpty) return;
    _activeFlow = _ActiveFlow.music;
    _musiccurrentlyPlaying = music;
    music_playlist = List.from(musicPlaylist);
    currentIndex = music_playlist.indexWhere((m) => m.id == music.id);
    await _saveMusicCurrentlyPlaying();
    notifyListeners();
    await playMusic();
  }

  Future<void> _saveMusicCurrentlyPlaying() async {
    final prefs = await SharedPreferences.getInstance();
    // FIX — original checked `_currentlyPlaying` (Audio model) instead of
    // `_musiccurrentlyPlaying` (Music model), so nothing was ever saved.
    if (_musiccurrentlyPlaying != null) {
      prefs.setString('musiccurrentlyPlaying',
          jsonEncode(_musiccurrentlyPlaying!.toJson()));
      prefs.setInt('currentIndex', currentIndex);
      prefs.setString('music_playList',
          jsonEncode(music_playlist.map((m) => m.toJson()).toList()));
    }
  }

  Future<void> prepareMusic() async {
    if (currentIndex < 0 || currentIndex >= music_playlist.length) return;
    try {
      audioUrl = await AudioApiService()
          .fetchAudioStreamUrl(music_playlist[currentIndex].fileName);
      if (audioUrl != null) {
        await audioPlayer.setSource(UrlSource(audioUrl!));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider.prepareMusic error: $e');
    }
  }

  Future<void> playMusic() async {
    if (currentIndex < 0 || currentIndex >= music_playlist.length) return;
    try {
      final current = music_playlist[currentIndex];
      audioUrl =
          await AudioApiService().fetchAudioStreamUrl(current.fileName);
      await audioPlayer.stop();
      await audioPlayer.play(UrlSource(audioUrl!));
      isPlaying = true;
      _musiccurrentlyPlaying = current;
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider.playMusic error: $e');
    }
  }

  void playPauseMusic() async {
    try {
      if (isPlaying) {
        await audioPlayer.pause();
        isPlaying = false;
      } else {
        if (audioUrl == null && _musiccurrentlyPlaying != null) {
          await prepareMusic();
        }
        await audioPlayer.resume();
        isPlaying = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider.playPauseMusic error: $e');
    }
  }

  Future<void> playNextMusic() async {
    if (_repeatMode == RepeatMode.one) {
      await playMusic();
      return;
    }
    if (currentIndex < music_playlist.length - 1) {
      currentIndex++;
    } else if (_repeatMode == RepeatMode.all || _isShuffleOn) {
      currentIndex = 0;
    } else {
      return;
    }
    _musiccurrentlyPlaying = music_playlist[currentIndex];
    notifyListeners();
    await playMusic();
    _recentlyPlayed.addRecentlyPlayed(music_playlist[currentIndex]);
  }

  Future<void> playPreviousMusic() async {
    if (_repeatMode == RepeatMode.one) {
      await playMusic();
      return;
    }
    if (currentIndex > 0) {
      currentIndex--;
    } else if (_repeatMode == RepeatMode.all || _isShuffleOn) {
      currentIndex = music_playlist.length - 1;
    } else {
      return;
    }
    _musiccurrentlyPlaying = music_playlist[currentIndex];
    notifyListeners();
    await playMusic();
    _recentlyPlayed.addRecentlyPlayed(music_playlist[currentIndex]);
  }

  void _onMusicComplete() async {
    if (_repeatMode == RepeatMode.one) {
      await playMusic();
    } else if (_repeatMode == RepeatMode.all ||
        _isShuffleOn ||
        // FIX — was `playList.length` (legacy Audio list) instead of music_playlist.length
        currentIndex < music_playlist.length - 1) {
      await playNextMusic();
    } else {
      isPlaying = false;
      notifyListeners();
    }
  }

  // Public alias
  void handleMusicCompletion() => _onMusicComplete();

  // FIX — was shuffling `playList` (legacy Audio) instead of `music_playlist`
  void toggleShuffleMusic() {
    _isShuffleOn = !_isShuffleOn;
    if (_isShuffleOn) {
      _originalmusicPlaylist = List.from(music_playlist);
      music_playlist.shuffle();
      currentIndex = music_playlist
          .indexWhere((m) => m.id == _musiccurrentlyPlaying?.id);
    } else {
      music_playlist = List.from(_originalmusicPlaylist);
      currentIndex = music_playlist
          .indexWhere((m) => m.id == _musiccurrentlyPlaying?.id);
    }
    notifyListeners();
  }

  void toggleRepeatMusic() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  Future<void> musicloadCurrentlyPlaying() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('currentIndex');
    final audioJson = prefs.getString('musiccurrentlyPlaying');
    final playListJson = prefs.getString('music_playList');

    if (audioJson != null) {
      _musiccurrentlyPlaying =
          Music.fromJson(jsonDecode(audioJson) as Map<String, dynamic>);
      notifyListeners();
    }
    if (savedIndex != null) currentIndex = savedIndex;
    if (playListJson != null) {
      music_playlist = (jsonDecode(playListJson) as List)
          .map((m) => Music.fromJson(m))
          .toList();
    }
    if (currentIndex < 0 || currentIndex >= music_playlist.length) {
      currentIndex = -1;
    }
    notifyListeners();
  }

  // =========================================================================
  // Legacy Audio flow
  // =========================================================================

  Future<void> prepareAudio() async {
    if (currentIndex < 0 || currentIndex >= playList.length) return;
    try {
      final current = playList[currentIndex];
      audioUrl =
          await AudioApiService().fetchAudioStreamUrl(current.fileName);
      if (audioUrl != null) {
        await audioPlayer.setSource(UrlSource(audioUrl!));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AudioProvider.prepareAudio error: $e');
    }
  }

  Future<void> setCurrentlyPlaying(
      Audio audio, List<Audio> newPlaylist) async {
    if (newPlaylist.isEmpty) return;
    _activeFlow = _ActiveFlow.legacyAudio;
    _currentlyPlaying = audio;
    playList = List.from(newPlaylist);
    currentIndex = playList.indexOf(audio);
    await _saveCurrentlyPlaying();
    notifyListeners();
    await prepareAudio();
  }

  Future<void> playAudio() async {
    if (currentIndex < 0 || currentIndex >= playList.length) return;
    try {
      final current = playList[currentIndex];
      audioUrl =
          await AudioApiService().fetchAudioStreamUrl(current.fileName);
      await audioPlayer.stop();
      await audioPlayer.play(UrlSource(audioUrl!));
      isPlaying = true;
      _updateCurrentlyPlaying(current);
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider.playAudio error: $e');
    }
  }

  void playPause() async {
    try {
      if (isPlaying) {
        await audioPlayer.pause();
        isPlaying = false;
      } else {
        if (audioUrl == null && _currentlyPlaying != null) {
          await prepareAudio();
        }
        await audioPlayer.resume();
        isPlaying = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider.playPause error: $e');
    }
  }

  Future<void> playNext() async {
    if (_repeatMode == RepeatMode.one) {
      await playAudio();
      return;
    }
    if (currentIndex < playList.length - 1) {
      currentIndex++;
    } else if (_repeatMode == RepeatMode.all || _isShuffleOn) {
      currentIndex = 0;
    } else {
      return;
    }
    _updateCurrentlyPlaying(playList[currentIndex]);
    notifyListeners();
    await playAudio();
    _recentlyPlayedManager.addRecentlyPlayed(playList[currentIndex]);
  }

  Future<void> playPrevious() async {
    if (_repeatMode == RepeatMode.one) {
      await playAudio();
      return;
    }
    if (currentIndex > 0) {
      currentIndex--;
    } else if (_repeatMode == RepeatMode.all || _isShuffleOn) {
      currentIndex = playList.length - 1;
    } else {
      return;
    }
    _updateCurrentlyPlaying(playList[currentIndex]);
    notifyListeners();
    await playAudio();
    _recentlyPlayedManager.addRecentlyPlayed(playList[currentIndex]);
  }

  void _onLegacyAudioComplete() async {
    if (_repeatMode == RepeatMode.one) {
      await playAudio();
    } else if (_repeatMode == RepeatMode.all ||
        _isShuffleOn ||
        currentIndex < playList.length - 1) {
      await playNext();
    } else {
      isPlaying = false;
      notifyListeners();
    }
  }

  // Public alias
  void handleSongCompletion() => _onLegacyAudioComplete();

  void toggleShuffle() {
    _isShuffleOn = !_isShuffleOn;
    if (_isShuffleOn) {
      _originalPlaylist = List.from(playList);
      playList.shuffle();
      currentIndex = playList.indexOf(_currentlyPlaying!);
    } else {
      playList = List.from(_originalPlaylist);
      currentIndex = playList.indexOf(_currentlyPlaying!);
    }
    notifyListeners();
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  void _updateCurrentlyPlaying(Audio audio) {
    _currentlyPlaying = audio;
    notifyListeners();
  }

  Future<void> _saveCurrentlyPlaying() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentlyPlaying != null) {
      prefs.setString(
          'currentlyPlaying', jsonEncode(_currentlyPlaying!.toJson()));
      prefs.setInt('currentIndex', currentIndex);
      prefs.setString(
          'playList', jsonEncode(playList.map((a) => a.toJson()).toList()));
    }
  }

  Future<void> loadCurrentlyPlaying() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('currentIndex');
    final audioJson = prefs.getString('currentlyPlaying');
    final playListJson = prefs.getString('playList');

    if (audioJson != null) {
      _currentlyPlaying = Audio.fromJson(jsonDecode(audioJson));
      notifyListeners();
    }
    if (savedIndex != null) currentIndex = savedIndex;
    if (playListJson != null) {
      playList = (jsonDecode(playListJson) as List)
          .map((m) => Audio.fromJson(m))
          .toList();
    }
    if (currentIndex < 0 || currentIndex >= playList.length) {
      currentIndex = -1;
    }
    notifyListeners();
  }

  // =========================================================================
  // Shared
  // =========================================================================

  Future<void> seekTo(Duration pos) async {
    await audioPlayer.seek(pos);
    notifyListeners();
  }

  // =========================================================================
  // Playlist management — AudioPlaylist (server-backed)
  // =========================================================================

  Future<void> fetchUserPlaylists() async {
    try {
      String? userIDStr = await _secureStorage.read(key: 'userId');
      if (userIDStr == null) return;
      final userId = int.parse(userIDStr);
      audioPlaylists = await playlistService.getPlaylistsByUserId(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider.fetchUserPlaylists error: $e');
    }
  }

  Future<void> fetchPlaylists() async {
    try {
      final userId = await Service().getLoggedInUserId();
      if (userId != null) {
        audioPlaylists =
            await PlaylistService().getPlaylistsByUserId(userId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AudioProvider.fetchPlaylists error: $e');
    }
  }

  Future<void> createPlayList(String title, String description) async {
    // Removed the invalid `if (playlistService == null)` check.
    // The field is non-nullable so the check was always false.
    try {
      String? userIDStr = await _secureStorage.read(key: 'userId');
      if (userIDStr == null) throw Exception('User ID not found.');
      final userId = int.parse(userIDStr);
      final pl = await playlistService.createPlayList(
          title: title, description: description, userId: userId);
      audioPlaylists.add(pl);
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider.createPlayList error: $e');
      rethrow;
    }
  }

  Future<void> createPlayListWithAudioId(
      String title, String description, int audioId) async {
    try {
      String? userIDStr = await _secureStorage.read(key: 'userId');
      if (userIDStr == null) throw Exception('User ID not found.');
      final userId = int.parse(userIDStr);
      final pl = await playlistService.createPlayListWithAudioId(
          title: title,
          description: description,
          userId: userId,
          audioId: audioId);
      audioPlaylists.add(pl);
      await fetchUserPlaylists();
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider.createPlayListWithAudioId error: $e');
      rethrow;
    }
  }

  Future<void> addAudiosToPlaylist(
      AudioPlaylist playlist, int audioId) async {
    try {
      playlist.audioIds.add(audioId);
      notifyListeners();
      await PlaylistService().addAudiosToPlaylist(playlist.id, audioId);
      await _saveaudiosPlaylists();
    } catch (e) {
      playlist.audioIds.remove(audioId);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadPlaylistsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('playlists') ?? [];
    if (list.isNotEmpty) {
      audioPlaylists =
          list.map((s) => AudioPlaylist.fromJson(jsonDecode(s))).toList();
      notifyListeners();
    }
  }

  Future<void> _saveaudiosPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('playlists',
        audioPlaylists.map((p) => jsonEncode(p.toJson())).toList());
  }

  // =========================================================================
  // Playlist management — legacy Playlist (Audio model)
  // =========================================================================

  Future<void> createPlaylistAudio(String title, String description) async {
    _playlists
        .add(Playlist(title: title, description: description, audios: []));
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> addAudioToPlaylist(Playlist playlist, Audio audio) async {
    playlist.audios.add(audio);
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> addAudioToLikedsong(Playlist playlist, Audio audio) async {
    playlist.audios.add(audio);
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> removeAudioFromPlayList(
      Playlist playlist, Audio audio) async {
    playlist.audios.remove(audio);
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    _playlists.remove(playlist);
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> _savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('playlists',
        _playlists.map((p) => jsonEncode(p.toJson())).toList());
  }

  Future<void> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('playlists');
    if (list != null) {
      _playlists =
          list.map((s) => Playlist.fromJson(jsonDecode(s))).toList();
      notifyListeners();
    }
  }

  // =========================================================================
  // MusicPlaylist (local, Music model)
  // =========================================================================

  Future<void> loadMusicPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('playlists');
    if (list != null) {
      musicplaylists =
          list.map((s) => MusicPlaylist.fromJson(jsonDecode(s))).toList();
      notifyListeners();
    }
  }

  Future<void> createmusicPlaylist(
      String title, String description) async {
    musicplaylists.add(
        MusicPlaylist(title: title, description: description, music: []));
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> addMusicToPlaylist(
      MusicPlaylist playlist, Music music) async {
    playlist.music.add(music);
    await _savemusicPlaylists();
    notifyListeners();
  }

  Future<void> addMusicToLikedsong(
      MusicPlaylist playlist, Music music) async {
    playlist.music.add(music);
    await _savemusicPlaylists();
    notifyListeners();
  }

  Future<void> _savemusicPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('playlists',
        musicplaylists.map((p) => jsonEncode(p.toJson())).toList());
  }

  // =========================================================================
  // Image decode cache
  // =========================================================================

  Uint8List getDecodedImage(String thumbnail) {
    if (!_decodedImages.containsKey(thumbnail)) {
      final compressed = base64.decode(thumbnail);
      _decodedImages[thumbnail] =
          Uint8List.fromList(ZLibDecoder().decodeBytes(compressed));
    }
    return _decodedImages[thumbnail]!;
  }

  // =========================================================================
  // Helpers
  // =========================================================================

  List<AudioDescription> convertPlaylistToAudioDescriptions(
      List<LikedsongsDTO> items) {
    return items
        .map((i) => AudioDescription(
              id: i.audioId,
              audioTitle: i.audioTitle,
              paid: false,
              audioFileName: _audioDescriptioncurrently?.audioFileName,
            ))
        .toList();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}