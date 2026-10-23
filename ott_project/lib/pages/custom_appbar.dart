import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/components/notification/notification.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:ott_project/components/video_folder/video_container.dart';
import 'package:ott_project/pages/app_icon.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ott_project/pages/main_tab.dart';
import 'package:ott_project/pages/movie_page.dart';
import 'package:ott_project/service/audio_service.dart';
import 'package:ott_project/service/movie_service_page.dart';
import 'package:ott_project/service/notification_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/icon_service.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function(bool, List<dynamic>) onSearchChanged;
  const CustomAppBar({
    super.key,
    required this.onSearchChanged,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  List<dynamic> _filteredContent = [];
  List<AudioContainer> _audio = [];
  List<VideoContainer> _video = [];
  Uint8List? iconData;
  List<Notifications>? notifications;
  int unreadCount = 0;
  final storage = FlutterSecureStorage();
  String? token;

  // FIX 1: _recentSearch now stores the raw JSON strings exactly as saved,
  // so we can decode them consistently without a broken cast.
  List<String> _recentSearchRaw = [];

  @override
  void initState() {
    super.initState();
    _loadIcon();
    _loadToken();
    _loadVideoAndAudioContainers();
    loadRecentSearch();
  }

  Future<void> _loadToken() async {
    try {
      token = await storage.read(key: 'token');
      if (token != null) {
        _loadNotifications();
        _loadUnreadCount();
      } else {
        if (mounted) {
          setState(() {
            notifications = [];
            unreadCount = 0;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          notifications = [];
          unreadCount = 0;
        });
      }
    }
  }

  Future<void> _loadIcon() async {
    try {
      final icon = await IconService.fetchIcon();
      final decodedBytes = base64Decode(icon.icon);
      setState(() {
        iconData = decodedBytes;
      });
    } catch (e) {
      // keep silent in release; icon falls back gracefully
    }
  }

  Future<void> _loadVideoAndAudioContainers() async {
    _video = await MovieService.fetchVideoContainer();
    _audio = await AudioService.fetchAudioContainer();
  }

  Future<void> _loadNotifications() async {
    if (token == null || token!.isEmpty) {
      if (!mounted) return;
      setState(() {
        notifications = [];
      });
      return;
    }

    final loadedNotifications =
        await NotificationApiService().fetchNotification(token);
    if (!mounted) return;
    setState(() {
      this.notifications = loadedNotifications;
    });
  }

  Future<void> _loadUnreadCount() async {
    if (token == null || token!.isEmpty) {
      if (!mounted) return;
      setState(() {
        unreadCount = 0;
      });
      return;
    }

    try {
      final count = await NotificationApiService().fetchUnreadCount(token);
      if (!mounted) return;
      setState(() {
        unreadCount = count;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        unreadCount = 0;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    if (token == null || token!.isEmpty) return;
    try {
      final success = await NotificationApiService().markAllasRead(token);
      if (!mounted) return;
      setState(() {
        unreadCount = 0;
      });
      if (success) {
        _loadNotifications();
      }
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        unreadCount = 0;
      });
    }
  }

  Future<void> _clearAllNotifications() async {
    if (token == null || token!.isEmpty) return;
    try {
      final success = await NotificationApiService().clearAllNotifications(token);
      if (!mounted) return;
      setState(() {
        notifications = [];
        unreadCount = 0;
      });
      if (success) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        notifications = [];
        unreadCount = 0;
      });
    }
  }

  void _showNotification() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notifications'),
              IconButton(
                  tooltip: 'Clear All',
                  onPressed: _clearAllNotifications,
                  icon: const Icon(Icons.clear_all_rounded)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: notifications == null
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: notifications!.length,
                    itemBuilder: (context, index) {
                      final notification = notifications![index];
                      return ListTile(
                        title: Text(notification.title),
                        subtitle: Text(notification.message),
                      );
                    }),
          ),
          actions: [
            TextButton(
                onPressed: _markAllAsRead,
                child: const Text('Mark all as read')),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        _filteredContent.clear();
      } else {
        // FIX 2: Build recent-search list from the raw JSON strings
        // instead of the broken cast that crashed on initState
        _filteredContent = _recentSearchRaw.map((raw) {
          try {
            final decoded = jsonDecode(raw) as Map<String, dynamic>;
            return {'type': 'recent', ...decoded};
          } catch (_) {
            return {'type': 'recent', 'query': raw, 'title': raw};
          }
        }).toList();
      }
      widget.onSearchChanged(_showSearch, _filteredContent);
    });
  }

  Future<void> saveRecentSearch(
      String query, String type, String title) async {
    final prefs = await SharedPreferences.getInstance();
    final recentSearch = {'query': query, 'type': type, 'title': title};
    final recentSearchJson = jsonEncode(recentSearch);
    setState(() {
      _recentSearchRaw.insert(0, recentSearchJson);
      if (_recentSearchRaw.length > 5) {
        _recentSearchRaw = _recentSearchRaw.sublist(0, 5);
      }
    });
    await prefs.setStringList('recentSearch', _recentSearchRaw);
  }

  Future<void> loadRecentSearch() async {
    final prefs = await SharedPreferences.getInstance();
    // FIX 3: Store the raw JSON strings — do NOT decode + re-cast to String,
    // which was the original crash (Map<String,dynamic> is not a String).
    final savedSearches = prefs.getStringList('recentSearch') ?? [];
    setState(() {
      _recentSearchRaw = savedSearches;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: _showSearch
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search Movies and Songs...',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  onChanged: _filterContent,
                  onSubmitted: _performSearch,
                )
              : Row(
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.04,
                    ),
                    if (iconData != null)
                      IconButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MainTab(initialTab: 0)),
                                (route) => false);
                          },
                          icon: Image.memory(iconData!, height: 70))
                    else
                      Image.asset('assets/icon/media_jungle.png', height: 70),
                    const Spacer(),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.cast_connected_rounded,
                          color: kWhite,
                          size: 25,
                        )),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.05,
                    ),
                    // FIX 4: Wrap the bell + badge together in a Stack so the
                    // badge actually overlays the icon (Positioned requires a
                    // Stack ancestor — using it directly in a Row silently fails)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: _showNotification,
                          child: const Icon(
                            Icons.notifications_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              constraints: const BoxConstraints(
                                  minHeight: 16, minWidth: 16),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                    color: kWhite, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
          actions: [
            IconButton(
              onPressed: _toggleSearch,
              icon: Icon(
                _showSearch ? Icons.close : Icons.search_rounded,
                color: kWhite,
              ),
            ),
            SizedBox(width: MediaQuery.sizeOf(context).width * 0.01),
            SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
          ],
        ),
      ],
    );
  }

  void _filterContent(String query) {
    setState(() {
      if (query.isEmpty) {
        // Show recent searches when query is cleared
        _filteredContent = _recentSearchRaw.map((raw) {
          try {
            final decoded = jsonDecode(raw) as Map<String, dynamic>;
            return {'type': 'recent', ...decoded};
          } catch (_) {
            return {'type': 'recent', 'query': raw, 'title': raw};
          }
        }).toList();
      } else {
        final uniqueVideos = <VideoDescription>{};
        final uniqueAudios = <AudioDescription>{};

        for (var container in _video) {
          for (var video in container.videoDescriptions) {
            if (video.videoTitle
                .toLowerCase()
                .contains(query.toLowerCase())) {
              uniqueVideos.add(video);
            }
          }
        }

        for (var container in _audio) {
          for (var audio in container.audiolist) {
            if (audio.audioTitle
                .toLowerCase()
                .contains(query.toLowerCase())) {
              uniqueAudios.add(audio);
            }
          }
        }

        _filteredContent = [
          ...uniqueVideos,
          ...uniqueAudios,
        ];
      }
    });
    widget.onSearchChanged(_showSearch, _filteredContent);
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    _filterContent(query);
    // Save to recent searches
    saveRecentSearch(query, 'manual', query);
  }
}