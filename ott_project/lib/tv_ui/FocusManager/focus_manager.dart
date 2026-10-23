import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ott_project/tv_ui/components/authprovider.dart';
import 'package:ott_project/tv_ui/FocusManager/musicplayer_focusmanager.dart';
import 'package:ott_project/tv_ui/components/appbartv.dart';
import 'package:ott_project/tv_ui/login&signup/login_tv.dart';
import 'package:ott_project/tv_ui/FocusManager/videoplayer_focusmanager.dart';
import 'package:provider/provider.dart';

enum TVFocusZone {
  sidebar,
  topRow,
  carousel,
  button,
  seeMore,
  category,
  watchlistGrid,
  likedSongsGrid,
  playlistGrid,
  profileLogout,
  profileSubscription,
  watchlistTab,
  likedSongsTab,
  playlistTab,
  login,
}

class FocusManagerService {

  static final FocusNode globalFocusNode = FocusNode(debugLabel: 'globalFocusNode');

  static TVFocusZone _activeZone = TVFocusZone.sidebar;
  static TVFocusZone get activeZone => _activeZone;

  static void restoreFocusState(Map<String, dynamic> state) {
    isSidebarFocused        = state['isSidebarFocused']        ?? false;
    selectedSidebarIndex    = state['selectedSidebarIndex']    ?? 0;
    isTopRowFocused         = state['isTopRowFocused']         ?? false;
    selectedTopRowIndex     = state['selectedTopRowIndex']     ?? 0;
    isCarouselFocused       = state['isCarouselFocused']       ?? false;
    selectedCarouselIndex   = state['selectedCarouselIndex']   ?? 0;
    isCategoryFocused       = state['isCategoryFocused']       ?? false;
    focusedCategoryIndex    = state['focusedCategoryIndex']    ?? 0;
    selectedCategoryIndex   = state['selectedCategoryIndex']   ?? 0;
    isSeeMoreFocused        = state['isSeeMoreFocused']        ?? false;
    selectedSeeMoreIndex    = state['selectedSeeMoreIndex']    ?? 0;
    isButtonFocused         = state['isButtonFocused']         ?? false;
    selectedButtonIndex     = state['selectedButtonIndex']     ?? 0;
    isWatchlistMoviesFocused      = state['isWatchlistMoviesFocused']      ?? false;
    selectedWatchlistMovieIndex   = state['selectedWatchlistMovieIndex']   ?? 0;

    if (state['isCategoryFocused'] == true) {
      setZone(TVFocusZone.category);
    } else if (state['isCarouselFocused'] == true) {
      setZone(TVFocusZone.carousel);
    } else if (state['isSeeMoreFocused'] == true) {
      setZone(TVFocusZone.category);
    } else if (state['isTopRowFocused'] == true) {
      setZone(TVFocusZone.topRow);
    } else {
      setZone(TVFocusZone.sidebar);
    }

    final double scrollPos = (state['scrollPosition'] ?? 0.0) as double;
    if (scrollController.hasClients) {
      scrollController.jumpTo(
        scrollPos.clamp(0.0, scrollController.position.maxScrollExtent),
      );
    }

    if (state.containsKey('currentPage')) {
      currentPage = (state['currentPage'] ?? 0) as int;
    }

    globalFocusNode.requestFocus();
  }

  static int currentPage = 0;
  static int previousPage = 0;

  static int selectedSidebarIndex = 0;
  static int focusedSidebarIndex = 0;
  static int selectedTopRowIndex = 0;
  static int selectedCarouselIndex = 0;
  static int selectedCategoryIndex = 0;
  static int focusedCategoryIndex = 0;
  static int selectedButtonIndex = 0;
  static int selectedSeeMoreIndex = 0;
  static int selectedWatchlistMovieIndex = 0;
  static int selectedMyPlaylistIndex = 0;
  static int selectedLikedSongsIndex = 0;

  static int carouselItems = 0;
  static int watchlistMoviesCount = 0;
  static int likedSongsCount = 0;
  static int playlistCount = 0;
  static List<int> categoryItems = [];

