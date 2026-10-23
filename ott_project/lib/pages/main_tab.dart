import 'package:flutter/material.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/library/library_page.dart';
import 'package:ott_project/pages/login_page.dart';
import 'package:ott_project/pages/movie_page.dart';
import 'package:ott_project/pages/music_page.dart';
import 'package:ott_project/profile/profile_page.dart';
import 'package:ott_project/service/service.dart';

class MainTab extends StatefulWidget {
  final int initialTab;
  const MainTab({super.key, required this.initialTab});

  @override
  State<MainTab> createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> with TickerProviderStateMixin {
  int selectTab = 0;
  TabController? controller;
  int? userId;

  // -------------------------------------------------------------------------
  // FIX — BUG-I:
  //
  // OLD CODE had:
  //   if (userId == null) { return Scaffold(... CircularProgressIndicator) }
  //
  // WHY IT BROKE:
  //   userId starts as null (it is int?). The Future from getLoggedInUserId()
  //   completes asynchronously — so on the first build() call userId IS null
  //   and the spinner is shown. That is correct so far.
  //
  //   The bug is that when the user navigates BACK from MoviesPlayerPage,
  //   MainTab is rebuilt. At that moment userId has already been set, so no
  //   spinner — fine.  BUT if the session token was cleared (e.g. after the
  //   player page disposed and the auth service was refreshed), or if a hot
  //   reload/restart happens, getLoggedInUserId() can return null for a valid
  //   logged-in session because the storage read hasn't finished yet.
  //
  //   More critically: the old code had NO escape from the spinner when
  //   getLoggedInUserId() returns null (guest user / expired token). The
  //   .then() callback fires and sets userId = null — which is already null —
  //   so setState() is never called, the spinner never clears, and every tab
  //   button press is swallowed by the loading overlay forever.
  //
  // FIX:
  //   Add a separate boolean _userLoaded that flips to true only AFTER the
  //   Future completes — regardless of whether userId is null or not.
  //   • Still loading  → show spinner (same as before)
  //   • Loaded, userId != null → show tabs (same as before)
  //   • Loaded, userId == null → redirect to LoginPage so the user can sign in
  //     instead of showing an infinite spinner.
  // -------------------------------------------------------------------------
  bool _userLoaded = false;

  @override
  void initState() {
    super.initState();
    controller = TabController(
        length: 4, vsync: this, initialIndex: widget.initialTab);
    controller?.addListener(() {
      if (!mounted) return;
      setState(() {
        selectTab = controller!.index;
      });
    });

    // Load userId in background — set _userLoaded=true when done.
    Service().getLoggedInUserId().then((id) {
      if (!mounted) return;
      setState(() {
        userId = id;
        _userLoaded = true;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Still waiting for storage read to complete → show spinner.
    if (!_userLoaded) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            BackgroundImage(),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    // Storage read finished but no valid session → go to login.
    if (userId == null) {
      // Use addPostFrameCallback so we don't call Navigator during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      });
      // Return an empty black scaffold while the frame callback fires.
      return const Scaffold(backgroundColor: Colors.black);
    }

    // Normal render — userId is confirmed non-null.
    return WillPopScope(
      onWillPop: () async {
        if (controller?.index != 0) {
          controller?.animateTo(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            // Main content area
            Expanded(
              child: TabBarView(
                controller: controller,
                children: [
                  const MoviePage(),
                  MusicPage(userId: userId!),
                  LibraryPage(userId: userId!),
                  const ProfilePage(),
                ],
              ),
            ),
            // Bottom TabBar
            Container(
              height: MediaQuery.sizeOf(context).height * 0.10,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                  bottom: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -3),
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: TabBar(
                controller: controller,
                indicatorWeight: 0.01,
                indicatorColor: Colors.black,
                dividerColor: Colors.transparent,
                overlayColor: const WidgetStatePropertyAll(
                    Color.fromARGB(0, 14, 13, 13)),
                unselectedLabelStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelColor: Colors.white,
                labelColor: Colors.green,
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                tabs: [
                  Tab(
                    text: "MOVIE",
                    icon: Icon(Icons.movie_rounded,
                        size: 27,
                        color: selectTab == 0
                            ? Colors.green
                            : Colors.white),
                  ),
                  Tab(
                    text: "MUSIC",
                    icon: Icon(Icons.music_note_sharp,
                        size: 27,
                        color: selectTab == 1
                            ? Colors.green
                            : Colors.white),
                  ),
                  Tab(
                    text: "LIBRARY",
                    icon: Icon(Icons.library_music_rounded,
                        size: 27,
                        color: selectTab == 2
                            ? Colors.green
                            : Colors.white),
                  ),
                  Tab(
                    text: "ACCOUNT",
                    icon: Icon(Icons.person_outline_rounded,
                        size: 27,
                        color: selectTab == 3
                            ? Colors.green
                            : Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
