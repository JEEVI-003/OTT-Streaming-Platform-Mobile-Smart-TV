import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';

class MusicPlayerFocusManager {
  final FocusNode globalFocusNode = FocusNode(debugLabel: 'musicPlayerFocusNode');
  final FocusNode playlistFocusNode = FocusNode(debugLabel: 'musicPlaylistFocusNode');

  bool isLikeButtonFocused = true;
  bool isaddPlaylistButtonFocused = false;
  bool isSliderFocused = false;
  bool isPlayButtonFocused = false;
  bool isSidebarFocused = false;
  bool isMusicListFocused = false;
  bool isPreviousSongFocused = false;
  bool isNextSongFocused = false;
  bool isShuffleFocused = false;
  bool isRepeatFocus = false;

  int selectedMusicIndex = 0;
  int totalSongs = 0;

  bool isNewPlaylistbuttonFocused = false;
  bool isCancelFocused = false;
  bool isPlaylistItemFocused = false;
  int selectedPlaylistIndex = 0;
  int totalPlaylists = 0;

  final Function()? onLikeSelect;
  final Function()? onPlaylistSelect;
  final Function()? onSliderSelect;
  final VoidCallback onPlayButtonSelect;
  final Function(int)? onMusicListSelect;
  final Function()? onShuffleSelect;
  final Function()? onRepeatSelect;
  final Function()? onNextSongSelect;
  final Function()? onPreviousSongSelect;
  Function()? onCreatePlayListSelect;
  Function(int index)? onSelectedPlaylistIndex;
  final Function()? onBack;

  VoidCallback? onStateChanged;

  MusicPlayerFocusManager({
    required this.totalSongs,
    this.onLikeSelect,
    this.onPlaylistSelect,
    this.onSliderSelect,
    required this.onPlayButtonSelect,
    this.onMusicListSelect,
    this.onShuffleSelect,
    this.onRepeatSelect,
    this.onNextSongSelect,
    this.onPreviousSongSelect,
    this.onCreatePlayListSelect,
    this.onBack,
    this.onSelectedPlaylistIndex,
  });

  bool _isDialogOpen = false;
  bool get isDialogOpen => _isDialogOpen;

  void openDialog() {
    _isDialogOpen = true;
    globalFocusNode.unfocus();
  }

  void closeDialog() {
    _isDialogOpen = false;
    globalFocusNode.requestFocus();
  }

  void setFocusToPlaylist() {
    updateFocusState(isPlaylistItem: false, isCreatePlaylist: true, isCancelFocused: false);
    selectedPlaylistIndex = 0;
    globalFocusNode.unfocus();
    playlistFocusNode.requestFocus();
    onStateChanged?.call();
    if (totalPlaylists > 0) {
      Future.delayed(const Duration(milliseconds: 50), () {
        updateFocusState(isPlaylistItem: true, isCreatePlaylist: false, isCancelFocused: false);
      });
    }
  }

  void handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    debugPrint('[MusicFocus] Key: ${event.logicalKey.keyLabel}');

