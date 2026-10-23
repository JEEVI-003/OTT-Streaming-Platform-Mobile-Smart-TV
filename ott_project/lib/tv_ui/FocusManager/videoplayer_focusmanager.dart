import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';

class VideoFocusManager {
  // FIX: This FocusNode is owned by VideoFocusManager but it must NOT be
  // disposed here — it is disposed by the page that created this manager
  // (TVMoviesPlayerPage) in its own dispose() method. Previously the node
  // was disposed in _handleBackNavigation() while the widget was still alive,
  // causing "use after dispose" crashes and silently dropping all future key
  // events.
  final FocusNode _focusNode = FocusNode(debugLabel: 'videoPlayerFocusNode');
  final List<FocusNode> _settingsFocusNodes =
      List.generate(2, (index) => FocusNode());

  final VoidCallback onUserInteraction;
  final VoidCallback onPlayPause;
  final VoidCallback onFullScreen;
  final VoidCallback onToggleSettings;
  final VoidCallback onPlaybackSpeedSelected;
  final Function(double) onChangePlaybackSpeed;
  final VoidCallback onPlayMovie;
  final VoidCallback onAddToWatchLater;
  final Function(bool) onSeek;
  final VoidCallback onBack;
  final ScrollController scrollController = ScrollController();

  int _focusIndex = 4;
  bool _isSettingsOpen = false;
  bool _isSubMenuOpen = false;
  int _settingsIndex = 0;
  int _subMenuIndex = 0;

  final List<double> _playbackSpeeds = [
    0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0
  ];
  final bool Function() isFullScreen;
  final bool Function() isMoviePlaying;

  VideoFocusManager({
    required this.onSeek,
    required this.onUserInteraction,
    required this.onPlayPause,
    required this.onFullScreen,
    required this.onToggleSettings,
    required this.onPlaybackSpeedSelected,
    required this.onChangePlaybackSpeed,
    required this.onPlayMovie,
    required this.onAddToWatchLater,
    required this.isFullScreen,
    required this.isMoviePlaying,
    required this.onBack,
  });

  FocusNode get focusNode => _focusNode;
  FocusNode get settingsFocusNode => _settingsFocusNodes[_settingsIndex];

  void resetFocus() {
    _focusIndex = 4;
    _isSettingsOpen = false;
    _isSubMenuOpen = false;
    _settingsIndex = 0;
    _subMenuIndex = 0;
  }

  void requestInitialFocus({int index = 4}) {
    _focusIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    debugPrint('[VideoFocus] Initial focus index: $index');
  }

