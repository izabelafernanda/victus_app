import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

// ESTADO: O que a tela precisa saber?
// 1. isLoading: Se está carregando
// 2. error: Se deu erro (e qual foi)
// 3. user: O usuário logado (se houver)
class AuthState {
  final bool isLoading;
  final String? error;
  final UserModel? user;

  AuthState({this.isLoading = false, this.error, this.user});
}

// VIEW MODEL: A lógica do login
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthViewModel(this._repository) : super(AuthState());

  Future<bool> login(String email, String password) async {
    // 1. Avisa a tela que começou a carregar
    state = AuthState(isLoading: true);

    try {
      // 2. Tenta logar
      final user = await _repository.login(email, password);
      
      // 3. Sucesso! Salva o usuário no estado
      state = AuthState(isLoading: false, user: user);
      return true; // Retorna true para a tela saber que pode mudar de página

    } catch (e) {
      // 4. Erro! Avisa a tela
      state = AuthState(isLoading: false, error: e.toString());
      return false;
    }
  }
}

// PROVIDER: O elo de ligação com a tela
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.read(authRepositoryProvider));
});