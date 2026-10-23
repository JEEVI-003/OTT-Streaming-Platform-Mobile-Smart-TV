import 'package:ott_project/components/video_folder/category.dart';
import 'package:ott_project/service/movie_api_service.dart';

class CategoryService {
  static final CategoryService _instance = CategoryService._internal();

  factory CategoryService() {
    return _instance;
  }

  CategoryService._internal();

  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Future<void> loadCategories() async {
    _categories = await MovieApiService.fetchCategories();
  }

  int getCategoryId(List<int> categoryIds, String categoryName) {
    for (int categoryId in categoryIds) {
      // Find the category name for this ID
      final matchingCategory = _categories.firstWhere(
        (category) => category.id == categoryId,
        orElse: () => Category(id: 0, category_name: 'Unknown'),
      );

      // Check if the category name matches the current category
      if (matchingCategory.category_name == categoryName) {
        return categoryId;
      }
    }

    // If no match, return the first in the list or default
    return categoryIds.isNotEmpty ? categoryIds.first : 1;
  }
List<String> getCategoryNames(List<int> categoryIds) {
  return categoryIds.map((id) {
    final category = CategoryService().categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => Category(id: 0, category_name: 'Unknown'),
    );
    return category.category_name;
  }).toList();
}

}
