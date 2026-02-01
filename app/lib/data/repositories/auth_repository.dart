import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../../core/api_client.dart';
import '../models/user_model.dart';

// --- DEFINIÇÃO DO PROVIDER GLOBAL ---
// Isto resolve o erro "Undefined name 'authRepositoryProvider'"
final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthRepository {
  final ApiClient _client = ApiClient();

  // 1. LOGIN (Atualizado para salvar o Nome)
  // lib/data/repositories/auth_repository.dart

  // 1. LOGIN (Atualizado para remover "Exception:")
  // lib/data/repositories/auth_repository.dart

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _client.dio.post('login.php', data: {
        'email': email,
        'password': password,
      });

      // 1. Verificar se o servidor mandou 'success': true
      if (response.data['success'] == true) {
        final data = response.data;
        
        if (data['token'] != null) {
          _client.setToken(data['token']);
        }

        if (data['user'] != null && data['user']['name'] != null) {
           ApiClient.userName = data['user']['name'];
        }
        
        return UserModel.fromJson(data['user']);
      } else {
        // 2. Se 'success' for false (senha errada), lançamos a mensagem
        throw response.data['message'] ?? "Erro ao fazer login";
      }

    } catch (e) {
       // 3. Limpeza final da mensagem de erro
       // Remove "Exception:" e "DioException" para ficar limpo na tela
       String errorMsg = e.toString();
       errorMsg = errorMsg.replaceAll("Exception: ", "");
       errorMsg = errorMsg.replaceAll("DioException: ", "");
       throw errorMsg;
    }
  }

  // 2. REGISTO (Resolve o erro "The method 'register' isn't defined")
  // Em lib/data/repositories/auth_repository.dart

  // lib/data/repositories/auth_repository.dart

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await _client.dio.post('register.php', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        return; // Sucesso!
      } else {
        // --- CORREÇÃO AQUI ---
        // Antes: throw Exception(response.data['message']);
        // Agora: Lançamos apenas a mensagem (String) para não aparecer "Exception:"
        throw response.data['message'] ?? "Erro ao criar conta.";
      }

    } catch (e) {
      // --- LIMPEZA FINAL ---
      // Se ocorrer um erro de conexão ou outro, limpamos o prefixo "Exception: "
      // caso ele tenha sido adicionado automaticamente por alguma biblioteca.
      String errorMessage = e.toString().replaceAll("Exception: ", "");
      throw errorMessage;
    }
  }

  // 3. RECUPERAR SENHA (Já tinhas este)
  // lib/data/repositories/auth_repository.dart

  // No auth_repository.dart
Future<void> recoverPassword(String email) async {
  try {
    final response = await _client.dio.post('forgot_password.php', data: {'email': email});

    // Se o PHP diz que falhou (ex: email não existe), lançamos erro
    if (response.data['success'] != true) {
       throw response.data['message'] ?? "Erro desconhecido.";
    }
    // Se chegou aqui, é sucesso (void)
  } catch (e) {
    throw e.toString().replaceAll("Exception: ", "");
  }
}
}