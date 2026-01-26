import 'dart:developer'; 
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
    } catch (e, stackTrace) { 
      
      log(
        'Falha ao carregar itens da biblioteca', 
        name: 'LibraryRepository', 
        error: e, 
        stackTrace: stackTrace
      );
      
      return [];
    }
  }
}