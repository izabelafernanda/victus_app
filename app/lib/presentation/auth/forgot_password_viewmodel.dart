import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

// 1. O Estado da Tela
class ForgotPasswordState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  ForgotPasswordState({
    this.isLoading = false, 
    this.errorMessage, 
    this.isSuccess = false
  });

  // Método auxiliar para atualizar o estado mantendo os outros valores
  ForgotPasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Se passar null, limpa o erro
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// 2. A Lógica (ViewModel)
class ForgotPasswordViewModel extends StateNotifier<ForgotPasswordState> {
  final AuthRepository _repository;

  ForgotPasswordViewModel(this._repository) : super(ForgotPasswordState());

  Future<void> sendRecoveryEmail(String email) async {
    // Começa o loading e limpa erros antigos
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    try {
      // Chama o repositório (que já trata o JSON success: true/false)
      await _repository.recoverPassword(email);
      
      // Se não deu erro no repositório, foi sucesso
      state = state.copyWith(isLoading: false, isSuccess: true);
      
    } catch (e) {
      // Se o repositório lançou erro (ex: "Email não existe"), capturamos aqui
      state = state.copyWith(
        isLoading: false, 
        errorMessage: e.toString(),
        isSuccess: false
      );
    }
  }

  // Método para limpar o estado quando fechas o Dialog
  void reset() {
    state = ForgotPasswordState();
  }
}

// 3. O Provider Global
final forgotPasswordViewModelProvider = StateNotifierProvider<ForgotPasswordViewModel, ForgotPasswordState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ForgotPasswordViewModel(repository);
});