import 'package:flutter/material.dart';

class CategoryBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  CategoryBar(
      {super.key,
      required this.selectedCategory,
      required this.onCategorySelected,
      this.categories = const ["All", "Movies", "Music","Library", "Profile"]});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          return Center(
            child: GestureDetector(
              onTap: () => onCategorySelected(category),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                margin: EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromARGB(255, 203, 116, 219)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  category,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
