class Category {
  final String id;
  final String name;
  final String? parentId;

  Category({
    required this.id,
    required this.name,
    this.parentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parent_id'] as String?,
    );
  }
}