import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart'; // Import corrigido
import '../models/dashboard_model.dart';

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository());

class DashboardRepository {
  final ApiClient _client = ApiClient();

  Future<DashboardModel> getDashboardData() async {
    try {
      final response = await _client.dio.get('dashboard.php'); // Usa o endpoint novo

      if (response.statusCode == 200) {
        return DashboardModel.fromJson(response.data);
      } else {
        throw Exception("Falha ao carregar dashboard");
      }
    } catch (e) {
      throw Exception("Erro: $e");
    }
  }
}