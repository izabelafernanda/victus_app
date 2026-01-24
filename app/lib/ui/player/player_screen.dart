import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCourseContent();
  }

  Future<void> _loadCourseContent() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.dio.get('get_course_content.php?course_id=${widget.courseId}');

      if (response.statusCode == 200 && (response.data as List).isNotEmpty) {
        setState(() {
          _lessons = response.data;
        });
        _initializePlayer(_lessons[0]['video_url']);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Erro Player: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _initializePlayer(String url) async {
    if (_videoPlayerController != null) {
      await _videoPlayerController!.dispose();
      _chewieController?.dispose();
    }

    if (url.isEmpty) return; 

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      allowFullScreen: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFCB8B8B), 
        handleColor: const Color(0xFFCB8B8B),
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white24,
      ),
    );

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
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
                  width: 100,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.8, 
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFCB8B8B),
                        borderRadius: BorderRadius.circular(2),
                      ),
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

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFCB8B8B)))
          : currentLesson == null 
              ? const Center(child: Text("Sem aulas", style: TextStyle(color: Colors.white)))
              : Column(
                  children: [
                    Container(
                      height: 220,
                      color: Colors.black,
                      child: _chewieController != null
                          ? Chewie(controller: _chewieController!)
                          : Image.network(
                              "https://images.unsplash.com/photo-1490645935967-10de6ba17061", 
                              fit: BoxFit.cover,
                            ),
                    ),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currentLesson['title'],
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontSize: 20, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              const Row(
                                children: [
                                  Icon(Icons.star_border, color: Colors.white),
                                  SizedBox(width: 10),
                                  Icon(Icons.favorite_border, color: Colors.white),
                                  SizedBox(width: 10),
                                  Icon(Icons.check_circle, color: Color(0xFFCB8B8B)), 
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          
                          Text(
                            currentLesson['description'],
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          ),
                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(30), 
                            ),
                            child: Row(
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Próxima aula", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    Text("Métodos e princípios", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(Icons.play_circle_fill, color: Color(0xFFD4AF37), size: 30), 
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
                                onTap: isLocked ? null : () {
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
                      ),
                    ),
                  ],
                ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: Colors.white, 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(Icons.play_circle_outline, "Aulas", isActive: true),
            _buildTabItem(Icons.chat_bubble_outline, "Comentários"),
            _buildTabItem(Icons.edit_note, "Anotações"),
            _buildTabItem(Icons.attach_file, "Materiais"),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? const Color(0xFFCB8B8B) : Colors.grey[400]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFFCB8B8B) : Colors.grey[400],
            fontSize: 10,
          ),
        )
      ],
    );
  }
}