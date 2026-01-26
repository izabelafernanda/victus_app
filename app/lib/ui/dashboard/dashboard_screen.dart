import 'dart:developer';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../library/library_screen.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(child: Text("Tela de $title em construção 🚧")),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.dio.get('get_dashboard.php?user_id=1');
      
      if (mounted) {
        setState(() {
          _data = response.data;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      log("Erro Dashboard", error: e, stackTrace: stackTrace, name: "DashboardScreen");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("O que queres registar?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.local_drink, color: Colors.blue),
                title: const Text("Água"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.restaurant, color: Colors.orange),
                title: const Text("Refeição"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.monitor_weight, color: Colors.purple),
                title: const Text("Peso"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 0: break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: "Plano Alimentar")));
        break;
      case 2:
        _showAddOptions(); 
        setState(() => _selectedIndex = 0);
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LibraryScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: "Meu Perfil")));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFCB8B8B))));
    }

    final dailyTip = _data?['daily_tip'] ?? 'Carregando dicas...';
    final weightLost = _data?['weight_lost'] ?? 0;
    final List events = _data?['next_events'] ?? [];
    
    final bool isCristiana = ApiClient.userName == 'Cristiana';

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Olá, ${ApiClient.userName ?? 'Visitante'}", 
                    style: const TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.black87
                    ),
                  ),
                  Row(
                    children: [
                      _buildTopIcon(Icons.groups, false, () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A comunidade abre dia 15!")));
                      }),
                      
                      _buildTopIcon(Icons.notifications, true, () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Notificações"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                ListTile(
                                  leading: Icon(Icons.check_circle, color: Colors.green),
                                  title: Text("Parabéns!"),
                                  subtitle: Text("Completaste a meta de água de ontem."),
                                ),
                                ListTile(
                                  leading: Icon(Icons.video_library, color: Color(0xFFCB8B8B)),
                                  title: Text("Nova Aula"),
                                  subtitle: Text("A aula 'Planeamento' já está disponível."),
                                ),
                              ],
                            ),
                            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Fechar"))],
                          ),
                        );
                      }),

                      _buildTopIcon(Icons.comment, true, () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Mensagens"),
                            content: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                child: const Icon(Icons.person, color: Colors.grey),
                              ),
                              title: const Text("Nutricionista"),
                              subtitle: const Text("Olá! Como te sentiste com o plano desta semana?"),
                            ),
                            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Responder"))],
                          ),
                        );
                      }),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity, height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF4F4), 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 30, right: 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Bem-vinda à minha App!", style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                          const SizedBox(height: 8),
                          const Text(
                            "Clica aqui para iniciares a tua jornada",
                            style: TextStyle(color: Colors.black, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LibraryScreen())),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            child: const Text("Começa aqui", style: TextStyle(fontSize: 12)),
                          )
                        ],
                      ),
                    ),
                    
                    Positioned(
                      right: 0, bottom: 0, 
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20)),
                        child: Image.asset(
                          'assets/header_woman.png',
                          height: 180,
                          fit: BoxFit.fitHeight, 
                          alignment: Alignment.bottomRight, 
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE6B7B7), Color(0xFFF8E8E8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text("LEMBRETE DO DIA:", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text(dailyTip, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(color: const Color(0xFFF8F0F0), borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 100, height: 100,
                                child: CircularProgressIndicator(value: 0.7, strokeWidth: 8, backgroundColor: Colors.grey[300], color: const Color(0xFFD4AF37)),
                              ),
                              Column(
                                children: [
                                  Text("${weightLost}kg", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  const Text("perdidos", style: TextStyle(fontSize: 12)),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF8F0F0), borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Próximos eventos:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 10),
                          if (events.isEmpty) const Text("Sem eventos.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ...events.map((evt) {
                            final title = evt['title'].toString();
                            final isSpecialItem = title.startsWith('+');
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: !isSpecialItem 
                                ? Row( 
                                    children: [
                                      Text(evt['date_label'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      const SizedBox(width: 8),
                                      Container(width: 1, height: 12, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(evt['type'] ?? title, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                    ],
                                  )
                                : Row( 
                                    children: [
                                      Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                                    ],
                                  ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
            icon: Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCristiana ? null : Colors.grey[300], 
                image: isCristiana 
                  ? const DecorationImage(
                      image: AssetImage('assets/profile.png'), 
                      fit: BoxFit.cover,
                    )
                  : null,
              ),
              child: !isCristiana 
                  ? const Icon(Icons.person, size: 18, color: Colors.grey) 
                  : null,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildTopIcon(IconData icon, bool hasBadge, VoidCallback onTap) {
    return Stack(
      children: [
        IconButton(icon: Icon(icon, color: Colors.black87), onPressed: onTap),
        if (hasBadge)
          Positioned(
            right: 8, top: 8,
            child: Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          )
      ],
    );
  }
}