import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/library_repository.dart';

// Estado da Tela (Carregando, Sucesso, Erro)
class LibraryState {
  final bool isLoading;
  final List<dynamic> courses;
  final String? errorMessage;

  LibraryState({this.isLoading = false, this.courses = const [], this.errorMessage});
}

// ViewModel (Gerencia a lógica)
class LibraryViewModel extends StateNotifier<LibraryState> {
  final LibraryRepository _repository;

  LibraryViewModel(this._repository) : super(LibraryState(isLoading: true)) {
    loadCourses(); // Carrega automaticamente ao iniciar
  }

  Future<void> loadCourses() async {
    try {
      state = LibraryState(isLoading: true, courses: state.courses);
      final courses = await _repository.getLibraryItems();
      state = LibraryState(isLoading: false, courses: courses);
    } catch (e) {
      state = LibraryState(isLoading: false, errorMessage: e.toString());
    }
  }
}

// Provider para usar na tela
final libraryViewModelProvider = StateNotifierProvider<LibraryViewModel, LibraryState>((ref) {
  return LibraryViewModel(ref.watch(libraryRepositoryProvider));
});