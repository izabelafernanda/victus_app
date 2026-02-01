import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class MyDataScreen extends StatefulWidget {
  const MyDataScreen({super.key});

  @override
  State<MyDataScreen> createState() => _MyDataScreenState();
}

class _MyDataScreenState extends State<MyDataScreen> {
  String _currentName = '';
  bool _showSuccessBanner = false;

  @override
  void initState() {
    super.initState();
    _currentName = ApiClient.userName ?? '';
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Editar nome"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Nome",
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(context, value.trim().isEmpty ? null : value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              Navigator.pop(context, name.isEmpty ? null : name);
            },
            child: const Text("Guardar", style: TextStyle(color: Color(0xFFCB8B8B), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    final res = await ApiClient().updateUserName(result);
    if (!mounted) return;
    if (res['success'] == true && mounted) {
      setState(() {
        _currentName = result;
        _showSuccessBanner = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showSuccessBanner = false);
      });
    } else {
      final msg = res['message']?.toString() ?? "Não foi possível atualizar o nome. Tenta novamente.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Os meus dados",
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: _buildAvatar(radius: 50),
                ),
                const SizedBox(height: 24),
                _buildDataRow(label: "Nome", value: _currentName, onTap: _editName),
              ],
            ),
          ),
          if (_showSuccessBanner)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFCB8B8B).withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 16,
                        child: Icon(Icons.check, color: Color(0xFFCB8B8B), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Nome atualizado",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required double radius}) {
    final url = ApiClient.userAvatarUrl;
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: radius * 2,
            height: radius * 2,
            color: Colors.grey[300],
            child: Icon(Icons.person, size: radius * 1.2, color: Colors.grey),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.person, size: radius * 1.2, color: Colors.grey),
    );
  }

  Widget _buildDataRow({required String label, required String value, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(width: 6),
            Icon(Icons.edit, size: 14, color: Colors.grey[500]),
          ],
        ),
        subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
