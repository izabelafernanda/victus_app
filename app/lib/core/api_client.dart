import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  // Padrão Singleton: Garante que só existe uma conexão aberta na App inteira
  static final ApiClient _instance = ApiClient._internal();
  
  factory ApiClient() {
    return _instance;
  }

  late final Dio dio;
  String? _authToken;
  static String? userName;

  // Define a URL base dependendo se é Web ou Android
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/victus_app/api/';
    } else {
      // 10.0.2.2 é o endereço do localhost do PC visto de dentro do emulador Android
      return 'http://10.0.2.2/victus_app/api/';
    }
  }

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ));

    // Interceptor: Adiciona o Token automaticamente em todos os pedidos
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
          debugPrint("🔑 Token enviado: $_authToken");
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        debugPrint("❌ Erro API: ${e.response?.statusCode} - ${e.message}");
        return handler.next(e);
      },
    ));
  }

  void setToken(String token) {
    _authToken = token;
  }
}