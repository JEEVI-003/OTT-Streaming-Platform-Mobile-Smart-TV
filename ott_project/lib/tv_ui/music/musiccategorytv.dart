import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ott_project/components/music_folder/audio_container.dart';

import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/music/audiocardtv.dart';
import 'package:ott_project/tv_ui/music/musicplayertv.dart'; // Assuming you have a player page like TVMoviesPlayerPage
import 'package:ott_project/tv_ui/components/tvlayout.dart';

class TVCategoryBasedSong extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final List<AudioDescription> audioDescriptions;

  const TVCategoryBasedSong({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.audioDescriptions,
  });

  @override
  State<TVCategoryBasedSong> createState() => _TVCategoryBasedSongState();
}

class _TVCategoryBasedSongState extends State<TVCategoryBasedSong> {
  int selectedIndex = 0;
  final FocusNode _gridFocusNode = FocusNode();
  int currentFocusedIndex = 0;

  static const int columns = 4; // You can adjust based on screen size if needed

  @override
  void initState() {
    super.initState();
    FocusManagerService.previousPage = FocusManagerService.currentPage;
    FocusManagerService.currentPage = 4;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManagerService.unfocusAll();
      _gridFocusNode.requestFocus();
    });

    FocusManagerService.gridFocusNode = _gridFocusNode;
  }

  @override
  void dispose() {
    FocusManagerService.currentPage = FocusManagerService.previousPage;
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      int maxIndex = widget.audioDescriptions.length - 1;

      setState(() {
        if (key == LogicalKeyboardKey.arrowRight) {
          if (currentFocusedIndex < maxIndex) {
            currentFocusedIndex++;
          }
        } else if (key == LogicalKeyboardKey.arrowLeft) {
          if (currentFocusedIndex > 0) {
            currentFocusedIndex--;
          } else {
           
            FocusManagerService.setSidebarFocus();
             currentFocusedIndex = -1;
           // _gridFocusNode.unfocus();
          }
        } else if (key == LogicalKeyboardKey.arrowDown) {
          if (currentFocusedIndex + columns <= maxIndex) {
            currentFocusedIndex += columns;
          }
        } else if (key == LogicalKeyboardKey.arrowUp) {
          if (currentFocusedIndex - columns >= 0) {
            currentFocusedIndex -= columns;
          }
        } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
         _playSelectedSong();
        }
      });
    }
  }

  void _playSelectedSong() {
   // final selectedSong = widget.audioDescriptions[currentFocusedIndex];

    final previousFocusState = {
      'isSidebarFocused': FocusManagerService.isSidebarFocused,
      'selectedSidebarIndex': FocusManagerService.selectedSidebarIndex,
      'currentPage': FocusManagerService.currentPage,
      'gridFocusIndex': currentFocusedIndex,
    };

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => TVMusicPlayerPage( // You should have this page
          audioDescriptions: widget.audioDescriptions,
          initialIndex: currentFocusedIndex, categoryId:widget.categoryId,
          categoryName: widget.categoryName,
        ),
      ),
    ).then((_) {
      FocusManagerService.currentPage = 4;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _gridFocusNode.requestFocus();
        setState(() {
          currentFocusedIndex = (previousFocusState['gridFocusIndex'] as int?) ?? 0;
        });
      });
    });
  }

  void _onSidebarSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TVLayout(
      
         selectedIndex: selectedIndex,
    onSidebarSelected: _onSidebarSelected,

      child: KeyboardListener(
        focusNode: _gridFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Text(
                    '${widget.categoryName} Songs',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
      
            // GridView
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: widget.audioDescriptions.length,
                  itemBuilder: (context, index) {
                    final song = widget.audioDescriptions[index];
                    final isFocused = index == currentFocusedIndex;
      
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: isFocused ? const EdgeInsets.all(2.0) : EdgeInsets.zero,
                      decoration: BoxDecoration(
                        border: isFocused ? Border.all(color: Colors.white, width: 2.0) : null,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: TVAudioCard(
                        audio: song,
                        initialIndex: index,
                        onTap: () {
                          // _playSelectedSong();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
