import 'package:flutter/material.dart';
import '../../data/models/library_model.dart';
import '../../data/repositories/library_repository.dart';
import '../../core/api_client.dart'; 
import '../player/player_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/perfil_screen.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, style: const TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black), elevation: 0),
      body: Center(child: Text("Tela de $title em construção 🚧")),
    );
  }
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryRepository _repository = LibraryRepository();
  List<LibraryItem> _items = [];
  bool _isLoading = true;
  int _selectedIndex = 3;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final items = await _repository.getLibraryItems();
      
      if (mounted) {
        setState(() {
          if (items.isEmpty) {
            _items = _getFakeItems();
          } else {
            _items = items;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _items = _getFakeItems();
          _isLoading = false;
        });
      }
    }
  }

  List<LibraryItem> _getFakeItems() {
    return [
      LibraryItem(id: 1, title: 'Liberdade Alimentar', description: 'Aprende a comer sem culpa.', imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061', progress: 45),
      LibraryItem(id: 2, title: 'Planeamento Semanal', description: 'Organiza a tua semana.', imageUrl: 'https://images.unsplash.com/photo-1484723091739-30a097e8f929', progress: 0),
      LibraryItem(id: 3, title: 'Receitas Rápidas', description: 'Pratos em 15 minutos.', imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd', progress: 0),
    ];
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0: 
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
        break;
      case 1: 
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: "Plano Alimentar")));
        break;
      case 2: 
        _showAddOptions();
        setState(() => _selectedIndex = 3); 
        break;
      case 3: 
        break;
      case 4: 
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PerfilScreen()));
        break;
    }
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("O que queres registar?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(leading: const Icon(Icons.local_drink, color: Colors.blue), title: const Text("Água"), onTap: () => Navigator.pop(context)),
              ListTile(leading: const Icon(Icons.restaurant, color: Colors.orange), title: const Text("Refeição"), onTap: () => Navigator.pop(context)),
              ListTile(leading: const Icon(Icons.monitor_weight, color: Colors.purple), title: const Text("Peso"), onTap: () => Navigator.pop(context)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAvatarFromDb = ApiClient.userAvatarUrl != null && ApiClient.userAvatarUrl!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Biblioteca", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        automaticallyImplyLeading: false, 
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFCB8B8B)))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = _items[index];
                return _buildLibraryCard(item, index);
              },
            ),
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFCB8B8B),
        unselectedItemColor: Colors.grey[400],
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Plano'),
          const BottomNavigationBarItem(
            icon: CircleAvatar(backgroundColor: Color(0xFFCB8B8B), radius: 22, child: Icon(Icons.add, color: Colors.white)),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Biblioteca'),
          
          BottomNavigationBarItem(
            icon: ClipOval(
              child: SizedBox(
                width: 26,
                height: 26,
                child: hasAvatarFromDb
                  ? Image.network(
                      ApiClient.userAvatarUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Image.asset('assets/profile.png', fit: BoxFit.cover),
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/profile.png',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset('assets/profile.png', fit: BoxFit.cover),
              ),
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryCard(LibraryItem item, int index) {
    final isUnlocked = index == 0; 
    final isHovering = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (isUnlocked) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(courseId: item.id)));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Disponível em breve!"), duration: Duration(milliseconds: 800)));
          }
        },
        child: Container(
          height: 110, 
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                    child: Image.network(
                      item.imageUrl,
                      width: 110, height: 110, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 110, color: Colors.grey[200], child: const Icon(Icons.image)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          if (isUnlocked && item.progress > 0) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(3)),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: item.progress / 100,
                                      child: Container(decoration: BoxDecoration(color: const Color(0xFFCB8B8B), borderRadius: BorderRadius.circular(3))),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text("${item.progress}%", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))
                              ],
                            ),
                          ] else
                            Text(item.description, style: const TextStyle(fontSize: 13, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (!isUnlocked && isHovering)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Text("EM BREVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5))),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}