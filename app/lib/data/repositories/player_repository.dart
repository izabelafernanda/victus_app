import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';

// --- ESTA LINHA É OBRIGATÓRIA PARA O ERRO DESAPARECER ---
final playerRepositoryProvider = Provider((ref) => PlayerRepository());

class PlayerRepository {
  final ApiClient _client = ApiClient();

  Future<List<dynamic>> getCourseContent(int courseId) async {
    try {
        final response = await _client.dio.get('get_course_content.php?course_id=$courseId');
        if (response.data is List) return response.data;
        if (response.data is Map && response.data['data'] is List) return response.data['data'];
        return [];
    } catch (e) { throw Exception(e); }
  }

  Future<void> toggleFavorite(int lessonId) async {
    try {
      // Usa o ID 1 temporariamente até teres o ID real do utilizador logado
      await _client.dio.post('toggle_favorite.php', data: {
        'user_id': 1, 
        'lesson_id': lessonId
      });
    } catch (e) {
      print("Erro ao favoritar: $e");
    }
  }

  Future<void> updateProgress(int lessonId, bool isCompleted) async {
    try {
      await _client.dio.post('update_progress.php', data: {
        'user_id': 1,
        'lesson_id': lessonId,
        'is_completed': isCompleted
      });
    } catch (e) {
      print("Erro ao salvar progresso: $e");
    }
  }
}