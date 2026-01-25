import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../dashboard/dashboard_screen.dart';
import 'forgot_password_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showTermsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7, 
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                  const Text("Termos e Política de Privacidade", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: const [
                        Text("1. Introdução", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Bem-vindo à Victus. Ao utilizar a nossa aplicação, concordas com a recolha e uso das tuas informações de acordo com esta política.\n"),
                        Text("2. Dados Recolhidos", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Recolhemos dados como nome, e-mail e preferências de treino para personalizar a tua experiência.\n"),
                        Text("3. Segurança", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Valorizamos a tua confiança ao nos fornecer os teus dados pessoais, e esforçamo-nos por usar meios comercialmente aceitáveis para os proteger.\n"),
                        Text("4. Alterações", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Podemos atualizar a nossa Política de Privacidade periodicamente. Recomendamos que revejas esta página regularmente."),
                        SizedBox(height: 40), 
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                      child: const Text("Entendi"),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus(); 

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preenche todos os campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiClient = ApiClient();
      final response = await apiClient.post(
        'auth_login.php', 
        data: {
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Erro de login');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro: ${e.toString().replaceAll('Exception:', '')}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF0F0), Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.black),
                                onPressed: () => Navigator.pop(context), 
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Text("Entra na tua conta", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 50),
                          const Text("Email", style: TextStyle(fontSize: 14, color: Colors.black87)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: "exemploemail@gmail.com",
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCB8B8B))),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text("Palavra-passe", style: TextStyle(fontSize: 14, color: Colors.black87)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                              hintText: "Inserir palavra-passe",
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCB8B8B))),
                              suffixIcon: IconButton(
                                icon: Icon(_isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                                onPressed: () => setState(() => _isObscure = !_isObscure),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE6B7B7), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                              child: _isLoading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Entrar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          Center(
                            child: MouseRegion( 
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: "Esqueceste-te da palavra-passe? ",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    children: const [
                                      TextSpan(text: "Recuperar", style: TextStyle(color: Color(0xFFCB8B8B), fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 20, top: 20),
                            child: MouseRegion( 
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: _showTermsModal,
                                child: Column(
                                  children: [
                                    Text("Ao utilizares a Victus, aceitas os nossos", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                    const SizedBox(height: 4),
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: const TextSpan(
                                        text: "Termos",
                                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
                                        children: [
                                          TextSpan(text: " e ", style: TextStyle(fontWeight: FontWeight.normal)),
                                          TextSpan(text: "Política de Privacidade", style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: ".", style: TextStyle(fontWeight: FontWeight.normal)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}