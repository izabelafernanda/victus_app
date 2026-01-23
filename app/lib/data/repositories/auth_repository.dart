import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../models/user_model.dart';

// O Provider que disponibiliza esse repositório para o App
final authRepositoryProvider = Provider((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

class AuthRepository {
  final ApiClient _api;

  AuthRepository(this._api);

  Future<UserModel> login(String email, String password) async {
    // Chama a nossa rota PHP
    final response = await _api.post(
      'auth_login.php', 
      data: {
        'email': email,
        'password': password,
      }
    );

    // Verifica se o PHP respondeu "success"
    if (response.data['status'] == 'success') {
      // Converte o JSON 'data' para o nosso objeto UserModel
      return UserModel.fromJson(response.data['data']);
    } else {
      // Se deu erro (senha errada), lança uma exceção
      throw Exception(response.data['message'] ?? 'Erro desconhecido');
    }
  }
}