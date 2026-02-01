import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';

// --- ESTA LINHA É OBRIGATÓRIA PARA O ERRO DESAPARECER ---
final libraryRepositoryProvider = Provider((ref) => LibraryRepository());

class LibraryRepository {
  final ApiClient _client = ApiClient();

  Future<List<dynamic>> getLibraryItems() async {
    try {
      // Ajuste para a rota correta do teu backend
      final response = await _client.dio.get('get_library.php');
      return response.data;
    } catch (e) {
      throw Exception("Erro ao carregar biblioteca.");
    }
  }

  Future<List<dynamic>> getCourseLessons(int courseId) async {
    try {
      final response = await _client.dio.get('get_course_content.php', queryParameters: {
        'course_id': courseId
      });
      return response.data;
    } catch (e) {
      throw Exception("Erro ao carregar aulas.");
    }
  }

  Future<Map<String, dynamic>> getLesson(int courseId) async {
    try {
      final response = await _client.dio.get('get_lesson.php', queryParameters: {
        'course_id': courseId
      });
      
      if (response.data is List && (response.data as List).isEmpty) {
        return {}; 
      }
      return response.data; 
    } catch (e) {
      throw Exception("Erro ao carregar vídeo.");
    }
  }
}