  static const double categoryHeight = 350.0;
  static final ScrollController _scrollController = ScrollController();
  static ScrollController get scrollController => _scrollController;

  static bool isVideoFullScreen = false;

  static VideoFocusManager? videoFocusManager;
  static MusicPlayerFocusManager? musicPlayerFocusManager;
  static FocusNode? gridFocusNode;

  static Function(int)? onSidebarSelect;
  static Function()? onPlayButtonPress;
  static Function()? onWatchLaterPress;
  static Function(int)? onSeeMoreSelect;
  static Function(int, int)? onCategorySelect;
  static Function(int)? onWatchlistMovieSelect;
  static Function(int)? onMyPlaylistSelect;
  static Function(int)? onLikedSongsSelect;
  static Function(int)? onTabSelected;
  static Function()? onLogoutSelectps;
  static void Function()? onSubscriptionSelectedps;

  static bool get isSidebarFocused => _activeZone == TVFocusZone.sidebar;
  static bool get isTopRowFocused => _activeZone == TVFocusZone.topRow;
  static bool get isCarouselFocused => _activeZone == TVFocusZone.carousel;
  static bool get isCategoryFocused => _activeZone == TVFocusZone.category;
  static bool get isButtonFocused => _activeZone == TVFocusZone.button;
  static bool get isSeeMoreFocused => _activeZone == TVFocusZone.seeMore;
  static bool get isWatchlistMoviesFocused => _activeZone == TVFocusZone.watchlistGrid;
  static bool get isLikedSongsFocused => _activeZone == TVFocusZone.likedSongsGrid;
  static bool get isMyPlaylistFocused => _activeZone == TVFocusZone.playlistGrid;
  static bool get isLogoutFocused => _activeZone == TVFocusZone.profileLogout;
  static bool get isSubscriptionFocused => _activeZone == TVFocusZone.profileSubscription;
  static bool get myWatchlistTabFocused => _activeZone == TVFocusZone.watchlistTab;
  static bool get myLikedSongsTabFocused => _activeZone == TVFocusZone.likedSongsTab;
  static bool get myPlaylistTabFocused => _activeZone == TVFocusZone.playlistTab;
  static bool get isLoginPageFocused => _activeZone == TVFocusZone.login;

  // FIX: When the search text field is active, block global key routing so
  // arrow keys and Enter are handled by the TextField, not the TV navigator.
  static bool isSearchActive = false;

  static set isSidebarFocused(bool v) { if (v) _activeZone = TVFocusZone.sidebar; }
  static set isTopRowFocused(bool v) { if (v) _activeZone = TVFocusZone.topRow; }
  static set isCarouselFocused(bool v) { if (v) _activeZone = TVFocusZone.carousel; }
  static set isCategoryFocused(bool v) { if (v) _activeZone = TVFocusZone.category; }
  static set isButtonFocused(bool v) { if (v) _activeZone = TVFocusZone.button; }
  static set isSeeMoreFocused(bool v) { if (v) _activeZone = TVFocusZone.seeMore; }
  static set isWatchlistMoviesFocused(bool v) { if (v) _activeZone = TVFocusZone.watchlistGrid; }
  static set isLikedSongsFocused(bool v) { if (v) _activeZone = TVFocusZone.likedSongsGrid; }
  static set isMyPlaylistFocused(bool v) { if (v) _activeZone = TVFocusZone.playlistGrid; }
  static set isLogoutFocused(bool v) { if (v) _activeZone = TVFocusZone.profileLogout; }
  static set isSubscriptionFocused(bool v) { if (v) _activeZone = TVFocusZone.profileSubscription; }
  static set myWatchlistTabFocused(bool v) { if (v) _activeZone = TVFocusZone.watchlistTab; }
  static set myLikedSongsTabFocused(bool v) { if (v) _activeZone = TVFocusZone.likedSongsTab; }
  static set myPlaylistTabFocused(bool v) { if (v) _activeZone = TVFocusZone.playlistTab; }
  static set isLoginPageFocused(bool v) { if (v) _activeZone = TVFocusZone.login; }

