import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ott_project/components/library/audio_playlist.dart';
import 'package:ott_project/service/playlist_service.dart';
import 'package:ott_project/tv_ui/FocusManager/musicplayer_focusmanager.dart';


class PlaylistOptionsPopup extends StatefulWidget {
  final int currentSongId;
  final int? currentUserId;
  final PlaylistService playlistService;
  final MusicPlayerFocusManager focusManager;
  final Function showCreateDialog;
  final VoidCallback onClose;

  const PlaylistOptionsPopup({
    Key? key,
    required this.currentSongId,
    required this.currentUserId,
    required this.playlistService,
    required this.focusManager,
    required this.showCreateDialog,
    required this.onClose,
  }) : super(key: key);

  @override
  _PlaylistOptionsPopupState createState() => _PlaylistOptionsPopupState();
}

class _PlaylistOptionsPopupState extends State<PlaylistOptionsPopup> {
  List<AudioPlaylist>? playlists;
  bool isLoading = true;
  late FocusNode _listFocusNode;

  @override
  void initState() {
    super.initState();
    _listFocusNode = FocusNode();
    _loadPlaylists();
    
    // Add listener to force rebuild when focus changes
    widget.focusManager.onStateChanged = () {
      if (mounted) setState(() {});
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFocus();
    });

    widget.focusManager.onSelectedPlaylistIndex = (int index) {
      if (index >= 0 && index < (playlists?.length ?? 0)) {
        final selectedPlaylist = playlists![index];
        final isAlreadyInPlaylist = selectedPlaylist.audioIds.contains(widget.currentSongId);

        if (isAlreadyInPlaylist) {
          Fluttertoast.showToast(
            msg: 'Song already in playlist "${selectedPlaylist.title}"',
            backgroundColor: Colors.orange,
          );
        } else {
          widget.playlistService
              .addAudiosToPlaylist(selectedPlaylist.id, widget.currentSongId)
              .then((_) {
            Fluttertoast.showToast(
              msg: 'Song added to "${selectedPlaylist.title}"',
              backgroundColor: Colors.green,
            );
            _loadPlaylists();
          });
        }
      }
    };
    
    widget.focusManager.onCreatePlayListSelect = () {
      widget.focusManager.playlistFocusNode.unfocus();
      widget.focusManager.openDialog();
      widget.showCreateDialog();
    };
  }

  @override
  void dispose() {
    _listFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPlaylists() async {
    try {
      final fetchedPlaylists = await widget.playlistService.getPlaylistsByUserId(widget.currentUserId ?? 0);
      setState(() {
        playlists = fetchedPlaylists;
        widget.focusManager.totalPlaylists = fetchedPlaylists.length;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        playlists = [];
        widget.focusManager.totalPlaylists = 0;
        isLoading = false;
      });
    }
  }

  void _initializeFocus() {
    if ((playlists?.isNotEmpty ?? false)) {
      widget.focusManager.updateFocusState(
        isPlaylistItem: true,
        isCreatePlaylist: false,
        isCancelFocused: false,
      );
      widget.focusManager.selectedPlaylistIndex = 0;
    } else {
      widget.focusManager.updateFocusState(
        isPlaylistItem: false,
        isCreatePlaylist: true,
        isCancelFocused: false,
      );
    }
    _listFocusNode.requestFocus();
  }

  void _handlePlaylistTap(AudioPlaylist playlist) async {
    if (widget.currentUserId == null) {
      Fluttertoast.showToast(
        msg: 'Please log in to add songs to playlists.',
        backgroundColor: Colors.red,
      );
      return;
    }

    final alreadyInPlaylist = playlist.audioIds.contains(widget.currentSongId);

    if (alreadyInPlaylist) {
      Fluttertoast.showToast(
        msg: 'Song already in playlist "${playlist.title}"',
        backgroundColor: Colors.orange,
      );
    } else {
      await widget.playlistService.addAudiosToPlaylist(playlist.id, widget.currentSongId);
      Fluttertoast.showToast(
        msg: 'Song added to "${playlist.title}"',
        backgroundColor: Colors.green,
      );
      _loadPlaylists();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: widget.focusManager.playlistFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          widget.focusManager.handleKeyEvent(event);
          setState(() {}); // Force rebuild on key press
        }
      },
      autofocus: true,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF070708),
                  Color(0xFF1D1B53),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add to Playlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                Expanded(
                  child: Focus(
                    focusNode: _listFocusNode,
                    child: Builder(
                      builder: (context) {
                        if (isLoading) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (playlists == null || playlists!.isEmpty) {
                          return Center(
                            child: Text(
                              'No playlists found',
                              style: TextStyle(color: Colors.white54),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: playlists!.length,
                          itemBuilder: (context, index) {
                            final playlist = playlists![index];
                            final isInPlaylist = playlist.audioIds.contains(widget.currentSongId);
                            final isFocused = widget.focusManager.isPlaylistItemFocused &&
                                widget.focusManager.selectedPlaylistIndex == index;

                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: isFocused ? Color.fromARGB(255, 143, 228, 0) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.playlist_play,
                                  color: isInPlaylist ? Colors.green : Colors.white,
                                ),
                                title: Text(
                                  playlist.title,
                                  style: TextStyle(
                                    color: isFocused ? Colors.black : Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                onTap: () => _handlePlaylistTap(playlist),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Create New Playlist Button
                    Focus(
                      onFocusChange: (hasFocus) {
                        if (hasFocus) {
                          widget.focusManager.updateFocusState(
                            isPlaylistItem: false,
                            isCreatePlaylist: true,
                            isCancelFocused: false,
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.focusManager.isNewPlaylistbuttonFocused 
                            ? Color.fromARGB(255, 143, 228, 0)
                            : Color.fromARGB(255, 193, 39, 45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          onPressed: () {
                            widget.focusManager.onCreatePlayListSelect?.call();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Create New',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Cancel Button
                    Focus(
                      onFocusChange: (hasFocus) {
                        if (hasFocus) {
                          widget.focusManager.updateFocusState(
                            isPlaylistItem: false,
                            isCreatePlaylist: false,
                            isCancelFocused: true,
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.focusManager.isCancelFocused 
                            ? Color.fromARGB(255, 143, 228, 0)
                            : Colors.grey[800],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          onPressed: widget.onClose,
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: widget.focusManager.isCancelFocused 
                                ? Colors.black 
                                : Colors.white,
                            ),
                          ),
                        ),
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