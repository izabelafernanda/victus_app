import 'package:dio/dio.dart';
import '../../core/api_client.dart'; // Certifique-se que o caminho está certo
import '../models/dashboard_model.dart';

class DashboardRepository {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardData?> getDashboardData() async {
    try {
      // Chama o endpoint que criamos
      final response = await _apiClient.dio.get('get_dashboard.php?user_id=1');

      if (response.statusCode == 200) {
        return DashboardData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("Erro ao buscar dashboard: $e");
      return null;
    }
  }
}