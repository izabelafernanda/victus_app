import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost/victus_app/api/';
  
  static String? authToken;
  static String? userName;
  static String? userAvatarUrl;

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  final Dio dio;

  ApiClient._internal() : dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (authToken != null) {
          options.headers['Authorization'] = 'Bearer $authToken';
          print("🔑 Token enviado: $authToken");
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        print("❌ Erro na API: ${e.response?.statusCode} - ${e.message}");
        return handler.next(e);
      },
    ));
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await dio.post('auth_login.php', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        authToken = data['token'];
        
        if (data['user'] != null) {
          userName = data['user']['name'];
          userAvatarUrl = data['user']['avatar_url'];
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Alterna favorito da aula. Retorna { success, is_favorited } ou null em erro.
  Future<Map<String, dynamic>?> toggleFavorite(int lessonId) async {
    try {
      final response = await dio.post('toggle_favorite.php', data: {'lesson_id': lessonId});
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Atualiza progresso e/ou conclusão da aula. Retorna { success, progress_seconds, completed } ou null em erro.
  Future<Map<String, dynamic>?> updateLessonProgress(int lessonId, int progressSeconds, {bool completed = false}) async {
    try {
      final response = await dio.post('update_lesson_progress.php', data: {
        'lesson_id': lessonId,
        'progress_seconds': progressSeconds,
        'completed': completed,
      });
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}