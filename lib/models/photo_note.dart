class PhotoNote {
  final String id;
  final String text;
  final String imageId;
  final DateTime createdAt;

  PhotoNote({required this.id, required this.text, required this.imageId, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'imageId': imageId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PhotoNote.fromMap(Map<String, dynamic> map) {
    return PhotoNote(
      id: map['id'],
      text: map['text'],
      imageId: map['imageId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}