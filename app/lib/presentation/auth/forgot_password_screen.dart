import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/custom_input.dart';
import 'forgot_password_viewmodel.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Observa o estado (Loading, Erro, Sucesso)
    final state = ref.watch(forgotPasswordViewModelProvider);

    // Escuta mudanças de estado para mostrar SnackBar ou Dialog
    ref.listen(forgotPasswordViewModelProvider, (previous, next) {
      // 1. Tratamento de Erro
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!), 
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      // 2. Tratamento de Sucesso
      if (next.isSuccess) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Email Enviado"),
            // --- AJUSTE AQUI: Mensagem limpa para o utilizador ---
            content: const Text("Verifica a tua caixa de entrada para recuperares a palavra-passe."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Fecha o Dialog
                  Navigator.pop(context); // Volta para o Login
                  // Reseta o estado para limpar a mensagem de sucesso
                  ref.read(forgotPasswordViewModelProvider.notifier).reset();
                },
                child: const Text("Ok"),
              )
            ],
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Recuperar Palavra-passe",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Insere o teu email para receberes as instruções de recuperação.",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 30),
              
              CustomInput(
                controller: _emailController,
                hintText: "Email",
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val!.isEmpty) return "Insere o email";
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return "Email inválido";
                  return null;
                },
              ),

              const SizedBox(height: 30),
              
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            ref.read(forgotPasswordViewModelProvider.notifier)
                               .sendRecoveryEmail(_emailController.text.trim());
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCB8B8B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: state.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Enviar Email"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}