  static void setZone(TVFocusZone zone) {
    _activeZone = zone;
  }

  static void setSidebarFocus() {
    _activeZone = TVFocusZone.sidebar;
    globalFocusNode.requestFocus();
  }

  static void unfocusAll() {
    globalFocusNode.unfocus();
  }

  static bool isSidebarFocus() => _activeZone == TVFocusZone.sidebar;
  static void clearSidebarFocus() { /* no-op */ }

  static void updateCarouselLength(int length) => carouselItems = length;
  static void updateWatchlistMoviesCount(int count) => watchlistMoviesCount = count;
  static void updateLikedSongCount(int count) => likedSongsCount = count;
  static void updatePlaylistCount(int count) => playlistCount = count;

  static void updateCategoryLength(int index, int length) {
    while (categoryItems.length <= index) categoryItems.add(0);
    categoryItems[index] = length;
  }

  static void setTabFocus(int index) {
    if (index == 0) _activeZone = TVFocusZone.watchlistTab;
    else if (index == 1) _activeZone = TVFocusZone.likedSongsTab;
    else if (index == 2) _activeZone = TVFocusZone.playlistTab;
  }

  static void selectTab(int index) {
    setTabFocus(index);
    onTabSelected?.call(index);
  }

  static void handleKeyEvent(
    KeyEvent event,
    Function(int) onSidebarSelectCb,
    Function(int) onTopRowSelectCb,
    Function(int) onCarouselSelectCb,
    Function(int, int) onCategorySelectCb,
    Function(int) onSeeMoreSelectCb,
    Function() onPlayPressCb,
    Function() onWatchlistPressCb,
    Function(int) onWatchlistMovieSelectCb,
    BuildContext context,
  ) {
    if (event is! KeyDownEvent) return;

    if (_activeZone == TVFocusZone.login) return;
    // FIX: If the search text field is active, don't intercept key events —
    // let the TextField handle arrow keys, backspace, enter, etc.
    if (isSearchActive) return;

    switch (_activeZone) {
      case TVFocusZone.sidebar:
        _handleSidebarNavigation(event, onSidebarSelectCb, context);
        break;
      case TVFocusZone.topRow:
        _handleTopRowNavigation(event, onTopRowSelectCb);
        break;
      case TVFocusZone.carousel:
        _handleCarouselNavigation(event, onCarouselSelectCb);
        break;
      case TVFocusZone.category:
        _handleCategoryNavigation(event, onCategorySelectCb);
        break;
      case TVFocusZone.seeMore:
        _handleSeeMoreNavigation(event, onSeeMoreSelectCb);
        break;
      case TVFocusZone.button:
        _handleButtonNavigation(event);
        break;
      case TVFocusZone.watchlistGrid:
        _handleWatchlistMoviesNavigation(event, onWatchlistMovieSelectCb);
        break;
      case TVFocusZone.playlistGrid:
        // FIX: guard null — onMyPlaylistSelect may not yet be registered
        if (onMyPlaylistSelect != null) {
          _handleMyPlaylistNavigation(event, onMyPlaylistSelect!);
        }
        break;
      case TVFocusZone.likedSongsGrid:
        // FIX: guard null — onLikedSongsSelect may not yet be registered
        if (onLikedSongsSelect != null) {
          _handleLikedSongsNavigation(event, onLikedSongsSelect!);
        }
        break;
      case TVFocusZone.profileSubscription:
        _handleSubScriptionNavigation(event);
        break;
      case TVFocusZone.profileLogout:
        _handleLogoutNavigation(event);
        break;
      case TVFocusZone.watchlistTab:
        _handleWatchlistTabNavigation(event);
        break;
      case TVFocusZone.likedSongsTab:
        _handleLikedSongsTabNavigation(event);
        break;
      case TVFocusZone.playlistTab:
        _handlePlaylistTabNavigation(event);
        break;
      default:
        break;
    }
  }

