import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:ott_project/components/banners/audio_banner.dart';
import 'package:ott_project/components/category/music_category_section.dart';
import 'package:ott_project/components/music_folder/audio_provider.dart';
import 'package:ott_project/components/music_folder/currently_playing_bar.dart';
import 'package:ott_project/components/music_folder/recently_played.dart';
import 'package:ott_project/components/video_folder/video_container.dart';
import 'package:ott_project/pages/custom_appbar.dart';
import 'package:ott_project/pages/main_tab.dart';
import 'package:ott_project/service/audio_api_service.dart';
import 'package:ott_project/service/audio_service.dart';
import 'package:ott_project/service/movie_service_page.dart';
import 'package:provider/provider.dart';
import '../components/background_image.dart';
import '../components/music_folder/audio_container.dart';
import '../components/music_folder/song_player_page.dart';
import '../components/video_folder/movie_player_page.dart';


class MusicPage extends StatefulWidget {
  final int userId;
  const MusicPage({super.key, required this.userId});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  
  final TextEditingController _searchController = TextEditingController();
  //List<Music> _filteredAudios = [];
  
  List<AudioDescription> allSongs =[];
  late List<VideoDescription> _allVideos =[];
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  final RecentlyPlayed _mrecentlyPlayed = RecentlyPlayed();
   int currentBannerIndex = 0;
   List<AudioContainer> _audioContainers=[];
   List<AudioBanner> audiobanners =[];
    Map<int,Uint8List?> bannerImages = {};
    Map<int,AudioDescription> _audioDetails ={};
  bool _isLoading = true;
  bool _isBannerLoading = true; 

