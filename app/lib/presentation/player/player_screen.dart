import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'player_viewmodel.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final int courseId;
  const PlayerScreen({super.key, required this.courseId});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  int _selectedTabIndex = 0; 
  bool _isVideoLoading = true;
  
  // Usado para garantir que o widget do player é recriado
  int? _playingLessonId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerViewModelProvider.notifier).loadCourse(widget.courseId);
    });
  }

  @override
  void dispose() {
    _disposeVideoControllers();
    super.dispose();
  }

  void _disposeVideoControllers() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController = null;
    _videoPlayerController = null;
  }

  Future<void> _initializePlayer(String? url, int lessonId) async {
    if (url == null || url.isEmpty) return;

    _disposeVideoControllers();
    
    if (mounted) {
      setState(() {
        _isVideoLoading = true;
        _playingLessonId = lessonId; // Força rebuild do widget
      });
    }

    try {
      // 1. Construção Inteligente da URL (Mantém parametros originais e adiciona o ID)
      final originalUri = Uri.parse(url);
      final newParams = Map<String, String>.from(originalUri.queryParameters);
      newParams['lesson_id'] = lessonId.toString(); // Cache Buster
      
      final uri = originalUri.replace(queryParameters: newParams);
      
      print("🎬 A carregar Aula $lessonId: $uri");

      final newVideoController = VideoPlayerController.networkUrl(uri);
      await newVideoController.initialize();
      await newVideoController.seekTo(Duration.zero);

      newVideoController.addListener(() {
        final val = newVideoController.value;
        if (val.isInitialized && !val.isPlaying && val.position >= val.duration) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted) ref.read(playerViewModelProvider.notifier).onVideoFinished();
           });
        }
      });

      final newChewieController = ChewieController(
        videoPlayerController: newVideoController,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        // Configuração visual
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFCB8B8B),
          handleColor: const Color(0xFFCB8B8B),
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white24,
        ),
        errorBuilder: (ctx, err) => const Center(child: Text("Erro ao carregar", style: TextStyle(color: Colors.white))),
      );

      if (mounted) {
        setState(() {
          _videoPlayerController = newVideoController;
          _chewieController = newChewieController;
          _isVideoLoading = false;
        });
      }
    } catch (e) {
      log("Erro Player: $e");
      if (mounted) setState(() => _isVideoLoading = false);
    }
  }

  // --- HANDLERS (Snackbars) ---
  void _handleFavorite() async {
    final bool newState = await ref.read(playerViewModelProvider.notifier).toggleFavorite();
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newState ? "Adicionado aos Favoritos! ⭐" : "Removido dos Favoritos."),
        backgroundColor: const Color(0xFFCB8B8B),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleCompletion() async {
    final bool newState = await ref.read(playerViewModelProvider.notifier).toggleCompletion();
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newState ? "Aula Concluída! 🎉" : "Aula desmarcada."),
        backgroundColor: newState ? Colors.green : Colors.grey[800],
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerViewModelProvider);
    final currentLesson = state.currentLesson;

    // --- ESCUTAR MUDANÇAS (Corrigido) ---
    ref.listen(playerViewModelProvider, (previous, next) {
      // Lógica robusta para detectar mudança
      final prevIndex = previous?.currentLessonIndex;
      final nextIndex = next.currentLessonIndex;
      final nextUrl = next.currentLesson?['video_url'];
      
      // Pega o ID para usar no Cache Buster
      final nextIdStr = next.currentLesson?['id'];
      final int nextId = int.tryParse(nextIdStr.toString()) ?? 0;

      // Se é a primeira carga OU se o índice mudou
      if (prevIndex != nextIndex || (previous?.isLoading == true && !next.isLoading)) {
        if (nextUrl != null) {
          _initializePlayer(nextUrl, nextId);
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Liberdade Alimentar", style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- ÁREA DO VÍDEO ---
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.black,
            child: _isVideoLoading || state.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFCB8B8B)))
                : _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                    ? Chewie(
                        // Key ÚNICA baseada no ID da aula
                        key: ValueKey(_playingLessonId), 
                        controller: _chewieController!
                      )
                    : _buildVideoPlaceholder(),
          ),
          
          // --- CONTEÚDO ---
          Expanded(
            child: state.isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFCB8B8B)))
              : currentLesson == null
                  ? const Center(child: Text("Nenhuma aula encontrada.", style: TextStyle(color: Colors.white)))
                  : _buildTabContent(currentLesson, state.lessons, state.currentLessonIndex),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomTabs(),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.tv_off, color: Colors.grey, size: 40),
             SizedBox(height: 8),
             Text("A carregar vídeo...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(dynamic currentLesson, List<dynamic> allLessons, int currentIndex) {
    if (_selectedTabIndex != 0) return Center(child: Text("Em breve...", style: TextStyle(color: Colors.grey)));

    final bool isFavorited = (currentLesson['is_favorited'].toString() == '1');
    final bool isCompleted = (currentLesson['is_completed'].toString() == '1');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(currentLesson['title'] ?? 'Aula', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDynamicIconButton(isActive: isFavorited, tooltip: "Favoritos", activeIcon: Icons.favorite, inactiveIcon: Icons.favorite_border, onTap: _handleFavorite),
                _buildDynamicIconButton(isActive: isCompleted, tooltip: "Concluir", activeIcon: Icons.check_circle, inactiveIcon: Icons.check_circle_outline, onTap: _handleCompletion),
              ],
            )
          ],
        ),
        const SizedBox(height: 10),
        Text(currentLesson['description'] ?? "", style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        const SizedBox(height: 20),
        
        ...allLessons.asMap().entries.map((entry) {
          int index = entry.key;
          Map lesson = entry.value;
          bool isCurrent = index == currentIndex;
          bool isLocked = (lesson['is_locked'].toString() == '1');
          bool isItemCompleted = (lesson['is_completed'].toString() == '1');

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isCurrent ? Colors.grey[900] : Colors.black,
              border: Border.all(color: isCurrent ? const Color(0xFFCB8B8B) : Colors.grey[800]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              onTap: isLocked 
                ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aula bloqueada!"), duration: Duration(seconds: 1))) 
                : () => ref.read(playerViewModelProvider.notifier).selectLesson(index),
              leading: isLocked
                  ? const Icon(Icons.lock_outline, color: Colors.grey)
                  : isItemCompleted 
                      ? const Icon(Icons.check_circle, color: Color(0xFFCB8B8B)) 
                      : Icon(Icons.play_circle_outline, color: isCurrent ? Colors.white : Colors.grey),
              title: Text(
                "${index + 1} | ${lesson['title']}", 
                style: TextStyle(
                  color: isLocked ? Colors.grey : Colors.white, 
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal
                )
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDynamicIconButton({required bool isActive, required String tooltip, required IconData activeIcon, required IconData inactiveIcon, required VoidCallback onTap}) {
    return Tooltip(message: tooltip, child: IconButton(icon: Icon(isActive ? activeIcon : inactiveIcon, color: isActive ? const Color(0xFFCB8B8B) : Colors.white), onPressed: onTap));
  }
  
  Widget _buildBottomTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(0, Icons.play_circle_outline, "Aulas"),
          _buildTabItem(1, Icons.chat_bubble_outline, "Comentários"),
          _buildTabItem(2, Icons.edit_note, "Anotações"),
          _buildTabItem(3, Icons.attach_file, "Materiais"),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final bool isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? const Color(0xFFCB8B8B) : Colors.grey[400]),
          Text(label, style: TextStyle(color: isActive ? const Color(0xFFCB8B8B) : Colors.grey[400], fontSize: 10)),
        ],
      ),
    );
  }
}