  // FIX: ensureFocus uses a post-frame callback to avoid requesting focus
  // mid-build (which can cause "setState called during build" assertions).
  void ensureFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_focusNode.hasFocus) _focusNode.requestFocus();
    });
  }

  void handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    onUserInteraction();

    if (_isSubMenuOpen) {
      _handleSubMenuNavigation(event);
    } else if (_isSettingsOpen) {
      _handleSettingsNavigation(event);
    } else {
      _handleMainControlsNavigation(event);
    }
  }

  void _handleMainControlsNavigation(KeyEvent event) {
    debugPrint(
        '[VideoFocus] Key: ${event.logicalKey.keyLabel}, focusIndex: $_focusIndex');

    // Back / Escape → always invoke onBack callback
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.goBack ||
        event.logicalKey == LogicalKeyboardKey.browserBack) {
      onBack();
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_focusIndex == 0) {
        _focusIndex = 1;
      } else if ((_focusIndex == 4 || _focusIndex == 5) &&
          !isMoviePlaying()) {
        _scrollUp();
      } else if (_focusIndex == 4 || _focusIndex == 5) {
        _focusIndex = 0;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_focusIndex == 1 ||
          _focusIndex == 2 ||
          _focusIndex == 3) {
        _focusIndex = 0;
      } else if (_focusIndex == 0) {
        if (!isFullScreen()) _focusIndex = 4;
      } else if (_focusIndex == 4 || _focusIndex == 5) {
        _scrollDown();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_focusIndex == 1) {
        _focusIndex = 2;
      } else if (_focusIndex == 2) {
        _focusIndex = 3;
      } else if (_focusIndex == 0) {
        onSeek(true);
      } else if (_focusIndex == 4) {
        _focusIndex = 5;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_focusIndex == 0) {
        onSeek(false);
      } else if (_focusIndex == 2) {
        _focusIndex = 1;
      } else if (_focusIndex == 3) {
        _focusIndex = 2;
      } else if (_focusIndex == 5) {
        _focusIndex = 4;
      } else if (_focusIndex == 4) {
        // FIX: Instead of calling FocusManagerService.setSidebarFocus() which
        // steals focus back to the main page while the player is still open,
        // we invoke onBack() so the page handles the navigation cleanly.
        // The old code set _focusIndex = -1 and re-routed focus to the sidebar
        // without popping the player, leaving the UI in a broken state.
        onBack();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      if (_focusIndex == 1) {
        onPlayPause();
      } else if (_focusIndex == 2) {
        onFullScreen();
      } else if (_focusIndex == 3) {
        _isSettingsOpen = true;
        _settingsIndex = 0;
        onToggleSettings();
        Future.delayed(const Duration(milliseconds: 100), () {
          _settingsFocusNodes[0].requestFocus();
        });
      } else if (_focusIndex == 4) {
        onPlayMovie();
        _focusIndex = 0;
      } else if (_focusIndex == 5) {
        onAddToWatchLater();
      }
    }
  }

  void _handleSettingsNavigation(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_settingsIndex > 0) _settingsIndex--;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_settingsIndex < _settingsFocusNodes.length - 1) _settingsIndex++;
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      if (_settingsIndex == 0) {
        _isSettingsOpen = false;
        onToggleSettings();
      } else if (_settingsIndex == 1) {
        _isSubMenuOpen = true;
        _subMenuIndex = 3;
        onPlaybackSpeedSelected();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _isSettingsOpen = false;
      onToggleSettings();
    }
  }

  void _handleSubMenuNavigation(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_subMenuIndex > 0) {
        _subMenuIndex--;
        _scrollToIndex(_subMenuIndex);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_subMenuIndex < _playbackSpeeds.length - 1) {
        _subMenuIndex++;
        _scrollToIndex(_subMenuIndex);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      onChangePlaybackSpeed(_playbackSpeeds[_subMenuIndex]);
      _isSubMenuOpen = false;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _isSubMenuOpen = false;
    }
  }

  void _scrollToIndex(int index) {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      index * 30.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollDown() {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final nextOffset = scrollController.offset + 150;
    scrollController.animateTo(
      nextOffset.clamp(0.0, maxScroll),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollUp() {
    if (!scrollController.hasClients) return;
    final nextOffset = scrollController.offset - 150;
    scrollController.animateTo(
      nextOffset.clamp(0.0, scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool isSliderFocused() => _focusIndex == 0;
  bool isPlayButtonFocused() => _focusIndex == 1;
  bool isFullScreenFocused() => _focusIndex == 2;
  bool isSettingsFocused() => _focusIndex == 3;
  bool isPlayMovieFocused() => _focusIndex == 4;
  bool isAddToWatchLaterFocused() => _focusIndex == 5;
  bool isSettingsOpen() => _isSettingsOpen;
  bool isSubMenuOpen() => _isSubMenuOpen;
  int getSettingsIndex() => _settingsIndex;
  int getSubMenuIndex() => _subMenuIndex;

  // FIX: dispose() cleans up the scroll controller and settings focus nodes.
  // The main _focusNode is intentionally NOT disposed here — it is disposed
  // by the owning page (TVMoviesPlayerPage) so the page controls the lifetime.
  void dispose() {
    scrollController.dispose();
    for (final node in _settingsFocusNodes) {
      node.dispose();
    }
  }
}