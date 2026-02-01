class LessonModel {
  final int id;
  final String title;
  final String description;
  final String videoUrl;
  final int durationMinutes;
  final bool isLocked;
  final bool isCompleted;
  final bool isFavorited;

  LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.durationMinutes,
    this.isLocked = false,
    this.isCompleted = false,
    this.isFavorited = false,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? 'Sem Título',
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      durationMinutes: int.tryParse(json['duration_minutes'].toString()) ?? 0,
      
      // Converte 1/0 ou true/false para bool Dart
      isLocked: json['is_locked'].toString() == '1' || json['is_locked'] == true,
      isCompleted: json['is_completed'].toString() == '1' || json['is_completed'] == true,
      isFavorited: json['is_favorited'].toString() == '1' || json['is_favorited'] == true,
    );
  }
}