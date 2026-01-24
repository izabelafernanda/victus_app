import 'package:flutter/material.dart';
import '../../data/models/library_model.dart';
import '../../data/repositories/library_repository.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryRepository _repository = LibraryRepository();
  List<LibraryItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await _repository.getLibraryItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Biblioteca",
          style: TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.bold,
            fontSize: 24
          ),
        ),
        automaticallyImplyLeading: false, // Remove botão de voltar automático
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final item = _items[index];
                return _buildLibraryCard(item);
              },
            ),
      // MANTEMOS A NAVBAR PARA NAVEGAR
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Índice da Biblioteca
        selectedItemColor: const Color(0xFFCB8B8B),
        unselectedItemColor: Colors.grey[400],
        onTap: (index) {
          if (index == 0) Navigator.pop(context); // Volta para Dashboard
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Plano'),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: Color(0xFFCB8B8B),
              child: Icon(Icons.add, color: Colors.white),
            ),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildLibraryCard(LibraryItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Fundo branco
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // 1. IMAGEM (Quadrada à esquerda)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              item.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100, height: 100, color: Colors.grey[300], 
                child: const Icon(Icons.image_not_supported)
              ),
            ),
          ),
          
          // 2. TEXTOS (Título e Descrição)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Se tiver progresso > 0, mostra barra. Se não, mostra descrição
                  if (item.progress > 0) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: item.progress / 100,
                      backgroundColor: const Color(0xFFF0F0F0),
                      color: const Color(0xFFCB8B8B), // Rosa Victus
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${item.progress}%",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.right,
                    )
                  ] else
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 12, 
                        color: Colors.grey
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}