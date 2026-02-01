import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

// Estado do Login (Pode estar em Loading, ter um Erro ou Sucesso)
class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  LoginState({this.isLoading = false, this.errorMessage, this.isSuccess = false});
}

// O ViewModel (Notifier)
class LoginViewModel extends StateNotifier<LoginState> {
  final AuthRepository _repository;

  LoginViewModel(this._repository) : super(LoginState());

  Future<void> login(String email, String password) async {
    // 1. Muda estado para Carregando
    state = LoginState(isLoading: true);

    try {
      // 2. Chama o repositório
      await _repository.login(email, password);
      
      // 3. Sucesso
      state = LoginState(isSuccess: true, isLoading: false);
    } catch (e) {
      // 4. Erro
      state = LoginState(isLoading: false, errorMessage: e.toString());
    }
  }
}

// O Provider que vamos usar na tela
final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginViewModel(repo);
});