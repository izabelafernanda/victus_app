import 'dart:developer'; 
import '../../core/api_client.dart'; 
import '../models/dashboard_model.dart';

class DashboardRepository {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardData?> getDashboardData() async {
    try {
      final response = await _apiClient.dio.get('get_dashboard.php?user_id=1');

      if (response.statusCode == 200) {
        return DashboardData.fromJson(response.data);
      }
      return null;
    } catch (e, stackTrace) { 
      
      log(
        'Erro ao buscar dados do dashboard',
        name: 'DashboardRepository',
        error: e,
        stackTrace: stackTrace,
      );
      
      return null;
    }
  }
}