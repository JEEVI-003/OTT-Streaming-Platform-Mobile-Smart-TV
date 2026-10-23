// import 'dart:typed_data';
// import 'package:flutter/material.dart';

// import 'package:ott_project/components/music_folder/music.dart';
// import 'package:ott_project/components/music_folder/music_listen_again.dart';
// // import 'package:ott_project/components/music_folder/listen_again.dart';
// // import 'package:ott_project/components/music_folder/music_player_page.dart';
// // import 'package:ott_project/components/music_folder/audio.dart';
// //import '../components/music_folder/audio_provider.dart';
// // import 'package:provider/provider.dart';
// import 'package:ott_project/components/pallete.dart';
// import 'package:ott_project/pages/app_icon.dart';
// import 'package:ott_project/pages/custom_appbar.dart';
// import 'package:ott_project/pages/blockbuster_movie_page.dart';
// import 'package:ott_project/service/audio_service.dart';
// import 'package:ott_project/service/icon_service.dart';
// import 'package:ott_project/service/movie_service_page.dart';
// import 'package:ott_project/service/service.dart';
// import 'package:ott_project/components/video_folder/movie.dart';
// import 'package:provider/provider.dart';

// import '../components/background_image.dart';
// import '../components/music_folder/audio_provider.dart';
// import '../components/music_folder/song_player_page.dart';

// class SampleHomePage extends StatefulWidget {
//   @override
//   _SampleHomePageState createState() => _SampleHomePageState();
// }

// class _SampleHomePageState extends State<SampleHomePage> {
//   final TextEditingController _searchController = TextEditingController();
//   late List<Movies> _allMovies = [];
//   late List<Music> _music = [];
//   Map<String, List<Movies>> _movieCategory = {};
//   late Map<String, List<Music>> _musicCategory = {};
//   //Map<String, List<Music>> _audioCategory = {};
//   // bool _showSearch = false;
//   AppIcon? iconData;
//   final Service service = Service();
//   //List<dynamic> _filteredContent = [];
//   bool _isSearching = false;
//   List<dynamic> _searchResults = [];

//   @override
//   void initState() {
//     super.initState();
//     print('init called');
//     _fetchData();
//     _loadIcon();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchData() async {
//     // print('Heloooo');
//     try {
//       // print('Heloooo');
//       final movies = await MovieService.fetchVideos();
//       print('Movie: $movies');
//       final musicByCategory = await AudioService.fetchMusicByCategory();
//       final allMusic = await AudioService.fetchAllMusic();
//       //print('Audio: $audios');
//       setState(() {
//         _allMovies = movies;
//         _musicCategory = musicByCategory;
//         _music = allMusic;
//         _categorizeMovies();
//         // _categorizeAudios();
//       });
//       // print(_allMovies);
//     } catch (e) {
//       throw Exception('Failed to load movies');
//     }
//   }

//   Future<void> _loadIcon() async {
//     try {
//       final icon = await IconService.fetchIcon();

//       setState(() {
//         iconData = icon;
//       });
//     } catch (e) {
//       print('Error loading icon: $e');
//     }
//   }

//   void _categorizeMovies() {
//     _movieCategory = {};
//     for (var movie in _allMovies) {
//       if (!_movieCategory.containsKey(movie.categories)) {
//         // _movieCategory[movie.categories] = [];
//       }
//       _movieCategory[movie.categories]!.add(movie);
//     }
//   }

//   // void _categorizeAudios() {
//   //   _audioCategory = {};
//   //   for (var song in _music) {
//   //     if (!_audioCategory.containsKey(song.categoryName)) {
//   //       _audioCategory[song.categoryName] = [];
//   //     }
//   //     _audioCategory[song.categoryName]!.add(song);
//   //   }
//   // }

//   Future<void> _refreshData() async {
//     await _fetchData();
//   }

//   void handleSearchState(bool isSearching, List<dynamic> results) {
//     setState(() {
//       _isSearching = isSearching;
//       _searchResults = results;
//     });
//   }
//   // void _filterContent(String query) {
//   //   setState(() {
//   //     if (query.isEmpty) {
//   //       _filteredContent = [];
//   //     } else {
//   //       final uniqueMovies = <Movie>{};
//   //       final uniqueSongs = <Audio>{};

