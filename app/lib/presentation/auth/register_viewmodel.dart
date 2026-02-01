import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

// Reutilizamos o LoginState ou criamos um RegisterState (vamos simplificar e usar uma classe simples)
class RegisterState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  RegisterState({this.isLoading = false, this.errorMessage, this.isSuccess = false});
}

class RegisterViewModel extends StateNotifier<RegisterState> {
  final AuthRepository _repository;

  RegisterViewModel(this._repository) : super(RegisterState());

  Future<void> register(String name, String email, String password) async {
    state = RegisterState(isLoading: true);

    try {
      await _repository.register(name, email, password);
      state = RegisterState(isSuccess: true, isLoading: false);
    } catch (e) {
      state = RegisterState(isLoading: false, errorMessage: e.toString());
    }
  }
}

final registerViewModelProvider = StateNotifierProvider<RegisterViewModel, RegisterState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return RegisterViewModel(repo);
});