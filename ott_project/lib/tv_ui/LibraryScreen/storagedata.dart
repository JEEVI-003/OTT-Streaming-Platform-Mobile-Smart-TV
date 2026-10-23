import 'dart:async';

class LikedSongsData {
  static final LikedSongsData _instance = LikedSongsData._internal();
  factory LikedSongsData() => _instance;
  static LikedSongsData get instance => _instance;

  LikedSongsData._internal();

  int _totalLikedSongs = 0;
  final StreamController<int> _likedSongsController = StreamController<int>.broadcast();

  Stream<int> get likedSongsStream => _likedSongsController.stream;
  int get totalLikedSongs => _totalLikedSongs;

  void updateLikedSongs(int count) {
    _totalLikedSongs = count;
    _likedSongsController.add(count);
  }
}


class WatchLaterData {
  static final WatchLaterData _instance = WatchLaterData._internal();
  factory WatchLaterData() => _instance;
  static WatchLaterData get instance => _instance;

  WatchLaterData._internal();

  int _totalWatchlistMovies = 0;
  final StreamController<int> _watchlistController = StreamController<int>.broadcast();

  Stream<int> get watchlistStream => _watchlistController.stream;
  int get totalWatchlistMovies => _totalWatchlistMovies;

  void updateWatchlistMovies(int count) {
    _totalWatchlistMovies = count;
    _watchlistController.add(count);
  }
}



class PlaylistData {
  static final PlaylistData _instance = PlaylistData._internal();
  factory PlaylistData() => _instance;
  static PlaylistData get instance => _instance;

  PlaylistData._internal();

  int _totalPlaylists = 0;
  final StreamController<int> _playlistController = StreamController<int>.broadcast();

  Stream<int> get playlistStream => _playlistController.stream;
  int get totalPlaylists => _totalPlaylists;

  void updatePlaylists(int count) {
    _totalPlaylists = count;
    print("Updating playlist count: $count");

    _playlistController.add(count);
  }
}
