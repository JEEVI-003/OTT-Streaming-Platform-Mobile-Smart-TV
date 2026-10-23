import 'package:flutter/material.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/category/category_service.dart';
import 'package:ott_project/components/video_folder/movie_player_page.dart';
import 'package:ott_project/components/video_folder/movies_card.dart';
import 'package:ott_project/components/video_folder/video_container.dart';
import 'package:ott_project/pages/custom_appbar.dart';

class CategoryBasedMovie extends StatefulWidget {
  final String categoryName;
  final List<VideoDescription> videoDescriptions;

  const CategoryBasedMovie({
    Key? key,
    required this.categoryName,
    required this.videoDescriptions,
  }) : super(key: key);

  @override
  State<CategoryBasedMovie> createState() => _CategoryBasedMovieState();
}

class _CategoryBasedMovieState extends State<CategoryBasedMovie> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

  // -------------------------------------------------------------------------
  // FIX — BUG-J:
  //
  // OLD CODE had no initState at all. CategoryService().getCategoryId() was
  // called directly inside the MoviesCard onTap callback without first
  // ensuring CategoryService._categories was populated.
  //
  // WHY IT BROKE:
  //   When the user navigates here via "See more" from a fresh launch (or
  //   after a hot restart), CategoryService._categories may be empty because
  //   MoviePage's loadCategories() hasn't completed yet — or this page was
  //   reached through a navigation path that bypassed MoviePage entirely.
  //   getCategoryId() on an empty list always falls through to
  //   "categoryIds.isNotEmpty ? categoryIds.first : 1", returning the wrong
  //   category ID → MoviesPlayerPage fetches the wrong video details →
  //   the player either crashes or plays the wrong content.
  //
  // FIX:
  //   Add initState() that calls CategoryService().loadCategories() when the
  //   cache is empty.  The grid is rendered immediately (no loading gate
  //   needed because we already have videoDescriptions as a parameter), but
  //   taps that fire before the Future completes will still get the correct
  //   IDs because getCategoryId() is called inside onTap — by which time the
  //   very fast GET /GetAllCategories will already have returned.
  //   A _categoriesReady flag hides the grid until categories are confirmed,
  //   preventing any tap from firing with an empty cache.
  // -------------------------------------------------------------------------
  bool _categoriesReady = false;

  @override
  void initState() {
    super.initState();
    _ensureCategoriesLoaded();
  }

  Future<void> _ensureCategoriesLoaded() async {
    if (CategoryService().categories.isNotEmpty) {
      // Already populated by MoviePage — nothing to do.
      if (mounted) setState(() => _categoriesReady = true);
      return;
    }
    // Load fresh from the backend.
    await CategoryService().loadCategories();
    if (mounted) setState(() => _categoriesReady = true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void handleSearchState(bool isSearching, List<dynamic> results) {
    setState(() {
      _isSearching = isSearching;
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackgroundImage(),
          CustomAppBar(onSearchChanged: handleSearchState),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.sizeOf(context).height * 0.10,
              left: MediaQuery.sizeOf(context).width * 0.02,
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.sizeOf(context).height * 0.15,
              left: MediaQuery.sizeOf(context).width * 0.07,
            ),
            child: Text(
              '${widget.categoryName}  Movies',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          // Show a spinner until categories are confirmed loaded,
          // then show the grid.  This prevents getCategoryId() from
          // being called with an empty cache.
          if (!_categoriesReady)
            const Center(child: CircularProgressIndicator())
          else
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.sizeOf(context).height * 0.20,
                right: MediaQuery.sizeOf(context).width * 0.08,
                left: MediaQuery.sizeOf(context).width * 0.08,
              ),
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 35,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.62,
                ),
                itemCount: widget.videoDescriptions.length,
                itemBuilder: (context, index) {
                  final movie = widget.videoDescriptions[index];
                  return MoviesCard(
                    movie: movie,
                    initialIndex: index,
                    onTap: () {
                      final categoryId = CategoryService()
                          .getCategoryId(
                              movie.categoryList, widget.categoryName);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MoviesPlayerPage(
                            videoDescriptions: widget.videoDescriptions,
                            categoryId: categoryId,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    categoryList: movie.categoryList,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
