import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/components/music_folder/audio_provider.dart';
import 'package:ott_project/components/music_folder/song_player_page.dart';
import 'package:ott_project/components/notification/notification.dart';
import 'package:ott_project/components/video_folder/movie_player_page.dart';
import 'package:ott_project/components/video_folder/video_container.dart';
import 'package:ott_project/pages/app_icon.dart';
import 'package:ott_project/service/audio_service.dart';
import 'package:ott_project/service/icon_service.dart';
import 'package:ott_project/service/movie_service_page.dart';
import 'package:ott_project/service/notification_api_service.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TVAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  static Function(int)? onNavigation;

  const TVAppBar({super.key})
      : preferredSize = const Size.fromHeight(70);

  @override
  State<TVAppBar> createState() => _TVAppBarState();
}

class _TVAppBarState extends State<TVAppBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  List<dynamic> _filteredContent = [];
  List<AudioContainer> _audio = [];
  List<VideoContainer> _video = [];
  // Stored as raw JSON strings — decoded only when displaying
  List<String> _recentSearch = [];
  List<Notifications>? notifications;
  int unreadCount = 0;
  final storage = FlutterSecureStorage();
  String? token;
  AppIcon? iconData;
  Uint8List? cachedImageBytes;
  final FocusNode _searchFocusNode = FocusNode();

  // Overlay entry for the search results dropdown
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  List<VideoDescription> allMovies = [];
  List<AudioDescription> allSongs = [];

  @override
  void initState() {
    super.initState();
    TVAppBar.onNavigation = _handleNavigation;
    _loadToken();
    _loadIcon();
    _loadVideoAndAudioContainers();
    loadRecentSearch();
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ── Overlay helpers ────────────────────────────────────────────────────────

  void _showOverlay() {
    _removeOverlay();
    if (_filteredContent.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        width: MediaQuery.of(context).size.width * 0.55,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          // Offset below the AppBar title area
          offset: const Offset(0, 56),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withOpacity(0.97),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredContent.length,
                itemBuilder: (_, index) =>
                    _buildResultTile(_filteredContent[index]),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _refreshOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    } else if (_filteredContent.isNotEmpty && _showSearch) {
      _showOverlay();
    }
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadIcon() async {
    if (cachedImageBytes != null) return;
    try {
      final icon = await IconService.fetchIcon();
      if (mounted) {
        setState(() {
          iconData = icon;
          cachedImageBytes = icon.imageBytes;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading icon: $e');
    }
  }

  Future<void> _loadToken() async {
    try {
      token = await storage.read(key: 'token');
      if (token != null) {
        _loadNotifications();
        _loadUnreadCount();
      }
    } catch (e) {
      // ignore token read errors
    }
  }

  Future<void> _loadVideoAndAudioContainers() async {
    try {
      final videos = await MovieService.fetchVideoContainer();
      final audios = await AudioService.fetchAudioContainer();
      if (mounted) {
        setState(() {
          _video = videos;
          _audio = audios;
          allMovies = _video.expand((c) => c.videoDescriptions).toList();
          allSongs = _audio.expand((c) => c.audiolist).toList();
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading media containers: $e');
    }
  }

  Future<void> _loadNotifications() async {
    if (token == null || token!.isEmpty) {
      if (!mounted) return;
      setState(() => notifications = []);
      return;
    }
    final loaded = await NotificationApiService().fetchNotification(token);
    if (!mounted) return;
    setState(() => notifications = loaded);
  }

  Future<void> _loadUnreadCount() async {
    if (token == null || token!.isEmpty) {
      if (!mounted) return;
      setState(() => unreadCount = 0);
      return;
    }
    try {
      final count = await NotificationApiService().fetchUnreadCount(token);
      if (!mounted) return;
      setState(() => unreadCount = count);
    } catch (e) {
      if (!mounted) return;
      setState(() => unreadCount = 0);
    }
  }

  Future<void> _markAllAsRead() async {
    if (token == null || token!.isEmpty) return;
    try {
      final success = await NotificationApiService().markAllasRead(token);
      if (!mounted) return;
      setState(() => unreadCount = 0);
      if (success) _loadNotifications();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => unreadCount = 0);
    }
  }

  Future<void> _clearAllNotifications() async {
    if (token == null || token!.isEmpty) return;
    try {
      final success =
          await NotificationApiService().clearAllNotifications(token);
      if (!mounted) return;
      setState(() {
        notifications = [];
        unreadCount = 0;
      });
      if (success) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        notifications = [];
        unreadCount = 0;
      });
    }
  }

  // ── Search logic ───────────────────────────────────────────────────────────

  void _filterContent(String query) {
    if (!mounted) return;
    List<dynamic> results;
    if (query.isEmpty) {
      results = _recentSearch.map((raw) {
        try {
          return jsonDecode(raw) as Map<String, dynamic>;
        } catch (_) {
          return <String, dynamic>{
            'type': 'recent',
            'query': raw,
            'title': raw
          };
        }
      }).toList();
    } else {
      final uniqueVideos = <VideoDescription>{};
      final uniqueAudios = <AudioDescription>{};
      for (var c in _video) {
        for (var v in c.videoDescriptions) {
          if (v.videoTitle.toLowerCase().contains(query.toLowerCase())) {
            uniqueVideos.add(v);
          }
        }
      }
      for (var c in _audio) {
        for (var a in c.audiolist) {
          if (a.audioTitle.toLowerCase().contains(query.toLowerCase())) {
            uniqueAudios.add(a);
          }
        }
      }
      results = [...uniqueVideos, ...uniqueAudios];
    }

    setState(() => _filteredContent = results);
    _refreshOverlay();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    _filterContent(query);
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (_showSearch) {
        FocusManagerService.isSearchActive = true;
        _filteredContent = _recentSearch.map((raw) {
          try {
            return jsonDecode(raw) as Map<String, dynamic>;
          } catch (_) {
            return <String, dynamic>{
              'type': 'recent',
              'query': raw,
              'title': raw
            };
          }
        }).toList();
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            _searchFocusNode.requestFocus();
            _showOverlay();
          }
        });
      } else {
        FocusManagerService.isSearchActive = false;
        _removeOverlay();
        _searchController.clear();
        _filteredContent.clear();
        FocusManagerService.globalFocusNode.requestFocus();
      }
    });
  }

  Future<void> saveRecentSearch(
      String query, String type, String title) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode({'query': query, 'type': type, 'title': title});
    if (!mounted) return;
    setState(() {
      _recentSearch.insert(0, json);
      if (_recentSearch.length > 5) {
        _recentSearch = _recentSearch.sublist(0, 5);
      }
    });
    await prefs.setStringList('recentSearch', _recentSearch);
  }

  Future<void> loadRecentSearch() async {
    final prefs = await SharedPreferences.getInstance();
    // FIX: Store raw JSON strings only — do NOT decode here to avoid cast crash
    final saved = prefs.getStringList('recentSearch') ?? [];
    if (!mounted) return;
    setState(() => _recentSearch = saved);
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _handleNavigation(int index) {
    if (index == 0) {
      _toggleSearch();
    } else if (index == 1) {
      _showNotificationDialog();
    } else if (index == 2) {
      FocusManagerService.isLoginPageFocused = false;
      Navigator.of(context).popUntil((route) => route.isFirst);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            FocusManagerService.setSidebarFocus();
            FocusManagerService.selectedSidebarIndex = 6;
            FocusManagerService.focusedSidebarIndex = 6;
            FocusManagerService.globalFocusNode.requestFocus();
          });
        }
      });
    }
  }

  void _onSearchItemSelected(dynamic item) {
    _removeOverlay();
    setState(() {
      _showSearch = false;
      FocusManagerService.isSearchActive = false;
    });
    _searchController.clear();
    _filteredContent.clear();

    if (item is VideoDescription) {
      saveRecentSearch(item.videoTitle, 'video', item.videoTitle);
      final idx = allMovies.indexWhere((v) => v.id == item.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MoviesPlayerPage(
            videoDescriptions: allMovies,
            categoryId:
                item.categoryList.isNotEmpty ? item.categoryList[0] : 0,
            initialIndex: idx < 0 ? 0 : idx,
          ),
        ),
      ).then((_) {
        if (mounted) FocusManagerService.globalFocusNode.requestFocus();
      });
    } else if (item is AudioDescription) {
      saveRecentSearch(item.audioTitle, 'audio', item.audioTitle);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SongPlayerPage(
            music: item,
            musicList: allSongs,
            onChange: (newAudio) {
              Provider.of<AudioProvider>(context, listen: false)
                  .setCurrentlyPlayingSong(newAudio, allSongs);
            },
            onDislike: (p0) {},
          ),
        ),
      ).then((_) {
        if (mounted) FocusManagerService.globalFocusNode.requestFocus();
      });
    } else if (item is Map<String, dynamic>) {
      final query = item['query'] as String? ?? '';
      _searchController.text = query;
      setState(() => _showSearch = true);
      FocusManagerService.isSearchActive = true;
      _filterContent(query);
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Text('Notifications'),
            IconButton(
              tooltip: 'Clear All',
              onPressed: _clearAllNotifications,
              icon: const Icon(Icons.clear_all_rounded),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: notifications == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications!.length,
                  itemBuilder: (context, index) {
                    final n = notifications![index];
                    return ListTile(
                        title: Text(n.title),
                        subtitle: Text(n.message));
                  },
                ),
        ),
        actions: [
          TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all as read')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close')),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: _showSearch
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search Movies and Songs...',
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.white60),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: _toggleSearch,
                  ),
                ),
                onChanged: _filterContent,
                onSubmitted: _performSearch,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (cachedImageBytes != null)
                    SizedBox(
                      height: 60,
                      width: 70,
                      child: Image.memory(
                        cachedImageBytes!,
                        fit: BoxFit.contain,
                      ),
                    )
                  else
                    Image.asset('assets/icon/media_jungle.png', height: 55),
                ],
              ),
        actions: [
          _buildTopRowIcon(0, Icons.search_outlined),
          const SizedBox(width: 10),
          _buildTopRowIcon(1, Icons.notifications_none, hasBadge: true),
          const SizedBox(width: 10),
          _buildTopRowIcon(2, Icons.person),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildTopRowIcon(int index, IconData icon,
      {bool hasBadge = false}) {
    final bool isSelected = FocusManagerService.isTopRowFocused &&
        FocusManagerService.selectedTopRowIndex == index;
    return GestureDetector(
      onTap: () => _handleNavigation(index),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(isSelected ? 4 : 0),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(186, 236, 236, 236)
                  : null,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 1)
                  : null,
            ),
            child: Icon(icon, color: Colors.white, size: 25),
          ),
          if (hasBadge && unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.red,
                child: Text(
                  unreadCount.toString(),
                  style:
                      const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultTile(dynamic item) {
    String title;
    String subtitle;
    IconData icon;

    if (item is VideoDescription) {
      title = item.videoTitle;
      subtitle = 'Movie';
      icon = Icons.movie_outlined;
    } else if (item is AudioDescription) {
      title = item.audioTitle;
      subtitle = 'Song';
      icon = Icons.music_note_outlined;
    } else if (item is Map<String, dynamic>) {
      title = item['title'] as String? ?? item['query'] as String? ?? '';
      subtitle = 'Recent';
      icon = Icons.history;
    } else {
      return const SizedBox.shrink();
    }

    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle:
          Text(subtitle, style: const TextStyle(color: Colors.white54)),
      onTap: () => _onSearchItemSelected(item),
    );
  }
}