import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost/victus_app/api/';
  
  static String? authToken;
  static String? userName;

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
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}