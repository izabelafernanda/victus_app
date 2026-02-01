import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/dashboard_screen.dart';
import '../common/custom_input.dart'; // O teu novo componente
import 'register_viewmodel.dart'; // A nova ViewModel (que criámos no passo anterior)

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Para validação
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Observar o estado do Registo (Loading, Sucesso, Erro)
    final registerState = ref.watch(registerViewModelProvider);

    // 2. Ouvir mudanças para navegar ou mostrar erro
    ref.listen(registerViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
      if (next.isSuccess) {
        // Navegar para o Dashboard removendo o histórico
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar nova conta"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Nome Completo"),
              const SizedBox(height: 8),
              
              // USANDO O NOVO COMPONENTE CUSTOM INPUT
              CustomInput(
                controller: _nameController,
                hintText: "O teu nome",
                validator: (val) => val!.isEmpty ? "Insere o nome" : null,
              ),

              const SizedBox(height: 20),
              
              const Text("Email"),
              const SizedBox(height: 8),
              CustomInput(
                controller: _emailController,
                hintText: "exemplo@email.com",
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                   if(val!.isEmpty) return "Insere o email";
                   // Validação simples de regex
                   if(!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return "Email inválido";
                   return null;
                },
              ),

              const SizedBox(height: 20),
              
              const Text("Palavra-passe"),
              const SizedBox(height: 8),
              CustomInput(
                controller: _passwordController,
                hintText: "Cria uma senha segura",
                obscureText: _obscurePassword,
                validator: (val) => val!.isEmpty ? "Insere a senha" : null,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 30),
              
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: registerState.isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            // CHAMA A VIEWMODEL (AQUI ESTÁ A MÁGICA)
                            // Em vez de chamar ApiClient, pedimos à ViewModel para registar
                            ref.read(registerViewModelProvider.notifier).register(
                              _nameController.text.trim(),
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCB8B8B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: registerState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Criar Conta"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}