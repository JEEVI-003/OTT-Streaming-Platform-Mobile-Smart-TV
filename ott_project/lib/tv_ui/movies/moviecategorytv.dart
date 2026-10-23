import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ott_project/components/category/category_service.dart';
import 'package:ott_project/components/video_folder/video_container.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/components/tvlayout.dart';
import 'package:ott_project/tv_ui/movies/moviecardtv.dart';
import 'package:ott_project/tv_ui/movies/movieplayertv.dart';

class TVCategoryBasedMovie extends StatefulWidget {
  final String categoryName;
  final List<VideoDescription> videoDescriptions;

  const TVCategoryBasedMovie({
    Key? key,
    required this.categoryName,
    required this.videoDescriptions,
  }) : super(key: key);

  @override
  State<TVCategoryBasedMovie> createState() => _TVCategoryBasedMovieState();
}

class _TVCategoryBasedMovieState extends State<TVCategoryBasedMovie> {
  int selectedIndex = FocusManagerService.selectedSidebarIndex;
  int currentFocusedIndex = 0;

  // FIX: This page owns its own KeyboardListener focus node — separate from
  // both FocusManagerService.globalFocusNode (TVMainPage) and the player's
  // private node. This is critical: when TVMoviesPlayerPage is popped,
  // its dispose() re-focuses globalFocusNode (TVMainPage), but TVCategoryBasedMovie
  // is on top of TVMainPage on the stack. We must re-request _gridFocusNode
  // in the .then() callback so this page intercepts keys again.
  final FocusNode _gridFocusNode =
      FocusNode(debugLabel: 'movieCategoryGrid');

  static const int columns = 4;

  @override
  void initState() {
    super.initState();
    FocusManagerService.previousPage = FocusManagerService.currentPage;
    FocusManagerService.currentPage = 2;
    FocusManagerService.gridFocusNode = _gridFocusNode;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gridFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // Clear the grid focus node reference so stale callbacks don't fire
    if (FocusManagerService.gridFocusNode == _gridFocusNode) {
      FocusManagerService.gridFocusNode = null;
    }
    _gridFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;
    final maxIndex = widget.videoDescriptions.length - 1;

    // Escape / GoBack — pop this category page back to the main listing
    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.goBack ||
        key == LogicalKeyboardKey.browserBack) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      return;
    }

    setState(() {
      if (key == LogicalKeyboardKey.arrowRight) {
        if (currentFocusedIndex < maxIndex) currentFocusedIndex++;
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        if (currentFocusedIndex > 0) {
          currentFocusedIndex--;
        } else {
          // Left from first item → go back to sidebar in TVMainPage
          // We pop this page entirely so TVMainPage regains control
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            FocusManagerService.setSidebarFocus();
          }
          debugPrint('[MovieCategory] Back to sidebar');
        }
      } else if (key == LogicalKeyboardKey.arrowDown) {
        if (currentFocusedIndex + columns <= maxIndex) {
          currentFocusedIndex += columns;
        }
      } else if (key == LogicalKeyboardKey.arrowUp) {
        if (currentFocusedIndex - columns >= 0) {
          currentFocusedIndex -= columns;
        }
      } else if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.select ||
          key == LogicalKeyboardKey.gameButtonA) {
        _playSelectedMovie();
      }
    });
  }

  void _playSelectedMovie() {
    if (currentFocusedIndex < 0 ||
        currentFocusedIndex >= widget.videoDescriptions.length) return;

    final selectedMovie = widget.videoDescriptions[currentFocusedIndex];
    final categoryId = CategoryService()
        .getCategoryId(selectedMovie.categoryList, widget.categoryName);
    final savedIndex = currentFocusedIndex;

    // FIX: Unfocus _gridFocusNode before pushing so that the player page's
    // autofocus can take effect cleanly without competing focus requests.
    _gridFocusNode.unfocus();

    Navigator.of(context, rootNavigator: true)
        .push(
          MaterialPageRoute(
            builder: (context) => TVMoviesPlayerPage(
              categoryId: categoryId,
              videoDescriptions: widget.videoDescriptions,
              initialIndex: currentFocusedIndex,
            ),
          ),
        )
        .then((_) {
      if (!mounted) return;

      // FIX: Restore page state and re-request focus on THIS page's node.
      // TVMoviesPlayerPage.dispose() requests globalFocusNode (TVMainPage),
      // but TVMainPage is behind us on the stack — we must explicitly
      // re-claim _gridFocusNode so key events flow here and not to TVMainPage.
      FocusManagerService.currentPage = 2;
      setState(() => currentFocusedIndex = savedIndex);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _gridFocusNode.requestFocus();
      });
    });
  }

  void _onSidebarSelected(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return TVLayout(
      selectedIndex: selectedIndex,
      onSidebarSelected: _onSidebarSelected,
      // FIX: KeyboardListener wraps the entire page content so key events
      // are captured as long as _gridFocusNode has focus, including during
      // the brief window between page mount and first postFrameCallback.
      child: KeyboardListener(
        focusNode: _gridFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 20.0),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Text(
                    '${widget.categoryName} Movies',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: widget.videoDescriptions.length,
                  itemBuilder: (context, index) {
                    final movie = widget.videoDescriptions[index];
                    final isFocused = index == currentFocusedIndex;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: isFocused
                          ? const EdgeInsets.all(2.0)
                          : EdgeInsets.zero,
                      decoration: BoxDecoration(
                        border: isFocused
                            ? Border.all(
                                color: Colors.white, width: 2.0)
                            : null,
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
                      child: TVMoviesCard(
                        movie: movie,
                        initialIndex: index,
                        onTap: () {
                          setState(
                              () => currentFocusedIndex = index);
                          _playSelectedMovie();
                        },
                        categoryList: movie.categoryList,
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