    if (isLikeButtonFocused) {
      handleLikeKeyEvent(event);
    } else if (isaddPlaylistButtonFocused) {
      handlePlaylistKeyEvent(event);
    } else if (isSliderFocused || isPlayButtonFocused ||
               isNextSongFocused || isPreviousSongFocused ||
               isRepeatFocus || isShuffleFocused) {
      handlePlayerControlsKeyEvent(event);
    } else if (isMusicListFocused) {
      handleMusicListKeyEvent(event);
    } else if (isPlaylistItemFocused || isNewPlaylistbuttonFocused || isCancelFocused) {
      handlePlaylistDialogKeyEvent(event);
    }
  }

  void handleLikeKeyEvent(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      updateFocusState(isLikeButton: false, isPlaylistButton: true);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      FocusManagerService.setSidebarFocus();
      updateFocusState(isLikeButton: false, isSidebar: true);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      updateFocusState(isLikeButton: false, isSlider: true);
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      onLikeSelect?.call();
    }
  }

  void handlePlaylistKeyEvent(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      updateFocusState(isPlaylistButton: false, isMusicList: true);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      updateFocusState(isPlaylistButton: false, isLikeButton: true);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      updateFocusState(isPlaylistButton: false, isSlider: true);
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      onPlaylistSelect?.call();
    }
  }

  void handlePlayerControlsKeyEvent(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (isPlayButtonFocused) {
        updateFocusState(isPlayButton: false, isSlider: true);
      } else if (isSliderFocused) {
        updateFocusState(isSlider: false, isLikeButton: true);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (isPlayButtonFocused) {
        updateFocusState(isPlayButton: false, isPreviousSongFocused: true);
      } else if (isPreviousSongFocused) {
        updateFocusState(isPreviousSongFocused: false, isShuffleFocused: true);
      } else if (isShuffleFocused) {
        updateFocusState(isShuffleFocused: false, isRepeatFocus: true);
      } else if (isNextSongFocused) {
        updateFocusState(isNextSongFocused: false, isPlayButton: true);
      } else if (isRepeatFocus) {
        updateFocusState(isRepeatFocus: false, isNextSongFocused: true);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (isPlayButtonFocused) {
        updateFocusState(isPlayButton: false, isNextSongFocused: true);
      } else if (isShuffleFocused) {
        updateFocusState(isShuffleFocused: false, isPreviousSongFocused: true);
      } else if (isPreviousSongFocused) {
        updateFocusState(isPreviousSongFocused: false, isPlayButton: true);
      } else if (isNextSongFocused) {
        updateFocusState(isNextSongFocused: false, isRepeatFocus: true);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      updateFocusState(isSlider: false, isPlayButton: true);
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      if (isShuffleFocused) {
        onShuffleSelect?.call();
      } else if (isPreviousSongFocused) {
        onPreviousSongSelect?.call();
      } else if (isNextSongFocused) {
        onNextSongSelect?.call();
      } else if (isRepeatFocus) {
        onRepeatSelect?.call();
      } else if (isSliderFocused) {
        onSliderSelect?.call();
      } else if (isPlayButtonFocused) {
        onPlayButtonSelect();
      }
    }
  }

  void handleMusicListKeyEvent(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (selectedMusicIndex > 0) selectedMusicIndex--;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (selectedMusicIndex < totalSongs - 1) selectedMusicIndex++;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      updateFocusState(isMusicList: false, isPlaylistButton: true);
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      onMusicListSelect?.call(selectedMusicIndex);
    }
  }

  void handlePlaylistDialogKeyEvent(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (isPlaylistItemFocused && selectedPlaylistIndex < totalPlaylists - 1) {
        selectedPlaylistIndex++;
      } else if (isPlaylistItemFocused) {
        updateFocusState(isPlaylistItem: false, isCreatePlaylist: true, isCancelFocused: false);
      } else if (isNewPlaylistbuttonFocused) {
        updateFocusState(isPlaylistItem: false, isCreatePlaylist: false, isCancelFocused: true);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (isPlaylistItemFocused && selectedPlaylistIndex > 0) {
        selectedPlaylistIndex--;
      } else if (isNewPlaylistbuttonFocused || isCancelFocused) {
        if (totalPlaylists > 0) {
          updateFocusState(isPlaylistItem: true, isCreatePlaylist: false, isCancelFocused: false);
          selectedPlaylistIndex = totalPlaylists - 1;
        }
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (isPlaylistItemFocused) {
        if (selectedPlaylistIndex == totalPlaylists - 1) {
          updateFocusState(isPlaylistItem: false, isCreatePlaylist: true, isCancelFocused: false);
        } else {
          selectedPlaylistIndex++;
        }
      } else if (isNewPlaylistbuttonFocused) {
        updateFocusState(isPlaylistItem: false, isCreatePlaylist: false, isCancelFocused: true);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (isPlaylistItemFocused && selectedPlaylistIndex > 0) {
        selectedPlaylistIndex--;
      } else if (isCancelFocused) {
        updateFocusState(isPlaylistItem: false, isCreatePlaylist: true, isCancelFocused: false);
      } else if (isNewPlaylistbuttonFocused && totalPlaylists > 0) {
        updateFocusState(isPlaylistItem: true, isCreatePlaylist: false, isCancelFocused: false);
        selectedPlaylistIndex = 0;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      if (isPlaylistItemFocused) {
        onSelectedPlaylistIndex?.call(selectedPlaylistIndex);
      } else if (isNewPlaylistbuttonFocused) {
        onCreatePlayListSelect?.call();
      } else if (isCancelFocused) {
        onBack?.call();
        updateFocusState(isPlaylistButton: true);
      }
    }
  }

  void updateFocusState({
    bool isLikeButton = false,
    bool isPlaylistButton = false,
    bool isSlider = false,
    bool isPlayButton = false,
    bool isSidebar = false,
    bool isMusicList = false,
    bool isShuffleFocused = false,
    bool isPreviousSongFocused = false,
    bool isNextSongFocused = false,
    bool isRepeatFocus = false,
    bool isPlaylistItem = false,
    bool isCreatePlaylist = false,
    bool isCancelFocused = false,
  }) {
    isLikeButtonFocused = isLikeButton;
    isaddPlaylistButtonFocused = isPlaylistButton;
    isSliderFocused = isSlider;
    isPlayButtonFocused = isPlayButton;
    this.isSidebarFocused = isSidebar;
    isMusicListFocused = isMusicList;
    this.isShuffleFocused = isShuffleFocused;
    this.isPreviousSongFocused = isPreviousSongFocused;
    this.isNextSongFocused = isNextSongFocused;
    this.isRepeatFocus = isRepeatFocus;
    isPlaylistItemFocused = isPlaylistItem;
    isNewPlaylistbuttonFocused = isCreatePlaylist;
    this.isCancelFocused = isCancelFocused;
    onStateChanged?.call();
  }
}