  static void _handleSidebarNavigation(
    KeyEvent event,
    Function(int) onSidebarSelectCb,
    BuildContext context,
  ) {
    final authProvider = Provider.of<AuthProviderTV>(context, listen: false);

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (focusedSidebarIndex < 6) focusedSidebarIndex++;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (focusedSidebarIndex == 0) {
        // FIX: only jump to topRow on pages that have one (Home=0, Movies=1)
        if (selectedSidebarIndex <= 1) {
          _activeZone = TVFocusZone.topRow;
          if (_scrollController.hasClients) _scrollController.animateTo(0,
              duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
        return;
      } else {
        focusedSidebarIndex--;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      // Move focus from the sidebar into the active page's content zone.
      // Only move when the D-pad highlight is on the currently active page.
      if (focusedSidebarIndex != selectedSidebarIndex) return;

      final page = selectedSidebarIndex;
      if (page == 1) {
        // Movies page — enter the video player controls
        Future.delayed(const Duration(milliseconds: 50), () {
          videoFocusManager?.requestInitialFocus(index: 4);
        });
        return;
      }

      if (focusedSidebarIndex >= 3 && focusedSidebarIndex <= 6 &&
          !authProvider.isLoggedIn) {
        onSidebarSelectCb(selectedSidebarIndex);
        _activeZone = TVFocusZone.login;
        Future.delayed(const Duration(milliseconds: 50), () {
          TVLoginPage.requestEmailFocus?.call();
        });
        return;
      }

      if (_scrollController.hasClients) _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

      // Map each page to its first focusable content zone
      switch (selectedSidebarIndex) {
        case 0: _activeZone = TVFocusZone.carousel; break;
        case 1: _activeZone = TVFocusZone.carousel; break;
        case 2: _activeZone = TVFocusZone.carousel; break; // Music: banner carousel
        case 3: _activeZone = TVFocusZone.likedSongsGrid; break;
        case 4: _activeZone = TVFocusZone.playlistGrid; break;
        case 5: _activeZone = TVFocusZone.watchlistGrid; break;
        case 6: _activeZone = TVFocusZone.profileSubscription; break;
        default: _activeZone = TVFocusZone.carousel; break;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      selectedSidebarIndex = focusedSidebarIndex;
      onSidebarSelectCb(selectedSidebarIndex);
    }
    globalFocusNode.requestFocus();
  }

  static void _handleTopRowNavigation(KeyEvent event, Function(int) onTopRowSelectCb) {
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      selectedTopRowIndex = (selectedTopRowIndex + 1).clamp(0, 2);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (selectedTopRowIndex == 0) {
        _activeZone = TVFocusZone.sidebar;
      } else {
        selectedTopRowIndex = (selectedTopRowIndex - 1).clamp(0, 2);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _activeZone = TVFocusZone.carousel;
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      TVAppBar.onNavigation?.call(selectedTopRowIndex);
    }
  }

  static void _handleCarouselNavigation(KeyEvent event, Function(int) onCarouselSelectCb) {
    if (carouselItems == 0) return; // guard empty state
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      selectedCarouselIndex = (selectedCarouselIndex + 1) % carouselItems;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (selectedCarouselIndex == 0) {
        _activeZone = TVFocusZone.sidebar;
      } else {
        selectedCarouselIndex =
            (selectedCarouselIndex - 1 + carouselItems) % carouselItems;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (selectedSidebarIndex == 2) {
        // Music page: no button row, go directly to category
        _activeZone = TVFocusZone.seeMore;
        selectedSeeMoreIndex = 0;
      } else {
        _activeZone = TVFocusZone.button;
        selectedButtonIndex = 0;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _activeZone = TVFocusZone.topRow;
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      onCarouselSelectCb(selectedCarouselIndex);
    }
  }

  static void _handleCategoryNavigation(
      KeyEvent event, Function(int, int) onCategorySelectCb) {
    if (categoryItems.isEmpty) return;
    int categoryLength = categoryItems[focusedCategoryIndex];
    double scrollOffset = categoryHeight;

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (selectedCategoryIndex < categoryLength - 1) selectedCategoryIndex++;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (selectedCategoryIndex > 0) {
        selectedCategoryIndex--;
      } else {
        _activeZone = TVFocusZone.sidebar;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (focusedCategoryIndex < categoryItems.length - 1) {
        _activeZone = TVFocusZone.seeMore;
        selectedSeeMoreIndex = focusedCategoryIndex + 1;
        if (_scrollController.hasClients) _scrollController.animateTo(
          _scrollController.offset + scrollOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (focusedCategoryIndex == 0) {
        _activeZone = TVFocusZone.seeMore;
        selectedSeeMoreIndex = 0;
        if (_scrollController.hasClients) _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        _activeZone = TVFocusZone.seeMore;
        selectedSeeMoreIndex = focusedCategoryIndex;
        if (_scrollController.hasClients) _scrollController.animateTo(
          scrollOffset * focusedCategoryIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      onCategorySelect?.call(focusedCategoryIndex, selectedCategoryIndex);
    }
    globalFocusNode.requestFocus();
  }

  static void _handleSeeMoreNavigation(KeyEvent event, Function(int) onSeeMoreSelectCb) {
    int totalCategories = categoryItems.length;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _activeZone = TVFocusZone.sidebar;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (selectedSeeMoreIndex > 0) {
        _activeZone = TVFocusZone.category;
        focusedCategoryIndex = selectedSeeMoreIndex - 1;
        selectedCategoryIndex = 0;
      } else {
        // FIX: Music page has no button row — go to carousel directly
        if (selectedSidebarIndex == 2) {
          _activeZone = TVFocusZone.carousel;
        } else {
          _activeZone = TVFocusZone.button;
        }
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (selectedSeeMoreIndex < totalCategories) {
        _activeZone = TVFocusZone.category;
        focusedCategoryIndex = selectedSeeMoreIndex;
        selectedCategoryIndex = 0;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      onSeeMoreSelect?.call(selectedSeeMoreIndex);
      unfocusAll();
    }
  }

  static void _handleButtonNavigation(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      selectedButtonIndex = (selectedButtonIndex + 1) % 2;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (selectedButtonIndex == 0) {
        _activeZone = TVFocusZone.sidebar;
      } else {
        selectedButtonIndex = 0;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _activeZone = TVFocusZone.seeMore;
      selectedSeeMoreIndex = 0;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _activeZone = TVFocusZone.carousel;
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      if (selectedButtonIndex == 0) {
        onPlayButtonPress?.call();
      } else {
        onWatchLaterPress?.call();
      }
    }
  }

  static void _handleWatchlistMoviesNavigation(
      KeyEvent event, Function(int) onWatchlistMovieSelectCb) {
    const int columns = 4;
    int totalMovies = watchlistMoviesCount;

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (selectedWatchlistMovieIndex < totalMovies - 1) selectedWatchlistMovieIndex++;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (selectedWatchlistMovieIndex % columns == 0) {
        _activeZone = TVFocusZone.sidebar;
      } else {
        selectedWatchlistMovieIndex--;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (selectedWatchlistMovieIndex + columns < totalMovies) {
        selectedWatchlistMovieIndex += columns;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (selectedWatchlistMovieIndex < columns) {
        _activeZone = TVFocusZone.sidebar;
        selectedWatchlistMovieIndex = 0;
      } else {
        selectedWatchlistMovieIndex -= columns;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      if (selectedWatchlistMovieIndex >= 0 &&
          selectedWatchlistMovieIndex < totalMovies) {
        onWatchlistMovieSelect?.call(selectedWatchlistMovieIndex);
      }
    }
    globalFocusNode.requestFocus();
  }

  static void _handleMyPlaylistNavigation(
      KeyEvent event, Function(int) onMyPlaylistSelectCb) {
    const int columns = 4;
    int totalPlaylist = playlistCount;

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (selectedMyPlaylistIndex < totalPlaylist - 1) selectedMyPlaylistIndex++;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (selectedMyPlaylistIndex % columns == 0) {
        _activeZone = TVFocusZone.sidebar;
      } else {
        selectedMyPlaylistIndex--;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (selectedMyPlaylistIndex + columns < totalPlaylist) {
        selectedMyPlaylistIndex += columns;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (selectedMyPlaylistIndex < columns) {
        _activeZone = TVFocusZone.sidebar;
        selectedMyPlaylistIndex = 0;
      } else {
        selectedMyPlaylistIndex -= columns;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      if (selectedMyPlaylistIndex >= 0 &&
          selectedMyPlaylistIndex < totalPlaylist) {
        onMyPlaylistSelectCb(selectedMyPlaylistIndex);
      }
    }
    globalFocusNode.requestFocus();
  }

  static void _handleLikedSongsNavigation(
      KeyEvent event, Function(int) onLikedSongsSelectCb) {
    const int columns = 4;
    int totalLiked = likedSongsCount;

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (selectedLikedSongsIndex < totalLiked - 1) selectedLikedSongsIndex++;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (selectedLikedSongsIndex % columns == 0) {
        _activeZone = TVFocusZone.sidebar;
      } else {
        selectedLikedSongsIndex--;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (selectedLikedSongsIndex + columns < totalLiked) {
        selectedLikedSongsIndex += columns;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (selectedLikedSongsIndex < columns) {
        _activeZone = TVFocusZone.sidebar;
        selectedLikedSongsIndex = 0;
      } else {
        selectedLikedSongsIndex -= columns;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      if (selectedLikedSongsIndex >= 0 && selectedLikedSongsIndex < totalLiked) {
        onLikedSongsSelectCb(selectedLikedSongsIndex);
      }
    }
    globalFocusNode.requestFocus();
  }

  static void _handleSubScriptionNavigation(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _activeZone = TVFocusZone.sidebar;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _activeZone = TVFocusZone.profileLogout;
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      onSubscriptionSelectedps?.call();
    }
    globalFocusNode.requestFocus();
  }

  static void _handleLogoutNavigation(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _activeZone = TVFocusZone.sidebar;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _activeZone = TVFocusZone.profileSubscription;
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      onLogoutSelectps?.call();
    }
    globalFocusNode.requestFocus();
  }

  static void _handleWatchlistTabNavigation(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _activeZone = TVFocusZone.sidebar;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _activeZone = TVFocusZone.watchlistGrid;
      selectedWatchlistMovieIndex = 0;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _activeZone = TVFocusZone.likedSongsTab;
    }
    globalFocusNode.requestFocus();
  }

  static void _handleLikedSongsTabNavigation(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _activeZone = TVFocusZone.watchlistTab;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _activeZone = TVFocusZone.likedSongsGrid;
      selectedLikedSongsIndex = 0;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _activeZone = TVFocusZone.playlistTab;
    }
    globalFocusNode.requestFocus();
  }

  static void _handlePlaylistTabNavigation(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _activeZone = TVFocusZone.likedSongsTab;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _activeZone = TVFocusZone.playlistGrid;
      selectedMyPlaylistIndex = 0;
    }
    globalFocusNode.requestFocus();
  }

  static void reset() {
    _activeZone = TVFocusZone.sidebar;
    focusedSidebarIndex = 0;
    selectedSidebarIndex = 0;
    currentPage = 0;
    selectedCarouselIndex = 0;
    selectedCategoryIndex = 0;
    focusedCategoryIndex = 0;
    selectedButtonIndex = 0;
    selectedSeeMoreIndex = 0;
    selectedWatchlistMovieIndex = 0;
    selectedMyPlaylistIndex = 0;
    selectedLikedSongsIndex = 0;
    categoryItems.clear();
    // Clear callbacks so stale page callbacks don't fire after page switches
    onPlayButtonPress = null;
    onWatchLaterPress = null;
    onSeeMoreSelect = null;
    onCategorySelect = null;
    onWatchlistMovieSelect = null;
    onMyPlaylistSelect = null;
    onLikedSongsSelect = null;
  }
}