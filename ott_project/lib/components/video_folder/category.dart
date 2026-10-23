class Category {
  final int id;
  final String category_name;

  Category({
    required this.id,
    required this.category_name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['category_id'], category_name: json['categories']);
  }

  @override
  String toString() {
    return 'Category{id: $id, category_name: $category_name}';
  }
}
