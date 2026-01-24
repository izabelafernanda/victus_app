class LibraryItem {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final int progress;

  LibraryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.progress,
  });

  factory LibraryItem.fromJson(Map<String, dynamic> json) {
    return LibraryItem(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      progress: (json['progress'] ?? 0),
    );
  }
}