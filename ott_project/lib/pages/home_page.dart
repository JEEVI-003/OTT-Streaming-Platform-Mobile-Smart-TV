// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:ott_project/components/music_folder/listen_again.dart';
// import 'package:ott_project/components/music_folder/music_player_page.dart';
// import 'package:ott_project/components/pallete.dart';
// import 'package:ott_project/pages/app_icon.dart';
// import 'package:ott_project/pages/blockbuster_movie_page.dart';
// import 'package:ott_project/service/audio_service.dart';
// import 'package:ott_project/service/icon_service.dart';
// import 'package:ott_project/service/movie_service_page.dart';
// import 'package:ott_project/service/service.dart';
// import 'package:ott_project/components/video_folder/movie.dart';
// import 'package:ott_project/components/music_folder/audio.dart';
// import 'package:ott_project/components/video_folder/video_play.dart';
// import 'package:archive/archive.dart';
// import 'package:provider/provider.dart';
// import '../components/background_image.dart';
// import '../components/music_folder/audio_provider.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final TextEditingController _searchController = TextEditingController();
//   late List<Movie> _allMovies = [];
//   late List<Audio> _music = [];
//   Map<String, List<Movie>> _movieCategory = {};
//   Map<String, List<Audio>> _audioCategory = {};
//   bool _showSearch = false;
//   AppIcon? iconData;
//   final Service service = Service();
//   List<dynamic> _filteredContent = [];

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
//     try {
//       //print('Heloooo');
//       final movies = await MovieService.fetchMovies();
//       //print('Movie: $movies');
//       final audios = await AudioService.fetchAudio();
//       // print('Audio: $audios');
//       setState(() {
//         _allMovies = movies;
//         _music = audios;
//         _categorizeMovies();
//         _categorizeAudios();
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
//       if (!_movieCategory.containsKey(movie.category)) {
//         _movieCategory[movie.category] = [];
//       }
//       _movieCategory[movie.category]!.add(movie);
//     }
//   }

//   void _categorizeAudios() {
//     _audioCategory = {};
//     for (var song in _music) {
//       if (!_audioCategory.containsKey(song.categoryName)) {
//         _audioCategory[song.categoryName] = [];
//       }
//       _audioCategory[song.categoryName]!.add(song);
//     }
//   }

//   Future<void> _refreshData() async {
//     await _fetchData();
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
//       body: Stack(
//         children: [
//           BackgroundImage(),
//           //CustomAppBar(),
//           Container(
//             margin: EdgeInsets.only(top: 90),
//             child: RefreshIndicator(
//               onRefresh: _refreshData,
//               child: _allMovies.isEmpty || _music.isEmpty
//                   ? Center(
//                       child: CircularProgressIndicator(),
//                     )
//                   : _showSearch
//                       ? _buildSearchResults()
//                       : SingleChildScrollView(
//                           child: Padding(
//                             padding: const EdgeInsets.all(10.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _buildMovieSection('Recent Movies', 'Recent'),
//                                 SizedBox(
//                                   height: 5,
//                                 ),
//                                 _buildMovieSection(
//                                     'BlockBuster Movies', 'Popular'),
//                                 SizedBox(
//                                   height: 5,
//                                 ),
//                                 _buildHorizontalMusicSection(
//                                     'Romantic Hits', 6),
//                                 // SizedBox(
//                                 //   height: 5,
//                                 // ),
//                                 ListenAgainSection(
//                                     allAudios: _music,
//                                     categoryPlayList: _music,
//                                     onAudioTap: (Audio song) {
//                                       print(
//                                           "onAudioTap called in HomePage for song: ${song.songname}");

