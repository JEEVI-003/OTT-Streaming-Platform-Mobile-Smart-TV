import 'package:flutter/material.dart';
import 'package:ott_project/components/background_image.dart';

class RecentMoviePage extends StatelessWidget {
  const RecentMoviePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackgroundImage(),
        Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        AppBar(
                          backgroundColor: Colors.transparent,
                          automaticallyImplyLeading: false,
                          leading: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: EdgeInsets.only(left: 50, right: 50),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextField(
                              //controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }
}
