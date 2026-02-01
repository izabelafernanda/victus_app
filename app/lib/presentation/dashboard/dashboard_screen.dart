import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../library/library_screen.dart';
import 'dashboard_viewmodel.dart'; // Importa a ViewModel

// --- Placeholder mantido ---
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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0; // Controla apenas a navegação visual

  // --- Lógica de Navegação (Mantida Localmente pois é UI) ---
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 0: break;
      case 1: Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: "Plano Alimentar"))); break;
      case 2: _showAddOptions(); setState(() => _selectedIndex = 0); break;
      case 3: Navigator.push(context, MaterialPageRoute(builder: (context) => const LibraryScreen())); break;
      case 4: Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: "Meu Perfil"))); break;
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
    // 1. OUVIR A VIEWMODEL (Dados vêm daqui agora)
    final state = ref.watch(dashboardViewModelProvider);
    final bool isCristiana = ApiClient.userName == 'Cristiana';

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFCB8B8B))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CABEÇALHO ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Olá, ${state.userName}", // Dados da ViewModel
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Row(
                    children: [
                      _buildTopIcon(Icons.groups, false, () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A comunidade abre dia 15!")));
                      }),
                      _buildTopIcon(Icons.notifications, true, () => _showNotificationDialog(context)),
                      _buildTopIcon(Icons.comment, true, () => _showMessageDialog(context)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),

              // --- BANNER PRINCIPAL ---
              Container(
                width: double.infinity, height: 180,
                decoration: BoxDecoration(color: const Color(0xFFFAF4F4), borderRadius: BorderRadius.circular(20)),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 30, right: 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Bem-vinda à minha App!", style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                          const SizedBox(height: 8),
                          const Text("Clica aqui para iniciares a tua jornada", style: TextStyle(color: Colors.black, fontSize: 13)),
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
                        child: Image.asset('assets/header_woman.png', height: 180, fit: BoxFit.fitHeight, alignment: Alignment.bottomRight, errorBuilder: (_,__,___) => Container()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- LEMBRETE DO DIA ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE6B7B7), Color(0xFFF8E8E8)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text("LEMBRETE DO DIA:", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text(state.dailyTip, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- PESO E EVENTOS ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD PESO
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
                                  Text("${state.weightLost}kg", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
                  
                  // CARD EVENTOS (CORRIGIDO PARA FEEDBACK)
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
                          
                          if (state.events.isEmpty) 
                            const Text("Sem eventos.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          
                          ...state.events.map((evt) {
                            final title = evt['title'].toString();
                            // Verifica se é o item "+1 evento" ou começa com +
                            final isSpecialItem = title.trim().startsWith('+');
                            
                            if (isSpecialItem) {
                              // --- LÓGICA DO BOTÃO (Feedback da Empresa) ---
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () {
                                    // AÇÃO: Redirecionar para Calendário
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: "Calendário Completo")));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFCB8B8B).withOpacity(0.5))
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFCB8B8B))),
                                        const SizedBox(width: 5),
                                        const Icon(Icons.arrow_forward, size: 14, color: Color(0xFFCB8B8B))
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              // Item Normal de Evento
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                child: Row( 
                                  children: [
                                    Text(evt['date_label'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(width: 8),
                                    Container(width: 1, height: 12, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(evt['type'] ?? title, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              );
                            }
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
      
      // Bottom Bar igual ao original
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFCB8B8B),
        unselectedItemColor: Colors.grey[400],
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Plano'),
          const BottomNavigationBarItem(icon: CircleAvatar(backgroundColor: Color(0xFFCB8B8B), radius: 22, child: Icon(Icons.add, color: Colors.white)), label: ''),
          const BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Biblioteca'),
          BottomNavigationBarItem(
            icon: Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCristiana ? null : Colors.grey[300], 
                image: isCristiana ? const DecorationImage(image: AssetImage('assets/profile.png'), fit: BoxFit.cover) : null,
              ),
              child: !isCristiana ? const Icon(Icons.person, size: 18, color: Colors.grey) : null,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // --- Widgets Auxiliares (Dialogs) ---
  Widget _buildTopIcon(IconData icon, bool hasBadge, VoidCallback onTap) {
    return Stack(
      children: [
        IconButton(icon: Icon(icon, color: Colors.black87), onPressed: onTap),
        if (hasBadge)
          Positioned(right: 8, top: 8, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFFFFD700), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)))),
      ],
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Notificações"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text("Parabéns!"), subtitle: Text("Completaste a meta de água.")),
            ListTile(leading: Icon(Icons.video_library, color: Color(0xFFCB8B8B)), title: Text("Nova Aula"), subtitle: Text("Aula 'Planeamento' disponível.")),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Fechar"))],
      ),
    );
  }

  void _showMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Mensagens"),
        content: ListTile(
          leading: CircleAvatar(backgroundColor: Colors.grey[300], child: const Icon(Icons.person, color: Colors.grey)),
          title: const Text("Nutricionista"),
          subtitle: const Text("Olá! Como te sentiste esta semana?"),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Responder"))],
      ),
    );
  }
}