//                                       setState(() {});
//                                       Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   MusicPlayerPage(
//                                                       audio: song,
//                                                       onDislike: (p0) {},
//                                                       onChange: (newAudio) {
//                                                         setState(() {
//                                                           Provider.of<AudioProvider>(
//                                                                   context,
//                                                                   listen: false)
//                                                               .setCurrentlyPlaying(
//                                                                   newAudio,
//                                                                   _music); // or whatever list you want to use
//                                                         });
//                                                       }))).then((_) {
//                                         print("Returned from MusicPlayerPage");
//                                         setState(() {});
//                                       });
//                                     }),
//                                 SizedBox(
//                                   height: 5,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//             ),
//             //),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMovieSection(String title, String category) {
//     if (!_movieCategory.containsKey(category) ||
//         _movieCategory[category]!.isEmpty) {
//       print('Category does not exist or empty');
//       print(_movieCategory['BlockBuster']);
//       return Container();
//     }
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.all(16.0),
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
//           height: 180,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: _movieCategory[category]!.length,
//             itemBuilder: (context, index) {
//               final movie = _movieCategory[category]![index];
//               final compressedBytes = base64.decode(movie.thumbnail);
//               final decompressedBytes =
//                   ZLibDecoder().decodeBytes(compressedBytes);
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: GestureDetector(
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => VideoPlayerPage(
//                               movies: _allMovies,
//                               initialIndex: _allMovies.indexOf(movie),
//                             )),
//                   ),
//                   // child: Card(
//                   //   color: Colors.transparent,
//                   child: Container(
//                     width: 100,
//                     child: Column(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.memory(
//                               Uint8List.fromList(decompressedBytes),
//                               width: 100,
//                               height: 115,
//                               fit: BoxFit.fill),
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
//                           maxLines: 2,
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

//  Widget _buildHorizontalMusicSection(String title, String categoryName) {
//   return _audioCategory.containsKey(categoryName)
//       ? Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(title,
//                       style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: kWhite)),
//                   TextButton(
//                       onPressed: () {},
//                       child: Text('See more',
//                           style: TextStyle(color: Colors.green))),
//                 ],
//               ),
//             ),
//             Container(
//               height: 160,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: _audioCategory[categoryName]!.length,
//                 itemBuilder: (context, index) {
//                   final song = _audioCategory[categoryName]![index];
//                   final compressedBytes = base64.decode(song.thumbnail);
//                   final decompressedBytes =
//                       ZLibDecoder().decodeBytes(compressedBytes);

//                   return GestureDetector(
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => MusicPlayerPage(
//                                 audio: song,
//                                 audioList: _audioCategory[categoryName]!,
//                                 onDislike: (p0) {},
//                                 onChange: (newAudio) {
//                                   Provider.of<AudioProvider>(context,
//                                           listen: false)
//                                       .setCurrentlyPlaying(newAudio, _music);
//                                 },
//                               )),
//                     ),
//                     child: Container(
//                       width: 105,
//                       margin: EdgeInsets.only(right: 10),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: Image.memory(
//                                   Uint8List.fromList(decompressedBytes),
//                                   width: 100,
//                                   height: 120,
//                                   fit: BoxFit.fill,
//                                 ),
//                               ),
//                               Icon(Icons.play_circle,
//                                   color: Colors.white, size: 35),
//                             ],
//                           ),
//                           SizedBox(height: 10),
//                           Text(
//                             song.songname,
//                             style: TextStyle(color: Colors.white),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         )
//       : Container();
// }

//   Widget _buildSearchResults() {
//   if (_searchController.text.isEmpty) {
//     return Container();
//   }

//   if (_filteredContent.isEmpty) {
//     return Center(
//       child: Text(
//         'No movies or song found',
//         style: TextStyle(color: Colors.white, fontSize: 18),
//       ),
//     );
//   }

//   return ListView.builder(
//     itemCount: _filteredContent.length,
//     itemBuilder: (context, index) {
//       final item = _filteredContent[index];

//       final compressedBytes = base64.decode(item.thumbnail);
//       final decompressedBytes =
//           ZLibDecoder().decodeBytes(compressedBytes);

//       return ListTile(
//         title: Text(
//           item is Movie ? item.moviename : item.songname,
//           style: TextStyle(color: Colors.white),
//         ),
//         subtitle: Text(
//           item is Movie ? 'Movie' : 'Song',
//           style: TextStyle(color: Colors.white70),
//         ),
//         leading: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.memory(
//             Uint8List.fromList(decompressedBytes),
//             width: 35,
//             height: 35,
//             fit: BoxFit.fill,
//           ),
//         ),
//         onTap: () {
//           if (item is Movie) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => VideoPlayerPage(
//                   movies: _allMovies,
//                   initialIndex: _allMovies.indexOf(item),
//                 ),
//               ),
//             );
//           }

//           if (item is Audio) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => MusicPlayerPage(
//                   audio: item,
//                   audioList: _music,
//                   onDislike: (p0) {},
//                   onChange: (newAudio) {
//                     Provider.of<AudioProvider>(context, listen: false)
//                         .setCurrentlyPlaying(newAudio, _music);
//                   },
//                 ),
//               ),
//             );
//           }
//         },
//       );
//     },
//   );
// }