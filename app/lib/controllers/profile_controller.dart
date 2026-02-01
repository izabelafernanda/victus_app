import '../core/api_client.dart';

/// Profile Controller - User profile logic
class ProfileController {
  final ApiClient _api = ApiClient();

  String get currentName => ApiClient.userName ?? '';

  Future<Map<String, dynamic>> updateUserName(String name) async {
    return _api.updateUserName(name);
  }
}
