import '../core/api_client.dart';

/// Dashboard Controller - Home data logic
class DashboardController {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>?> fetchDashboard() async {
    try {
      final response = await _api.dio.get('get_dashboard.php?user_id=1');
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
