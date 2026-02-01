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

  /// Atualiza o nome do utilizador. Retorna { success, name?, message? }.
  Future<Map<String, dynamic>> updateUserName(String name) async {
    try {
      final response = await dio.post('update_profile.php', data: {'name': name});
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data)
          : <String, dynamic>{};
      if (response.statusCode == 200 && (data['success'] == true || data['success'] == 1)) {
        if (data['name'] != null) userName = data['name'] as String;
        return {'success': true, 'name': data['name']};
      }
      return {'success': false, 'message': data['message'] ?? 'Erro ao atualizar.'};
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      return {'success': false, 'message': msg ?? e.message ?? 'Não foi possível atualizar. Verifica a ligação.'};
    } catch (e) {
      return {'success': false, 'message': 'Erro inesperado. Tenta novamente.'};
    }
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