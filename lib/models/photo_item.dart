class PhotoItem {
  final String id;
  final String categoryId;
  final String imagePath;
  final DateTime createdAt;

  PhotoItem({
    required this.id,
    required this.categoryId,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PhotoItem.fromMap(Map<String, dynamic> map) {
    return PhotoItem(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      imagePath: map['image_path'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
