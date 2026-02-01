import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod
import '../dashboard/dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import '../common/custom_input.dart'; // O teu novo componente
import 'login_viewmodel.dart'; // A tua nova ViewModel

// Trocamos StatefulWidget por ConsumerStatefulWidget para usar Riverpod + Dispose
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Para validar os CustomInputs

  bool _isObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- MANTIVE A TUA LÓGICA DO MODAL DE TERMOS ---
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
                        // ... Podes adicionar o resto do texto aqui se quiseres
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

  @override
  Widget build(BuildContext context) {
    // 1. "Assistir" o estado do login via Riverpod
    final loginState = ref.watch(loginViewModelProvider);

    // 2. Escutar mudanças de estado (Sucesso ou Erro)
    ref.listen(loginViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.isSuccess) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    });

    return Scaffold(
      body: Container(
        // Mantive o teu gradiente
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
                      child: Form( // Adicionei o Form para validar
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Botão Voltar
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

                            // --- USANDO O NOVO COMPONENTE (CustomInput) ---
                            const Text("Email", style: TextStyle(fontSize: 14, color: Colors.black87)),
                            const SizedBox(height: 8),
                            CustomInput(
                              controller: _emailController,
                              hintText: "exemploemail@gmail.com",
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) => val!.isEmpty ? "Insere o email" : null,
                            ),

                            const SizedBox(height: 20),

                            // --- USANDO O NOVO COMPONENTE (CustomInput) ---
                            const Text("Palavra-passe", style: TextStyle(fontSize: 14, color: Colors.black87)),
                            const SizedBox(height: 8),
                            CustomInput(
                              controller: _passwordController,
                              hintText: "Inserir palavra-passe",
                              obscureText: _isObscure,
                              validator: (val) => val!.isEmpty ? "Insere a senha" : null,
                              suffixIcon: IconButton(
                                icon: Icon(_isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                                onPressed: () => setState(() => _isObscure = !_isObscure),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // --- BOTÃO DE LOGIN CONECTADO AO VIEWMODEL ---
                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: loginState.isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          // Chama a lógica na ViewModel (Riverpod)
                                          ref.read(loginViewModelProvider.notifier).login(
                                            _emailController.text.trim(),
                                            _passwordController.text.trim(),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE6B7B7),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: loginState.isLoading
                                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text("Entrar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Links de Esqueci a Senha e Criar Conta
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
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
                            const SizedBox(height: 24),
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                                child: RichText(
                                  text: TextSpan(
                                    text: "Ainda não tens conta? ",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    children: const [
                                      TextSpan(text: "Criar nova conta", style: TextStyle(color: Color(0xFFCB8B8B), fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Link dos Termos (Mantido)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20, top: 20),
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
                          ],
                        ),
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