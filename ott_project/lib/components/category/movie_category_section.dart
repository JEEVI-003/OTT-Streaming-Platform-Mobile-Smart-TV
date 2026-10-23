import 'package:flutter/material.dart';
import 'package:ott_project/components/category/category_service.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:ott_project/components/video_folder/category_based_movie.dart';
import 'package:ott_project/components/video_folder/movie_player_page.dart';
import 'package:ott_project/components/video_folder/movies_card.dart';

import '../video_folder/video_container.dart';

class MoviesCategorySection extends StatefulWidget {
  final VideoContainer videoContainer;
  const MoviesCategorySection({super.key, required this.videoContainer});

  @override
  State<MoviesCategorySection> createState() => _MoviesCategorySectionState();
}

class _MoviesCategorySectionState extends State<MoviesCategorySection> {

  @override
  void initState() {
    super.initState();
    // FIX — BUG-H: Only call loadCategories() if the cache is empty.
    // MoviePage already awaits loadCategories() before this widget is shown,
    // so this guard prevents redundant concurrent calls that race-overwrite
    // the singleton _categories list and assign wrong category IDs to sections.
    if (CategoryService().categories.isEmpty) {
      CategoryService().loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedMovies = widget.videoContainer.videoDescriptions.length > 5
        ? widget.videoContainer.videoDescriptions.sublist(0, 5)
        : widget.videoContainer.videoDescriptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.videoContainer.value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kWhite,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryBasedMovie(
                      categoryName: widget.videoContainer.value,
                      videoDescriptions:
                          widget.videoContainer.videoDescriptions,
                    ),
                  ),
                );
              },
              child: const Text('See more',
                  style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.22,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayedMovies.length,
            itemBuilder: (context, index) {
              final movie = displayedMovies[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: MoviesCard(
                  movie: displayedMovies[index],
                  onTap: () {
                    final categoryId = CategoryService().getCategoryId(
                        movie.categoryList, widget.videoContainer.value);

                    print(
                        'Tapped category: ${widget.videoContainer.value}, CategoryID: $categoryId');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MoviesPlayerPage(
                          categoryId: categoryId,
                          videoDescriptions:
                              widget.videoContainer.videoDescriptions,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  categoryList: movie.categoryList,
                  initialIndex: index,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}