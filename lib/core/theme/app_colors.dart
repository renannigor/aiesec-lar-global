import 'package:flutter/material.dart';

/// Uma classe para armazenar as cores padrão do aplicativo,
/// evitando a repetição de códigos hexadecimais.
class AppColors {
  // Construtor privado para que a classe não possa ser instanciada.
  AppColors._();

  static const Color primary = Color(0xFFF8AE00);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color textPrimary = Colors.black87; // Cor principal para textos
  static const Color textSecondary = Colors.black54; // Cor secundária para textos
}
