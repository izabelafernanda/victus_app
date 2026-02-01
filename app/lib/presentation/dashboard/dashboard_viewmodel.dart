import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../core/api_client.dart'; // Para acessar o userName global

// Estado do Dashboard
class DashboardState {
  final bool isLoading;
  final String userName;
  final String dailyTip;
  final double weightLost;
  final List<dynamic> events;
  final String? errorMessage;

  DashboardState({
    this.isLoading = false,
    this.userName = '',
    this.dailyTip = '',
    this.weightLost = 0,
    this.events = const [],
    this.errorMessage,
  });
}

class DashboardViewModel extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardViewModel(this._repository) : super(DashboardState(isLoading: true)) {
    loadData();
  }

  Future<void> loadData() async {
    try {
      state = DashboardState(isLoading: true);
      
      final data = await _repository.getDashboardData();

      state = DashboardState(
        isLoading: false,
        userName: ApiClient.userName ?? 'Visitante',
        
        // CORREÇÃO: Acessar propriedades do objeto DashboardModel
        dailyTip: data.dailyTip?.message ?? 'Dica indisponível hoje.',
        weightLost: data.weightLost, // Agora vem como double do PHP
        events: data.events,
      );
    } catch (e) {
      state = DashboardState(isLoading: false, errorMessage: "Erro: $e");
    }
  }
}

// O Provider deve estar aqui ou no ficheiro do repositório
final dashboardViewModelProvider = StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  // Certifica-te que o dashboardRepositoryProvider está importado ou definido
  return DashboardViewModel(ref.watch(dashboardRepositoryProvider));
});