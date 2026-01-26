import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../core/api_client.dart';

class PlayerScreen extends StatefulWidget {
  final int courseId;

  const PlayerScreen({super.key, required this.courseId});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  
  bool _isLoading = true;
  List<dynamic> _lessons = [];
  int _currentLessonIndex = 0;
  int _selectedTabIndex = 0; 

  bool _isRated = false;
  bool _isFavorited = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadCourseContent();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _loadCourseContent() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.dio.get('get_course_content.php?course_id=${widget.courseId}');

      List<dynamic> lessonsData = [];
      if (response.data is List) {
        lessonsData = response.data;
      } else if (response.data is Map && response.data['data'] is List) {
        lessonsData = response.data['data'];
      }

      if (response.statusCode == 200 && lessonsData.isNotEmpty) {
        if (mounted) {
          setState(() {
            _lessons = lessonsData;
          });
          if (_lessons[0]['video_url'] != null) {
            _initializePlayer(_lessons[0]['video_url']);
          }
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e, stackTrace) {
      log("Erro Player", error: e, stackTrace: stackTrace, name: "PlayerScreen");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _initializePlayer(String? url) async {
    setState(() {
      _isLoading = true;
    });

    final oldChewie = _chewieController;
    final oldVideo = _videoPlayerController;
    
    _chewieController = null;
    _videoPlayerController = null;

    try {
        if (oldChewie != null) oldChewie.dispose();
        if (oldVideo != null) await oldVideo.dispose();
    } catch(e) {
        log("Erro ao limpar controladores antigos: $e");
    }

    if (url == null || url.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vídeo indisponível no momento.")),
        );
      }
      return;
    }

    try {
      final newVideoController = VideoPlayerController.networkUrl(Uri.parse(url));
      
      await newVideoController.initialize();

      final newChewieController = ChewieController(
        videoPlayerController: newVideoController,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        allowFullScreen: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text("Erro no vídeo: $errorMessage", style: const TextStyle(color: Colors.white)),
          );
        },
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFCB8B8B),
          handleColor: const Color(0xFFCB8B8B),
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white24,
        ),
      );

      if (mounted) {
        setState(() {
          _videoPlayerController = newVideoController;
          _chewieController = newChewieController;
          _isLoading = false;
        });
      }

    } catch (e, stackTrace) {
      log("Erro ao inicializar player", error: e, stackTrace: stackTrace, name: "PlayerScreen");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Não foi possível carregar este vídeo.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLesson = _lessons.isNotEmpty ? _lessons[_currentLessonIndex] : null;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              "Liberdade Alimentar",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(2)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.8,
                    child: Container(
                      decoration: BoxDecoration(color: const Color(0xFFCB8B8B), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text("80%", style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            )
          ],
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.black,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFCB8B8B)))
                : _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : Stack(
                        alignment: Alignment.center,
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            "https://images.unsplash.com/photo-1490645935967-10de6ba17061",
                            fit: BoxFit.cover,
                            color: Colors.black.withOpacity(0.6),
                            colorBlendMode: BlendMode.darken,
                          ),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: Colors.white, size: 40),
                              SizedBox(height: 10),
                              Text("Vídeo não disponível", style: TextStyle(color: Colors.white)),
                            ],
                          )
                        ],
                      ),
          ),

          Expanded(
            child: currentLesson == null
                ? const Center(child: Text("Sem aulas", style: TextStyle(color: Colors.white)))
                : _buildTabContent(currentLesson),
          ),
        ],
      ),

      bottomNavigationBar: Container(
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
      ),
    );
  }

  Widget _buildTabContent(Map currentLesson) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildLessonsTab(currentLesson);
      case 1:
        return _buildPlaceholder("Comentários da aula aparecerão aqui.");
      case 2:
        return _buildPlaceholder("Suas anotações pessoais.");
      case 3:
        return _buildPlaceholder("Arquivos e materiais complementares.");
      default:
        return Container();
    }
  }

  Widget _buildPlaceholder(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[400], fontSize: 16),
      ),
    );
  }

  Widget _buildLessonsTab(Map currentLesson) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                currentLesson['title'] ?? 'Aula',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDynamicIconButton(
                  isActive: _isRated,
                  activeIcon: Icons.star,
                  inactiveIcon: Icons.star_border,
                  onTap: () => setState(() => _isRated = !_isRated),
                ),
                _buildDynamicIconButton(
                  isActive: _isFavorited,
                  activeIcon: Icons.favorite,
                  inactiveIcon: Icons.favorite_border,
                  onTap: () => setState(() => _isFavorited = !_isFavorited),
                ),
                _buildDynamicIconButton(
                  isActive: _isCompleted,
                  activeIcon: Icons.check_circle,
                  inactiveIcon: Icons.check_circle_outline,
                  onTap: () => setState(() => _isCompleted = !_isCompleted),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 10),

        Text(
          currentLesson['description'] ?? "",
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Próxima aula", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("Métodos e princípios", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              Spacer(),
              Icon(Icons.play_circle_fill, color: Color(0xFFD4AF37), size: 30),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ..._lessons.asMap().entries.map((entry) {
          int index = entry.key;
          Map lesson = entry.value;
          bool isCurrent = index == _currentLessonIndex;
          bool isLocked = lesson['is_locked'] == 1; 
          bool isCompleted = lesson['is_completed'] == 1;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              onTap: isLocked
                  ? null
                  : () {
                      if (isCurrent) return; 
                      setState(() => _currentLessonIndex = index);
                      _initializePlayer(lesson['video_url']);
                    },
              leading: isLocked
                  ? const Icon(Icons.lock_outline, color: Colors.grey)
                  : isCompleted
                      ? const Icon(Icons.check_circle, color: Color(0xFFCB8B8B))
                      : Icon(Icons.play_circle_outline, color: isCurrent ? Colors.white : Colors.grey),
              title: Text(
                "${index + 1} | ${lesson['title']}",
                style: TextStyle(
                  color: isCurrent || !isLocked ? Colors.white : Colors.grey,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDynamicIconButton({
    required bool isActive,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(
        isActive ? activeIcon : inactiveIcon,
        color: isActive ? const Color(0xFFCB8B8B) : Colors.white,
      ),
      onPressed: onTap,
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final bool isActive = _selectedTabIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent, 
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFCB8B8B) : Colors.grey[400],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFFCB8B8B) : Colors.grey[400],
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}