//   //       uniqueMovies.addAll(_allMovies.where((movie) =>
//   //           movie.moviename.toLowerCase().contains(query.toLowerCase())));
//   //       uniqueSongs.addAll(_music.where((song) =>
//   //           song.songname.toLowerCase().contains(query.toLowerCase())));
//   //       _filteredContent = [
//   //         ...uniqueMovies,
//   //         ...uniqueSongs,
//   //       ];
//   //     }
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       //appBar: CustomAppBar(),
//       body: Stack(
//         children: [
//           BackgroundImage(),
//           CustomAppBar(
//             onSearchChanged: handleSearchState,
//           ),
//           _isSearching
//               ? _buildSearchResults()
//               : Container(
//                   margin: EdgeInsets.only(top: 90),
//                   child: RefreshIndicator(
//                     onRefresh: _refreshData,
//                     child: _allMovies.isEmpty || _musicCategory.isEmpty
//                         ? Center(
//                             child: CircularProgressIndicator(),
//                           )
//                         // : _isSearching
//                         //     ? _buildSearchResults()
//                         : SingleChildScrollView(
//                             child: Padding(
//                               padding: const EdgeInsets.all(10.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   _buildMovieSection('Recent Movies', 'Recent'),
//                                   SizedBox(
//                                     height: 5,
//                                   ),
//                                   _buildMovieSection(
//                                       'BlockBuster Movies', 'Popular'),
//                                   SizedBox(
//                                     height: 5,
//                                   ),
//                                   _buildMovieSection('Must Watch', 'Action'),
//                                   SizedBox(
//                                     height: 5,
//                                   ),
//                                   _buildHorizontalMusicSection('Romantic Hits',
//                                       _musicCategory['Romance'] ?? []),
//                                   SizedBox(
//                                     height: 5,
//                                   ),
//                                   _music.isEmpty
//                                       ? CircularProgressIndicator()
//                                       : MusicListenAgainSection(
//                                           allAudios: _music,
//                                           categoryPlayList: _music,
//                                           onAudioTap: (Music song) {
//                                             print(
//                                                 "onAudioTap called in SampleHomePage for song: ${song.songname}");
//                                             Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         SongPlayerPage(
//                                                             music: song,
//                                                             onChange:
//                                                                 (newAudio) {
//                                                               setState(() {
//                                                                 Provider.of<AudioProvider>(
//                                                                         context,
//                                                                         listen:
//                                                                             false)
//                                                                     .musicsetCurrentlyPlaying(
//                                                                         newAudio,
//                                                                         _music);
//                                                               });
//                                                             },
//                                                             onDislike:
//                                                                 (p0) {})));
//                                             setState(() {});
//                                           }),
//                                   // Navigator.push(
//                                   //     context,
//                                   //     MaterialPageRoute(
//                                   //         builder: (context) =>
//                                   //             MusicPlayerPage(
//                                   //                 audio: song,
//                                   //                 onDislike: (p0) {},
//                                   //                 onChange: (newAudio) {
//                                   //                   setState(() {
//                                   //                     Provider.of<AudioProvider>(
//                                   //                             context,
//                                   //                             listen: false)
//                                   //                         .setCurrentlyPlaying(
//                                   //                             newAudio,
//                                   //                             _music); // or whatever list you want to use
//                                   //                   });
//                                   //                 }))).then((_) {
//                                   //   print("Returned from MusicPlayerPage");
//                                   //   setState(() {});
//                                   // });

