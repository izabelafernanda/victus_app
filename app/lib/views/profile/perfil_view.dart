import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import 'my_data_view.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  @override
  Widget build(BuildContext context) {
    final name = ApiClient.userName ?? 'Utilizador';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("Perfil", style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(radius: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyDataView())).then((_) => setState(() {})),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text("Editar nome", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text("Configuração", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            _buildConfigTile(
              context,
              icon: Icons.person_outline,
              label: "Os meus dados",
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const MyDataView()));
                if (mounted) setState(() {});
              },
            ),
          ],
        ),
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
    return CircleAvatar(radius: radius, backgroundColor: Colors.grey[300], child: Icon(Icons.person, size: radius * 1.2, color: Colors.grey));
  }

  Widget _buildConfigTile(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFCB8B8B), size: 22),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
