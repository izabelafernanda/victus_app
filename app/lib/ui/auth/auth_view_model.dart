import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final UserModel? user;

  AuthState({this.isLoading = false, this.error, this.user});
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthViewModel(this._repository) : super(AuthState());

  Future<bool> login(String email, String password) async {
    state = AuthState(isLoading: true);

    try {
      final user = await _repository.login(email, password);
      
      state = AuthState(isLoading: false, user: user);
      return true;

    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.read(authRepositoryProvider));
});