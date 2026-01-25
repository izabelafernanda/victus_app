import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost/victus_app/api/';
  
  static String? authToken;

  final Dio dio;

  ApiClient() : dio = Dio(BaseOptions(baseUrl: baseUrl)) {
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
}