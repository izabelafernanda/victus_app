import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../models/library_model.dart';

class LibraryRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<LibraryItem>> getLibraryItems() async {
    try {
      final response = await _apiClient.dio.get('get_library.php');

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => LibraryItem.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print("Erro Biblioteca: $e");
      return [];
    }
  }
}