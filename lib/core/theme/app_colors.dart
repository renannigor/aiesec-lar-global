import 'package:flutter/material.dart';

/// Uma classe para armazenar as cores padrão do aplicativo.
class AppColors {
  AppColors._();

  // Nova cor primária definida por você
  static const Color primary = Color(0xFFF8AE00); 
  
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color greyLight = Color(0xFFEEEEEE);

  // --- Cores Específicas dos Cards de Benefícios ---
  // (Baseadas no design anterior)
  static const Color cardTeal = Color(0xFF0A8EA0);   // Azul AIESEC / Cultura
  static const Color cardOrange = Color(0xFFF85A40); // Laranja / Conexões
  static const Color cardGreen = Color(0xFF4CAF50);  // Verde / Impacto
}