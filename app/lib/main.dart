import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Importante para o Riverpod
// 2. Caminho corrigido de 'ui' para 'presentation'
import 'presentation/auth/login_screen.dart'; 

void main() {
  runApp(
    // 3. O ProviderScope é obrigatório para o Riverpod funcionar!
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Victus App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Configuração de cores baseada no teu design
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCB8B8B),
          primary: const Color(0xFFCB8B8B),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDFDFD),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black, 
            fontSize: 20, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      // Aponta para a tela de Login que agora está na pasta certa
      home: const LoginScreen(),
    );
  }
}