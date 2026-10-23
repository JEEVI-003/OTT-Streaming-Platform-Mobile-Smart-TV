import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/LibraryScreen/libraryscreentv.dart';
import 'package:ott_project/tv_ui/LibraryScreen/playlistscreentv.dart';
import 'package:ott_project/tv_ui/LibraryScreen/watchlistscreen.dart';
import 'package:ott_project/tv_ui/moviepage_tv.dart';
import 'package:ott_project/tv_ui/music/musicscreentv.dart';
import 'package:ott_project/tv_ui/components/tvlayout.dart';
import 'package:provider/provider.dart';
import 'package:ott_project/tv_ui/components/authprovider.dart';
import 'package:ott_project/tv_ui/homescreen.dart';
import 'package:ott_project/tv_ui/login&signup/login_tv.dart';
import 'package:ott_project/tv_ui/profilescreen/profilescreentv.dart';

class TVMainPage extends StatefulWidget {
  const TVMainPage({Key? key}) : super(key: key);

  @override
  _TVMainPageState createState() => _TVMainPageState();
}

class _TVMainPageState extends State<TVMainPage> with WidgetsBindingObserver {
  int _pendingSidebarIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FocusManagerService.reset();
    FocusManagerService.globalFocusNode.canRequestFocus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManagerService.setSidebarFocus();
      FocusManagerService.globalFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // FIX: When the app resumes from background (or a child route is popped),
  // re-request the global focus node so the TV remote works immediately.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) FocusManagerService.globalFocusNode.requestFocus();
      });
    }
  }

  // ── Sidebar ────────────────────────────────────────────────────────────────

  void _onSidebarSelected(int index) {
    final authProvider = Provider.of<AuthProviderTV>(context, listen: false);

    if (index >= 3 && index <= 6 && !authProvider.isLoggedIn) {
      setState(() {
        _pendingSidebarIndex = index;
        FocusManagerService.selectedSidebarIndex = index;
        FocusManagerService.focusedSidebarIndex = index;
        FocusManagerService.currentPage = index;
        FocusManagerService.setZone(TVFocusZone.login);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        TVLoginPage.requestEmailFocus?.call();
      });
    } else {
      setState(() {
        FocusManagerService.selectedSidebarIndex = index;
        FocusManagerService.focusedSidebarIndex = index;
        FocusManagerService.currentPage = index;

        switch (index) {
          case 3:
            FocusManagerService.setZone(TVFocusZone.likedSongsGrid);
            break;
          case 4:
            FocusManagerService.setZone(TVFocusZone.playlistGrid);
            break;
          case 5:
            FocusManagerService.setZone(TVFocusZone.watchlistGrid);
            break;
          case 6:
            FocusManagerService.setZone(TVFocusZone.profileSubscription);
            break;
          default:
            FocusManagerService.setZone(TVFocusZone.sidebar);
            break;
        }

        FocusManagerService.selectedCarouselIndex = 0;
        FocusManagerService.selectedCategoryIndex = 0;
        FocusManagerService.focusedCategoryIndex = 0;
        FocusManagerService.selectedButtonIndex = 0;
        FocusManagerService.selectedSeeMoreIndex = 0;
        FocusManagerService.categoryItems.clear();
      });
    }
  }

  // ── Inner-page callbacks ───────────────────────────────────────────────────

  void _onTopRowSelected(int index) {
    // FIX: No setState needed — FocusManagerService is static and the
    // KeyboardListener rebuild is triggered by the setState in _handleKeyEvent.
    FocusManagerService.selectedTopRowIndex = index;
    FocusManagerService.setZone(TVFocusZone.topRow);
  }

  void _onCarouselSelected(int index) {
    FocusManagerService.selectedCarouselIndex = index;
    FocusManagerService.setZone(TVFocusZone.carousel);
  }

  void _onCategorySelected(int categoryIndex, int movieIndex) {
    FocusManagerService.selectedCategoryIndex = categoryIndex;
    FocusManagerService.selectedSeeMoreIndex = movieIndex;
    FocusManagerService.setZone(TVFocusZone.category);
  }

  void _onSeeMoreSelected(int index) {}

  void _handlePlayButtonPress() {}

  void _toggleWatchLater() {
    FocusManagerService.setZone(TVFocusZone.button);
  }

  void _handleWatchlistMovies(int index) {
    FocusManagerService.setZone(TVFocusZone.watchlistGrid);
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  void _handleLoginSuccess() {
    setState(() {
      FocusManagerService.setZone(TVFocusZone.sidebar);
      FocusManagerService.selectedSidebarIndex = _pendingSidebarIndex;
      FocusManagerService.focusedSidebarIndex = _pendingSidebarIndex;
      FocusManagerService.currentPage = _pendingSidebarIndex;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManagerService.globalFocusNode.requestFocus();
    });
  }

  // ── Key handling ───────────────────────────────────────────────────────────

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // FIX: If a player page is on top (videoFocusManager or
    // musicPlayerFocusManager is set), this page should NOT handle key events.
    // The player page uses its own private FocusNode so in practice its
    // KeyboardListener intercepts the events first — this guard is belt-and-
    // suspenders to prevent any edge-case double-dispatch.
    if (FocusManagerService.videoFocusManager != null) return;
    if (FocusManagerService.musicPlayerFocusManager != null) return;

    if (FocusManagerService.isLoginPageFocused) return;

    // FIX: Only call setState once per key event — wrapping the entire
    // handleKeyEvent call in setState caused redundant rebuilds of the whole
    // TVMainPage tree on every single key press, leading to frame drops and
    // perceived lag on TV hardware.
    FocusManagerService.handleKeyEvent(
      event,
      _onSidebarSelected,
      _onTopRowSelected,
      _onCarouselSelected,
      _onCategorySelected,
      _onSeeMoreSelected,
      _handlePlayButtonPress,
      _toggleWatchLater,
      _handleWatchlistMovies,
      context,
    );

    // A single setState after processing so the focus highlight updates
    if (mounted) setState(() {});
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderTV>(
      builder: (context, authProvider, _) {
        return FocusScope(
          autofocus: true,
          child: KeyboardListener(
            focusNode: FocusManagerService.globalFocusNode,
            onKeyEvent: _handleKeyEvent,
            child: TVLayout(
              onSidebarSelected: _onSidebarSelected,
              selectedIndex: FocusManagerService.selectedSidebarIndex,
              child: _getSelectedScreen(authProvider),
            ),
          ),
        );
      },
    );
  }

  // ── Screen router ──────────────────────────────────────────────────────────

  Widget _getSelectedScreen(AuthProviderTV authProvider) {
    final index = FocusManagerService.selectedSidebarIndex;

    final bool isProtectedRoute = index >= 3 && index <= 6;
    if ((isProtectedRoute && !authProvider.isLoggedIn) ||
        FocusManagerService.isLoginPageFocused) {
      return TVLoginPage(onLoginSuccess: _handleLoginSuccess);
    }

    switch (index) {
      case 0:
        return const TVHomeScreen();
      case 1:
        return const TVMovieScreen();
      case 2:
        return const TVMusicScreen();
      case 3:
        final uid3 = authProvider.userId;
        if (uid3 == null) return _loadingScreen('Loading Liked Music...');
        return TVLikedSongsPage(userId: uid3);
      case 4:
        final uid4 = authProvider.userId;
        if (uid4 == null) return _loadingScreen('Loading Playlists...');
        return TVPlayListPage(userId: uid4);
      case 5:
        final uid5 = authProvider.userId;
        if (uid5 == null) return _loadingScreen('Loading Watchlist...');
        return TVWatchlistscreen(userId: uid5);
      case 6:
        return const TVProfileScreen();
      default:
        return const TVHomeScreen();
    }
  }

  Widget _loadingScreen(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color.fromARGB(255, 143, 228, 0),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}