  @override
  void initState() {
    super.initState();
    _loadData();
     loadMovies();
    
   
    Provider.of<AudioProvider>(context, listen: false).loadCurrentlyPlaying();

    // _filterAudioList('');
  }

   Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
   await Future.wait([loadSongs(), loadBannerDetails()]);
  }

  Future<void> loadMovies() async {
  try {
    // Fetch the video containers
    List<VideoContainer> videoContainers = await MovieService.fetchVideoContainer();

    // Extract VideoDescription objects from the containers and populate allMovies
    _allVideos = videoContainers
        .expand((container) => container.videoDescriptions)
        .toList();
  print('all movies:${_allVideos}');
    // Ensure the UI updates after data is fetched
    setState(() {});
  } catch (e) {
    print('Error fetching movies: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load movies. Please try again.')),
    );
  }
}
 Future<void> loadSongs() async {
  try {
    // Fetch the video containers
    List<AudioContainer> audioContainers = await AudioService.fetchAudioContainer();

    // Extract VideoDescription objects from the containers and populate allMovies
    allSongs = audioContainers
        .expand((container) => container.audiolist)
        .toList();
  print('all movies:${allSongs}');
    // Ensure the UI updates after data is fetched
    setState(() {
      _audioContainers = audioContainers;
     _isLoading = false;
    });
  } catch (e) {
    print('Error fetching songs: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load songs. Please try again.')),
    );
  }
}

 Future<void> loadBannerDetails() async {
  try {
    final banners = await AudioApiService().fetchAllAudioBanner();
    final detailsMap = <int, AudioDescription>{};
    final imageMap = <int,Uint8List?>{};
    for (var banner in banners) {
      try {
        final details = await AudioApiService().fetchAudioDetails(banner.movienameID);
        detailsMap[banner.movienameID] = details;

        final image = await AudioService().fetchMusicBanner(banner.movienameID);
        imageMap[banner.movienameID] = image;
      } catch (e) {
        print('Error fetching details for video ${banner.movienameID}: $e');
      }
    }
     setState(() {
      audiobanners = banners;
      _audioDetails = detailsMap;
      bannerImages = imageMap;
      _isBannerLoading = false;
    });
  } catch (e) {
    print('Error loading banner: $e');
  }
 }



   void _navigateToCategory(String category) {
    switch (category) {
      case "All":
  
        break;
      case "Movies":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainTab(initialTab: 0)),
        );
        break;
      case "Music":
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MainTab(initialTab: 1)),
        );
        break;
      case "Library":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainTab(initialTab: 2)),
        );
        break;
       case "Profile":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainTab(initialTab: 3)),
        );
        break;
    }
  }


  Future<void> _refreshSongs() async {
     await loadSongs();
  }


  void handleSearchState(bool isSearching, List<dynamic> results) {
    setState(() {
      _isSearching = isSearching;
      _searchResults = results;
    });
  }

   @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: () async{
      return false;
    },
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
                   Positioned.fill(
            child: BackgroundImage(),
          ),

          Column(
            children: [
              CustomAppBar(onSearchChanged: handleSearchState),
            
          Expanded(
            child: _isSearching ?
            _buildSearchResults()
            : Container(
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.only(top: 5),
              child: Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshSongs,
                      child: ListView(
                        children: [
                          if(_isBannerLoading)
                             const Center(child: CircularProgressIndicator(),)
                          else
                           Stack(
                            children: [
                              Container(
                                height: MediaQuery.sizeOf(context).height * 0.25,
                               child:  CarouselSlider(
                                        options: CarouselOptions(
                                          height: double.infinity,
                                          viewportFraction: 1.0,
                                          autoPlay: true,
                                          autoPlayInterval: const Duration(seconds: 5),
                                          onPageChanged: (index, reason) {
                                            setState(() {
                                              currentBannerIndex = index;
                                            });
                                          },
                                        ),
                                        items: audiobanners.map((banner) {
                                          final details = _audioDetails[banner.movienameID];
final image = bannerImages[banner.movienameID];

if (details == null) {
  print(" No details found for ID: ${banner.movienameID}");
}

if (image == null) {
  print(" No banner image found for ID: ${banner.movienameID}");
}
                                          return Builder(
                                            builder: (BuildContext context) {
                                               print('AudioContainers length: ${_audioContainers.length}');
                                               print('Banner audiId: ${banner.movienameID}');
                                               print('Banner Image:$image');
                                               print('Details: $details');
                                             
                                              return GestureDetector(
                                                onTap: () async{
                                                  Uint8List? thumbnail = await details?.thumbnailImage;
                                                  Uint8List? bannerthumbnail = await details?.bannerImage;
                                                  if(details != null){
                                                    details.thumbnail = thumbnail;
                                                    details.bannerthumbnail = bannerthumbnail;
                  
                                                  }
                  
                                                   Provider.of<AudioProvider>(context, listen: false)
                                                    .setCurrentlyPlayingSong( 
                                                        details!, 
                                                        _searchResults.cast<AudioDescription>()
                                                    );
                                                 Navigator.push(context, MaterialPageRoute(builder: (context)=> SongPlayerPage(
                                                 musicList: allSongs,
                                                  
                                                  onChange: (newAudio) async{
                                                       Uint8List? newThumbnail = await newAudio.thumbnailImage;
                                                       Uint8List? newBannerThumbnail = await newAudio.bannerImage;
                                                       newAudio.thumbnail = newThumbnail;
                                                       newAudio.bannerthumbnail = newBannerThumbnail;
                                                      Provider.of<AudioProvider>(context,listen: true)
                                          .setCurrentlyPlayingSong(
                                                       newAudio,_searchResults.cast<AudioDescription>(),
                                                        );
                                                  },
                                                  onDislike: (_){}, music: details!,)));
                                                },
                                                child: Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: MemoryImage(image!),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment.topCenter,
                                                            end: Alignment.bottomCenter,
                                                            colors: [
                                                              Colors.transparent,
                                                              Colors.black.withOpacity(0.4),
                                                              Colors.black.withOpacity(0.5), // Stronger blur at bottom
                                                              Colors.black.withOpacity(0.6),
                                                            ],
                                                          ),
                                                        ),
                                                    
                                                      ),
                                                    ),
                                              );
                                               
                                            },
                                          );
                                        }).toList(),
                                      ),
                              ),
                              Positioned(
                                top: 180,
                                left: 0,
                                right: 0,
                                child: Center(
                                child:audiobanners.isNotEmpty ?
                                 DotsIndicator(
                                  dotsCount: audiobanners.length,
                                 position: currentBannerIndex.toDouble(),
                              //     position: currentBannerIndex,
                                  decorator: const DotsDecorator( 
                                    color: Colors.grey,
                                    activeColor: Colors.white,
                                    size: Size(7, 7),
                                    activeSize: Size(8, 8),
                                    spacing: EdgeInsets.all(4),
                                  ),
                                ) : SizedBox.shrink(),
                              ),
                              ),
                            ],
                           ),
                           SizedBox(height: MediaQuery.sizeOf(context).height * 0.03,),
                            _searchController.text.isNotEmpty 
                                        ? Center(
                                            child: Text(
                                              'No audios found',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          )
                                        : ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                                  itemCount: _audioContainers.length,
                                                  itemBuilder: (context, index) {
                                                    final container = _audioContainers[index];
                                                    print('AudioContainer:${container}');
                                                    return
                                                     MusicCategorySection(
                                                      audioContainer: container,
                                                  userId: widget.userId,
                                                  onTap: (audio) {
                                                    Navigator.push(context, MaterialPageRoute(
                                                      builder: (context)=>SongPlayerPage(
                                                        musicList: allSongs,
                                                        music: audio, onChange: (newAudio){
                                                    
                                                      }, onDislike:(audio){handleDislike(audio, context);})));
                                                  },
                                                 );
                                                 },
                                                 ),
                                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.03,),
                                   
                  
                  
                        ],
                      ),
                    ),
                  ),
                ],
              ),
             
            ),
          ),
          
            Align(
              alignment: Alignment.bottomCenter,
              child: Consumer<AudioProvider>(
                              builder: (context, audioProvider, child) {
                                return audioProvider.audioDescriptioncurrently != null
                                    ? CurrentlyPlayingBar(
                                        audioCurrentlyPlaying:
                                            audioProvider.audioDescriptioncurrently,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SongPlayerPage(
                                                  musicList: allSongs,
                                                  music: audioProvider.audioDescriptioncurrently!,                                              
                                                  onChange: (newAudio) {
                                                    audioProvider
                                                        .setCurrentlyPlayingSong(
                                                            newAudio,
                                                            audioProvider
                                                                .audio_playlist);
                                                  },
                                                  onDislike: ((audio) {
                                                    handleDislike(audio, context);
                                                  }),
                                                ),
                                              ));
                                        },
                                      )
                                    : Container();
                              },
                            ),
            ),
        ],
      ),
        ]
               ),
      
    )
   
    );
  }




  Widget _buildMusicCategories() {
    return FutureBuilder<List<AudioContainer>>(
      future: AudioService.fetchAudioContainer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
            'Error: ${snapshot.error}',
            style: TextStyle(color: Colors.white),
          ));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No audios found',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          // final movie = snapshot.data!;
          // final categories = movie
          //     .expand((movie) => movie.categories)
          //     .toSet()
          //     .toList();
          final audioContainer = snapshot.data!;
          
          return ListView.builder(
              itemCount: audioContainer.length,
              itemBuilder: (context, index) {
                final container = audioContainer[index];
                // final containerVideos =
                //     container.video;
                return Column(
                  children: [
                    MusicCategorySection(
                      audioContainer: container,
                      userId: widget.userId,
                      onTap: (audio) {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>SongPlayerPage(music: audio, onChange: (newAudio){
                        
                          }, onDislike:(audio){handleDislike(audio, context);})));
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.02,
                    ),
                  ],
                );
              });
        }
      },
    );
  }
  void handleDislike(AudioDescription audio, BuildContext context) async {
  try {
    // You can add these to your existing state or provider
    final userId = widget.userId;
    
    // Make API call to update dislike status
    final response = await AudioApiService().unlikeAudio(audio.id,userId);
    
    if (response) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Song disliked successfully'),
          backgroundColor: Colors.red,
        ),
      );
      
      // Optionally, you can update the UI or remove the song from the current playlist
      // For example, if using AudioProvider:
      // Provider.of<AudioProvider>(context, listen: false).removeFromPlaylist(audio);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to dislike song'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  } catch (e) {
    // Handle any errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: Something went wrong'),
        backgroundColor: Colors.red,
      ),
    );
    print('Error in handleDislike: $e');
  }
}



  Widget _buildSearchResults() {
    return Container(
      margin: EdgeInsets.only(top: 90),
      child: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final item = _searchResults[index];
          return ListTile(
            title: Text(item is VideoDescription ? item.videoTitle : item is AudioDescription ? item.audioTitle : 'unknown',
                style: TextStyle(color: Colors.white)),
            subtitle: Text(item is VideoDescription ? 'Movie' : item is AudioDescription ? 'Song' : 'Unknown',
                style: TextStyle(color: Colors.white70)),
            onTap: () {
              if (item is VideoDescription) {
                if(_allVideos.isNotEmpty){
                final movieIndex = _allVideos.indexWhere((video)=> video.id == item.id);
                print('Movie index:$movieIndex');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MoviesPlayerPage(
                      videoDescriptions: _allVideos,
                      categoryId: (item.categoryList.isNotEmpty && index < item.categoryList.length) ? item.categoryList[index] : 0,
                      initialIndex: movieIndex)
                  ),
                );
                }
                }
  
                else {
                  if (item is AudioDescription) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SongPlayerPage(
                                music: item,
                                  musicList: allSongs,
                                  onChange: (newAudio) {
                                     Provider.of<AudioProvider>(context,listen: true)
                                    .setCurrentlyPlayingSong(
                                                  newAudio,_searchResults.cast<AudioDescription>(),
                                                  );
                                  },
                                  onDislike: (p0) {},
                                )));
                  }
              }
            },
          );
        },
      ),
    );
  }
}


 
