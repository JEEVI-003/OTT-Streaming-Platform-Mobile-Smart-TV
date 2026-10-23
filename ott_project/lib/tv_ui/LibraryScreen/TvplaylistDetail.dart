import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ott_project/components/library/audio_playlist.dart';
import 'package:ott_project/components/library/likedSongsDTO.dart';
import 'package:ott_project/components/library/playlistDTO.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';
import 'package:ott_project/components/music_folder/audio_provider.dart';
import 'package:ott_project/service/audio_api_service.dart';
import 'package:ott_project/service/playlist_service.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/components/tvlayout.dart';
import 'package:provider/provider.dart';
import '../../service/service.dart';

class TVPlaylistDetailsPage extends StatefulWidget {
  final AudioPlaylist playlist;
  final int playlistId;

  const TVPlaylistDetailsPage(
      {required this.playlistId, required this.playlist, super.key});

  @override
  State<TVPlaylistDetailsPage> createState() => _TVPlaylistDetailsPageState();
}

class _TVPlaylistDetailsPageState extends State<TVPlaylistDetailsPage> {
  final FocusNode _listFocusNode = FocusNode();
  final List<FocusNode> _songFocusNodes = [];
  final List<FocusNode> _menuButtonFocusNodes = [];
  int _focusedSongIndex = 0;
  bool _isMenuOpen = false;
  int _menuSelectedOption = 0;
  bool _isMenuButtonFocused = false;

  @override
  void initState() {
    super.initState();
    _loadPlaylistDetails();
    _listFocusNode.addListener(_onListFocusChanged);
  }