//                                   SizedBox(
//                                     height: 5,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                   ),
//                   //),
//                 ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMovieSection(String title, String category) {
//     if (!_movieCategory.containsKey(category) ||
//         _movieCategory[category]!.isEmpty) {
//       //print('Category does not exist or empty');
//       print(_movieCategory['BlockBuster']);
//       return Container();
//     }
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                     fontSize: 20, fontWeight: FontWeight.bold, color: kWhite),
//               ),
//               TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => BlockBusterPage()));
//                   },
//                   child:
//                       Text('See more', style: TextStyle(color: Colors.green))),
//             ],
//           ),
//         ),
//         Container(
//           height: 160,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: _movieCategory[category]!.length,
//             itemBuilder: (context, index) {
//               final movie = _movieCategory[category]![index];
//               // final compressedBytes = base64.decode(movie.thumbnail);
//               // final decompressedBytes =
//               //     ZLibDecoder().decodeBytes(compressedBytes);
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: GestureDetector(
//                   onTap: () {},
//                   // => Navigator.push(
//                   //   context,
//                   //   MaterialPageRoute(
//                   //       builder: (context) => VideoPlayerPage(
//                   //             movies: _allMovies,
//                   //             initialIndex: _allMovies.indexOf(movie),
//                   //           )),
//                   // ),
//                   // child: Card(
//                   //   color: Colors.transparent,
//                   child: Container(
//                     width: 100,
//                     child: Column(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.asset(
//                             'assets/icon/media_jungle.png',
//                             width: 100,
//                             height: 115,
//                           ),
//                           // Image.memory(
//                           //     Uint8List.fromList(decompressedBytes),
//                           //     width: 100,
//                           //     height: 115,
//                           //     fit: BoxFit.fill),
//                         ),
//                         SizedBox(
//                           height: 3,
//                         ),
//                         Text(
//                           movie.moviename,
//                           style: TextStyle(
//                             color: kWhite,
//                           ),
//                           softWrap: true,
//                           overflow: TextOverflow.ellipsis,
//                           textAlign: TextAlign.center,
//                           maxLines: 1,
//                         ),
//                       ],
//                     ),
//                   ),
//                   //),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   // Widget _buildHorizontalMusicSection(String title, int categoryId) {
//   //   return _audioCategory.containsKey(categoryId)
//   //       ? Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             Padding(
//   //               padding: EdgeInsets.all(16.0),
//   //               child: Row(
//   //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                 children: [
//   //                   Text(title,
//   //                       style: TextStyle(
//   //                           fontSize: 20,
//   //                           fontWeight: FontWeight.bold,
//   //                           color: kWhite)),
//   //                   TextButton(
//   //                       onPressed: () {},
//   //                       child: Text('See more',
//   //                           style: TextStyle(color: Colors.green))),
//   //                 ],
//   //               ),
//   //             ),
//   //             Container(
//   //               height: 160,
//   //               child: ListView.builder(
//   //                 scrollDirection: Axis.horizontal,
//   //                 itemCount: _audioCategory[categoryId]!.length,
//   //                 itemBuilder: (context, index) {
//   //                   final song = _audioCategory[categoryId]![index];
//   //                   final compressedBytes = base64.decode(song.thumbnail);
//   //                   final decompressedBytes =
//   //                       ZLibDecoder().decodeBytes(compressedBytes);
//   //                   return GestureDetector(
//   //                     onTap: () => Navigator.push(
//   //                       context,
//   //                       MaterialPageRoute(
//   //                           builder: (context) => MusicPlayerPage(
//   //                                 audio: song,
//   //                                 // isLiked: true,
//   //                                 // onLike: (p0, p1) => {},
//   //                                 audioList: _audioCategory[categoryId]!,
//   //                                 onDislike: (p0) {},
//   //                                 onChange: (newAudio) {
//   //                                   Provider.of<AudioProvider>(context,
//   //                                           listen: false)
//   //                                       .setCurrentlyPlaying(newAudio, _music);
//   //                                 },
//   //                               )),
//   //                     ),
//   //                     child: Container(
//   //                       width: 105,
//   //                       margin: EdgeInsets.only(right: 10),
//   //                       child: Column(
//   //                         crossAxisAlignment: CrossAxisAlignment.center,
//   //                         children: [
//   //                           Stack(
//   //                             alignment: Alignment.center,
//   //                             children: [
//   //                               ClipRRect(
//   //                                 borderRadius: BorderRadius.circular(10),
//   //                                 child: Image.memory(
//   //                                   Uint8List.fromList(decompressedBytes),
//   //                                   width: 100,
//   //                                   height: 120,
//   //                                   fit: BoxFit.fill,
//   //                                 ),
//   //                               ),
//   //                               Icon(Icons.play_circle,
//   //                                   color: Colors.white, size: 35),
//   //                             ],
//   //                           ),
//   //                           SizedBox(height: 10),
//   //                           Text(
//   //                             song.songname,
//   //                             style: TextStyle(color: Colors.white),
//   //                             maxLines: 1,
//   //                             overflow: TextOverflow.ellipsis,
//   //                           ),
//   //                         ],
//   //                       ),
//   //                     ),
//   //                   );
//   //                 },
//   //               ),
//   //             ),
//   //           ],
//   //         )
//   //       : Container();
//   // }

//   Widget _buildHorizontalMusicSection(String title, List<Music> songs) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(title,
//                   style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: kWhite)),
//               TextButton(
//                   onPressed: () {},
//                   child:
//                       Text('See more', style: TextStyle(color: Colors.green))),
//             ],
//           ),
//         ),
//         Container(
//           height: 180,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: songs.length,
//             itemBuilder: (context, index) {
//               final song = songs[index];
//               return GestureDetector(
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => SongPlayerPage(
//                             music: song,
//                             musicList: songs,
//                             onDislike: (p0) {},
//                             onChange: (newAudio) {
//                               Provider.of<AudioProvider>(context, listen: false)
//                                   .musicsetCurrentlyPlaying(newAudio, songs);
//                             },
//                           )),
//                 ),
//                 child: Container(
//                   width: 110,
//                   margin: EdgeInsets.only(right: 10),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Container(
//                             height: 135,
//                             width: 120,
//                             decoration: BoxDecoration(
//                                 color: Colors.grey[800],
//                                 borderRadius: BorderRadius.circular(7)),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: FutureBuilder<Uint8List?>(
//                                 future: song.thumbnailImage,
//                                 //audio.bannerImage,

//                                 builder: (context, snapshot) {
//                                   //print('Thumbnail:${song.thumbnailImage}');
//                                   if (snapshot.connectionState ==
//                                           ConnectionState.done &&
//                                       snapshot.hasData) {
//                                     return Image.memory(snapshot.data!,
//                                         width: 164,
//                                         height: 135,
//                                         fit: BoxFit.fill);
//                                   } else {
//                                     return Container(
//                                       width: 164,
//                                       height: 135,
//                                       // fit: BoxFit.fill
//                                       color: Colors.grey,
//                                       child: Center(
//                                           child: CircularProgressIndicator()),
//                                     );
//                                   }
//                                 },
//                               ),
//                               // child: Container(
//                               //   width: 100,
//                               //   height: 120,
//                               //   color: Colors.grey, // Placeholder color
//                               //   child: Center(
//                               //     child:
//                               //     // Text(
//                               //     //   song.songname,
//                               //     //   style: TextStyle(
//                               //     //     color: Colors.white,
//                               //     //     fontSize: 40,
//                               //     //     fontWeight: FontWeight.bold,
//                               //     //   ),
//                               //     // ),
//                               //  // ),
//                               // ),
//                             ),
//                           ),
//                           Icon(Icons.play_circle,
//                               color: Colors.white, size: 35),
//                         ],
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         song.songname,
//                         style: TextStyle(color: Colors.white),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSearchResults() {
//     return Container(
//       margin: EdgeInsets.only(top: 90),
//       child: ListView.builder(
//         itemCount: _searchResults.length,
//         itemBuilder: (context, index) {
//           final item = _searchResults[index];
//           return ListTile(
//             title: Text(item is Movie ? item.moviename : item.songname,
//                 style: TextStyle(color: Colors.white)),
//             subtitle: Text(item is Movie ? 'Movie' : 'Song',
//                 style: TextStyle(color: Colors.white70)),
//             onTap: () {
//               // if (item is Movie) {
//               //   Navigator.push(
//               //     context,
//               //     MaterialPageRoute(
//               //       builder: (context) => VideoPlayerPage(
//               //         movies: _allMovies,
//               //         initialIndex: _allMovies.indexOf(item),
//               //       ),
//               //     ),
//               //   );
//               // }
//             },
//           );
//         },
//       ),
//     );
//   }
// }
