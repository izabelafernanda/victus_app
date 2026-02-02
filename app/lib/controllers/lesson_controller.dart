import 'package:dio/dio.dart';
import '../core/api_client.dart';

/// Lesson Controller - Course content, favorites, progress
class LessonController {
  final ApiClient _api = ApiClient();

  Future<List<dynamic>> getCourseContent(int courseId) async {
    try {
      final response = await _api.dio.get('get_course_content.php?course_id=$courseId');
      if (response.data is List) return response.data;
      if (response.data is Map && response.data['data'] is List) {
        return response.data['data'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> toggleFavorite(int lessonId) async {
    return _api.toggleFavorite(lessonId);
  }

  Future<Map<String, dynamic>?> updateProgress(int lessonId, int progressSeconds, {bool completed = false}) async {
    return _api.updateLessonProgress(lessonId, progressSeconds, completed: completed);
  }
}