  @override
  void dispose() {
    _listFocusNode.removeListener(_onListFocusChanged);
    _listFocusNode.dispose();
    for (var node in _songFocusNodes) {
      node.dispose();
    }
    for (var node in _menuButtonFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onListFocusChanged() {
    if (_listFocusNode.hasFocus && _songFocusNodes.isNotEmpty) {
      _songFocusNodes[_focusedSongIndex].requestFocus();
    }
  }

  List<PlaylistDTO> _playlists = [];
  bool _isLoading = true;
  String? _error;
  Map<int, Uint8List> audioImages = {};
  int selectedIndex = FocusManagerService.selectedSidebarIndex;

  void _onSidebarSelected(int index) {
    setState(() {
      selectedIndex = index;
      FocusManagerService.selectedSidebarIndex = index;
    });
  }

  Future<void> _loadPlaylistDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final List<PlaylistDTO> playlistData =
          await PlaylistService().getPlaylistWithAudioDetails(widget.playlistId);

      if (playlistData.isNotEmpty) {
        await Future.wait(playlistData.map((playlist) async {
          await _loadAudioImages(playlist.audioDetails);
          return playlist;
        }));

        // Initialize focus nodes
        _songFocusNodes.clear();
        _menuButtonFocusNodes.clear();
        for (var i = 0; i < playlistData.first.audioDetails.length; i++) {
          _songFocusNodes.add(FocusNode());
          _menuButtonFocusNodes.add(FocusNode());
        }

        setState(() {
          _playlists = playlistData;
          _isLoading = false;
        });

        // Focus the first song after loading
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_songFocusNodes.isNotEmpty) {
            _songFocusNodes[0].requestFocus();
          }
        });
      } else {
        setState(() {
          _error = 'Playlist not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load playlist: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAudioImages(List<LikedsongsDTO> audioDetails) async {
    for (var audio in audioDetails) {
      try {
        final audioDesc = await AudioApiService().fetchAudioDetails(audio.audioId);
        final image = await audioDesc.thumbnailImage;
        if (image != null) {
          setState(() {
            audioImages[audio.audioId] = image;
          });
        }
      } catch (e) {
        print('Error loading image for audio ${audio.audioId}: $e');
      }
    }
  }

  Widget buildAudioImage(LikedsongsDTO audio) {
    final audioImage = audioImages[audio.audioId];
    if (audioImage != null) {
      return Image.memory(
        audioImage,
        height: 50,
        width: 50,
        fit: BoxFit.cover,
      );
    }
    return Container(
      height: 50,
      width: 50,
      child: Icon(Icons.music_note_rounded, color: Colors.white),
    );
  }

  
  void _closeMenu() {
    setState(() {
      _isMenuOpen = false;
      _isMenuButtonFocused = false;
      _songFocusNodes[_focusedSongIndex].requestFocus();
    });
  }

  

  Future<void> _removeAudioFromPlaylist(int playlistId, int audioId) async {
    try {
      await PlaylistService().removeAudioFromPlaylist(playlistId, audioId);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio removed from this playlist')));
      await _loadPlaylistDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove audio: ${e.toString()}')));
    }
  }

  void _showMoveDialog(BuildContext context, int currentPlaylistId, int audioId) async {
  final userId = await Service().getLoggedInUserId();
  final playlists = await PlaylistService().getPlaylistsByUserId(userId!);
  int selectedPlaylistIndex = 0; // Start with the first item

  List<FocusNode> playlistFocusNodes = List.generate(
    playlists.length,
    (_) => FocusNode(),
  );

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return KeyboardListener(
            focusNode: FocusNode()..requestFocus(),
            autofocus: true,
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  if (selectedPlaylistIndex < playlists.length - 1) {
                    setState(() {
                      selectedPlaylistIndex++;
                      playlistFocusNodes[selectedPlaylistIndex].requestFocus();
                    });
                  }
                } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  if (selectedPlaylistIndex > 0) {
                    setState(() {
                      selectedPlaylistIndex--;
                      playlistFocusNodes[selectedPlaylistIndex].requestFocus();
                    });
                  }
                } else if (event.logicalKey == LogicalKeyboardKey.select ||
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  Navigator.of(context).pop(playlists[selectedPlaylistIndex].id);
                } else if (event.logicalKey == LogicalKeyboardKey.escape ||
                    event.logicalKey == LogicalKeyboardKey.goBack) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: AlertDialog(
                backgroundColor: Color.fromARGB(69, 178, 174, 174),
                title: Text('Move to Playlist', style: TextStyle(color: Colors.white)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < playlists.length; i++)
                      Focus(
                        focusNode: playlistFocusNodes[i],
                        child: GestureDetector(
                          // onTap: () {
                          //   Navigator.of(context).pop(playlists[i].id);
                          // },
                          child: Container(
                            color: selectedPlaylistIndex == i
                                ? Colors.blue
                                : Colors.transparent,
                            child: ListTile(
                              leading: Icon(Icons.playlist_play_rounded,
                                  color: Colors.white),
                              title: Text(playlists[i].title,
                                  style: TextStyle(color: Colors.white)),
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
    },
  ).then((selectedPlaylistId) async {
    if (selectedPlaylistId != null) {
      await PlaylistService().moveAudioToPlaylist(
          currentPlaylistId, audioId, selectedPlaylistId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Song moved successfully')),
      );
      _loadPlaylistDetails();
    }
  });
}

  void _playSong(int index) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      final selectedAudioId = _playlists.first.audioDetails[index].audioId;
      final AudioDescription selectedAudio = 
          await AudioApiService().fetchAudioDetails(selectedAudioId);
      
      await selectedAudio.fetchImage();

      // final audioProvider = Provider.of<AudioProvider>(context, listen: false);
      // audioProvider.updateCurrentlyPlayingSong(selectedAudio);
      // final playlistAudios = audioProvider.convertPlaylistToAudioDescriptions(
      //     _playlists.first.audioDetails);
      // await audioProvider.setCurrentlyPlayingSong(selectedAudio, playlistAudios);

      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Navigate to music player screen
      if (context.mounted) {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => TVMusicPlayerScreen(
        //       audio: selectedAudio,
        //       playlist: _playlists.first.audioDetails,
        //     ),
        //   ),
        // );
      }
    } catch (e) {
      print("Error fetching audio details: $e");
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (_isMenuOpen) return;

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        // Move to next song
        if (_focusedSongIndex < _playlists.first.audioDetails.length - 1) {
          setState(() {
            _focusedSongIndex++;
            _songFocusNodes[_focusedSongIndex].requestFocus();
            _isMenuButtonFocused = false;
          });
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        // Move to previous song
        if (_focusedSongIndex > 0) {
          setState(() {
            _focusedSongIndex--;
            _songFocusNodes[_focusedSongIndex].requestFocus();
            _isMenuButtonFocused = false;
          });
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        // Focus menu button
        if (!_isMenuButtonFocused) {
          setState(() {
            _isMenuButtonFocused = true;
            _menuButtonFocusNodes[_focusedSongIndex].requestFocus();
          });
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        // Unfocus menu button
        if (_isMenuButtonFocused) {
          setState(() {
            _isMenuButtonFocused = false;
            _songFocusNodes[_focusedSongIndex].requestFocus();
          });
        }
      } else if (event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        if (_isMenuButtonFocused) {
          _isMenuOpen=true;
          // _openMenu(_focusedSongIndex);
          _showMenuPopup(_focusedSongIndex);

        } else {
          _playSong(_focusedSongIndex);
        }
      }
      //  else if (event.logicalKey == LogicalKeyboardKey.goBack ||
      //     event.logicalKey == LogicalKeyboardKey.escape) {
      //   Navigator.of(context).pop();
      // }
    }
  }

void _showMenuPopup(int index) {
  setState(() {
    _isMenuOpen = true;
    _menuSelectedOption = 0;
  });

  final audio = _playlists.first.audioDetails[index];
  final playlistId = widget.playlistId;

  final FocusNode dialogFocusNode = FocusNode();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return KeyboardListener(
          focusNode: dialogFocusNode,
          autofocus: true,
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                setState(() {
                  _menuSelectedOption = (_menuSelectedOption + 1) % 2;
                });
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                setState(() {
                  _menuSelectedOption = (_menuSelectedOption - 1 + 2) % 2;
                });
              } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                         event.logicalKey == LogicalKeyboardKey.select) {
                Navigator.of(context).pop();
                if (_menuSelectedOption == 0) {
                  _showMoveDialog(context, playlistId, audio.audioId);
                } else {
                  _removeAudioFromPlaylist(playlistId, audio.audioId);
                }
              } 
              // else if (event.logicalKey == LogicalKeyboardKey.goBack ||
              //            event.logicalKey == LogicalKeyboardKey.escape) {
              //   Navigator.of(context).pop();
              // }
            }
          },
          child: AlertDialog(
            backgroundColor: const Color.fromARGB(89, 158, 158, 158),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuOption("Move to another Playlist", 0),
                _buildMenuOption("Remove from this Playlist", 1),
              ],
            ),
          ),
        );
      });
    },
  ).then((_) {
    _closeMenu();
  });
}

