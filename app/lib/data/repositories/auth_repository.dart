import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

class AuthRepository {
  final ApiClient _api;

  AuthRepository(this._api);

  Future<UserModel> login(String email, String password) async {
    final response = await _api.post(
      'auth_login.php', 
      data: {
        'email': email,
        'password': password,
      }
    );

    if (response.data['status'] == 'success') {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Erro desconhecido');
    }
  }
}