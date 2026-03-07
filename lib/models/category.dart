// category.dart

class Category {
  final String id;
  final String name;
  final List<Category> subcategories;

  Category({required this.id, required this.name, this.subcategories = const []});

  // Example method to add a subcategory
  void addSubcategory(Category subcategory) {
    subcategories.add(subcategory);
  }
}