Widget _buildMenuOption(String text, int optionIndex) {
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: _menuSelectedOption == optionIndex ? Colors.blue : Colors.transparent,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(text, style: TextStyle(color: Colors.white)),
  );
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return TVLayout(
      onSidebarSelected: _onSidebarSelected,
      selectedIndex: selectedIndex,
      child: KeyboardListener(
        focusNode: _listFocusNode,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF070708),
                  Color(0xFF1D1B53),
                ],
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(padding: EdgeInsets.only(top: 50)),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _playlists.first.title,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                    Expanded(
                      child: _playlists.first.audioDetails.isEmpty
                          ? Center(
                              child: _playlists.isEmpty
                                  ? CircularProgressIndicator()
                                  : Text(
                                      'No songs in this playlist',
                                      style: TextStyle(color: Colors.white),
                                    ))
                          : ListView.builder(
                              itemCount: _playlists.first.audioDetails.length,
                              itemBuilder: (context, index) {
                                final audio =
                                    _playlists.first.audioDetails[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Focus(
                                    focusNode: _songFocusNodes[index],
                                    onFocusChange: (hasFocus) {
                                      if (hasFocus) {
                                        setState(() {
                                          _focusedSongIndex = index;
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _songFocusNodes[index].hasFocus
                                            ? Colors.white.withOpacity(0.2)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: buildAudioImage(audio),
                                        ),
                                        title: Text(
                                          audio.audioTitle,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        trailing: Focus(
                                          focusNode: _menuButtonFocusNodes[index],
                                        
                                          child: IconButton(
                                            onPressed: (){},
                                           //  => _openMenu(index),
                                            icon: Icon(Icons.more_vert_rounded,
                                                color: _menuButtonFocusNodes[index]
                                                        .hasFocus
                                                    ? Colors.blue
                                                    : Colors.white),
                                          ),
                                        ),
                                        onTap: () => _playSong(index),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
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