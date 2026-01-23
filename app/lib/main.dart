import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/auth/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove a faixa vermelha "Debug"
      title: 'Victus App',
      theme: ThemeData(
        // Configura a cor base para o Rosa Victus
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE5C0BE)),
        useMaterial3: true,
        // Garante que o fundo do app seja branco
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
    );
  }
}