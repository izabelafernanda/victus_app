import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon; // Ícone da esquerda (prefix)
  final bool obscureText; // Para senhas (substitui o isPassword)
  final TextInputType keyboardType;
  final String? Function(String?)? validator; // Validação do formulário
  final Widget? suffixIcon; // Ícone da direita (olho da senha)

  const CustomInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.obscureText = false, // Por defeito não é senha
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField( // Mudámos de TextField para TextFormField para ter validator
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator, // Liga a validação
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        suffixIcon: suffixIcon, // Permite colocar o botão de ver senha
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCB8B8B)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}