import 'package:dio/dio.dart';
import '../core/api_client.dart';

/// Auth Controller - Login, Register, Forgot Password logic
class AuthController {
  final ApiClient _api = ApiClient();

  Future<bool> login(String email, String password) async {
    final response = await _api.dio.post(
      'auth_login.php',
      data: {'email': email.trim(), 'password': password},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['status'] == 'success') {
        if (data['token'] != null) ApiClient.authToken = data['token'];
        if (data['user'] != null) {
          ApiClient.userName = data['user']['name'];
          ApiClient.userAvatarUrl = data['user']['avatar_url'];
        }
        return true;
      }
    }
    return false;
  }

  Future<String?> loginWithError(String email, String password) async {
    try {
      final ok = await login(email, password);
      return ok ? null : 'Erro de login';
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return 'Email ou palavra-passe incorretos.';
      if (e.response?.statusCode == 404) return 'Conta não encontrada.';
      return e.response?.data['message']?.toString() ?? 'Erro no servidor.';
    } catch (_) {
      return 'Ocorreu um erro inesperado.';
    }
  }

  Future<String?> register(String name, String email, String password) async {
    try {
      final response = await _api.dio.post('auth_register.php', data: {
        'name': name,
        'email': email.trim(),
        'password': password,
      });

      if (response.statusCode == 201) {
        await login(email, password);
        return null;
      }
      return response.data['message']?.toString() ?? 'Erro ao registar';
    } on DioException catch (e) {
      return e.response?.data['message']?.toString() ?? 'Erro ao registar';
    } catch (e) {
      return 'Erro ao registar: $e';
    }
  }

  Future<String?> forgotPassword(String email) async {
    try {
      final response = await _api.dio.post(
        'auth_forgot_password.php',
        data: {'email': email.trim()},
      );

      if (response.statusCode == 200) return null;
      return response.data['message']?.toString() ?? 'Erro ao enviar email.';
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return 'Este email não está registado na nossa aplicação.';
      }
      return e.response?.data['message']?.toString() ?? 'Erro no servidor.';
    } catch (_) {
      return 'Erro ao enviar email.';
    }
  }
}
