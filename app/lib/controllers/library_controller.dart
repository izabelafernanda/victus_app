import '../data/models/library_model.dart';
import '../data/repositories/library_repository.dart';

/// Library Controller - Course items logic
class LibraryController {
  final LibraryRepository _repository = LibraryRepository();

  Future<List<LibraryItem>> getLibraryItems() async {
    final items = await _repository.getLibraryItems();
    if (items.isEmpty) {
      return _getFallbackItems();
    }
    return items;
  }

  List<LibraryItem> _getFallbackItems() {
    return [
      LibraryItem(
        id: 1,
        title: 'Liberdade Alimentar',
        description: 'Aprende a comer sem culpa.',
        imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061',
        progress: 45,
      ),
      LibraryItem(
        id: 2,
        title: 'Planeamento Semanal',
        description: 'Organiza a tua semana.',
        imageUrl: 'https://images.unsplash.com/photo-1484723091739-30a097e8f929',
        progress: 0,
      ),
      LibraryItem(
        id: 3,
        title: 'Receitas Rápidas',
        description: 'Pratos em 15 minutos.',
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
        progress: 0,
      ),
    ];
  }
}
