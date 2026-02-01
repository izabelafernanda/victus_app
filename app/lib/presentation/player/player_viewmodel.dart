import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/player_repository.dart';

class PlayerState {
  final bool isLoading;
  final List<dynamic> lessons;
  final int currentLessonIndex;
  final String? errorMessage;
  final int? currentCourseId;

  dynamic get currentLesson => lessons.isNotEmpty && currentLessonIndex < lessons.length 
      ? lessons[currentLessonIndex] 
      : null;

  bool get hasNext => currentLessonIndex < lessons.length - 1;

  PlayerState({
    this.isLoading = false,
    this.lessons = const [],
    this.currentLessonIndex = 0,
    this.errorMessage,
    this.currentCourseId,
  });

  PlayerState copyWith({
    bool? isLoading,
    List<dynamic>? lessons,
    int? currentLessonIndex,
    String? errorMessage,
    int? currentCourseId,
  }) {
    return PlayerState(
      isLoading: isLoading ?? this.isLoading,
      lessons: lessons ?? this.lessons,
      currentLessonIndex: currentLessonIndex ?? this.currentLessonIndex,
      errorMessage: errorMessage ?? this.errorMessage,
      currentCourseId: currentCourseId ?? this.currentCourseId,
    );
  }
}

class PlayerViewModel extends StateNotifier<PlayerState> {
  final PlayerRepository _repository;

  PlayerViewModel(this._repository) : super(PlayerState(isLoading: true));

  Future<void> loadCourse(int courseId) async {
    try {
      // Só mostra loading se a lista estiver vazia (primeira carga)
      if(state.lessons.isEmpty) {
         state = state.copyWith(isLoading: true, currentCourseId: courseId);
      } else {
         state = state.copyWith(currentCourseId: courseId);
      }

      final lessons = await _repository.getCourseContent(courseId);
      
      state = state.copyWith(
        isLoading: false, 
        lessons: lessons,
        // Mantém o índice atual se for apenas um refresh
        currentLessonIndex: state.currentLessonIndex >= lessons.length ? 0 : state.currentLessonIndex
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectLesson(int index) {
    if (index >= 0 && index < state.lessons.length) {
      state = state.copyWith(currentLessonIndex: index);
    }
  }

  // --- Atualização Otimista Segura ---
  void _updateLocalState(int lessonId, Map<String, dynamic> changes) {
    final updatedLessons = state.lessons.map((lesson) {
      // Garante que estamos a alterar APENAS a lição com este ID exato
      if (lesson['id'].toString() == lessonId.toString()) {
        return {...lesson, ...changes};
      }
      return lesson;
    }).toList();

    state = state.copyWith(lessons: updatedLessons);
  }

  Future<bool> toggleFavorite() async {
    final lesson = state.currentLesson;
    if (lesson == null) return false;

    final lessonId = int.tryParse(lesson['id'].toString()) ?? 0;
    final bool currentStatus = (lesson['is_favorited'].toString() == '1');
    final bool newStatus = !currentStatus;
    
    if (lessonId > 0) {
       _updateLocalState(lessonId, {'is_favorited': newStatus ? 1 : 0});
       try { await _repository.toggleFavorite(lessonId); } catch (_) {}
       return newStatus;
    }
    return currentStatus;
  }

  Future<bool> toggleCompletion() async {
    final lesson = state.currentLesson;
    if (lesson == null) return false;

    final lessonId = int.tryParse(lesson['id'].toString()) ?? 0;
    final bool currentStatus = (lesson['is_completed'].toString() == '1');
    final bool newStatus = !currentStatus; // Se estava true vira false, se false vira true

    if (lessonId > 0) {
      // 1. Atualiza visualmente
      _updateLocalState(lessonId, {'is_completed': newStatus ? 1 : 0});

      // 2. Envia ao servidor
      try { await _repository.updateProgress(lessonId, newStatus); } catch (_) {}

      // 3. Se marcou como CONCLUÍDO (não desmarcou), avança
      if (newStatus == true) {
         await _handleAutoAdvance();
      }
      return newStatus;
    }
    return currentStatus;
  }

  Future<void> _handleAutoAdvance() async {
    if (state.hasNext) {
       // Desbloqueia visualmente a próxima aula
       final nextIndex = state.currentLessonIndex + 1;
       final nextLesson = state.lessons[nextIndex];
       final nextId = int.tryParse(nextLesson['id'].toString()) ?? 0;
       
       if (nextId > 0) {
         _updateLocalState(nextId, {'is_locked': 0});
       }

       // Aguarda 1.5s para o usuário ver o check verde antes de mudar
       await Future.delayed(const Duration(milliseconds: 1500));
       
       // Muda de aula (Isto vai disparar o ref.listen na tela)
       selectLesson(nextIndex);
       
       // Sincroniza em background
       if (state.currentCourseId != null) loadCourse(state.currentCourseId!);
    }
  }

  // Chamado pelo player quando o vídeo acaba
  void onVideoFinished() {
    final lesson = state.currentLesson;
    if (lesson != null) {
      final isCompleted = (lesson['is_completed'].toString() == '1');
      if (!isCompleted) {
        toggleCompletion(); // Marca e avança
      } else if (state.hasNext) {
        // Se já estava visto, apenas avança
        selectLesson(state.currentLessonIndex + 1);
      }
    }
  }
}

final playerViewModelProvider = StateNotifierProvider<PlayerViewModel, PlayerState>((ref) {
  return PlayerViewModel(ref.watch(playerRepositoryProvider));
});