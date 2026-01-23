import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Este provider permite que qualquer lugar do app acesse a API
final apiClientProvider = Provider((ref) => ApiClient());

class ApiClient {
  final Dio _dio = Dio();

  // --- ADICIONE ESTA LINHA AQUI ---
  // Isso cria uma "porta pública" para o repositório conseguir usar o Dio
  Dio get dio => _dio; 
  // -------------------------------

  ApiClient() {
    // 🚨 CONFIGURAÇÃO IMPORTANTE:
    // Mudei para 127.0.0.1 pois o Chrome prefere números ao "localhost"
    _dio.options.baseUrl = 'http://127.0.0.1/victus_app/api/';
    
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
    // Isso mostra no terminal o que está sendo enviado (útil para debug)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // Função para fazer Login (POST)
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  // Função para buscar dados (GET)
  Future<Response> get(String path) async {
    try {
      return await _dio.get(path);
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}