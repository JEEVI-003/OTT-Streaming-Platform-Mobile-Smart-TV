import 'package:flutter/material.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/library/playlist_page.dart';
import 'package:ott_project/components/library/watch_list_page.dart';
import 'package:ott_project/components/library/liked_songs_page.dart';

import 'package:ott_project/pages/app_icon.dart';
import 'package:ott_project/pages/custom_appbar.dart';

import '../../service/icon_service.dart';

class LibraryPage extends StatefulWidget {
  final int userId;
  const LibraryPage({super.key, required this.userId});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  AppIcon? iconData;
  //bool _showSearch = false;
  //TextEditingController _searchController = TextEditingController();

  void initState() {
    super.initState();
    _loadIcon();
  }

  Future<void> _loadIcon() async {
    try {
      final icon = await IconService.fetchIcon();

      setState(() {
        iconData = icon;
      });
    } catch (e) {
      print('Error loading icon: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackgroundImage(),
          Column(
            children: [
               CustomAppBar(onSearchChanged: (p0, p1) {
                 
               },),
               SizedBox(
                height: MediaQuery.sizeOf(context).height *0.04,
              ),
              Text('Library',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
              SizedBox(
                height: MediaQuery.sizeOf(context).height *0.04,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.favorite,
                        color: Colors.white,
                      ),
                      title: Text('Liked Songs',
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LikedSongsPage(
                                    userId: widget.userId,
                                  )),
                        ).then((value) => setState(() {}));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.playlist_add, color: Colors.white),
                      title: Text('Playlists',
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlayListPage()),
                        );
                      },
                    ),
                     ListTile(
                        leading: Icon(Icons.video_library_rounded,
                            color: Colors.white),
                        title: Text('Watchlater',
                            style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WatchListPage(userId: widget.userId,)),
                          );
                        }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
