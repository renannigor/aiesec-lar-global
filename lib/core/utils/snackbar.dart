import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';

/// Uma classe de utilitários para exibir mensagens SnackBar de forma global.
class SnackbarUtils {
  // A GlobalKey para acessar o ScaffoldMessenger de qualquer lugar.
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  /// Exibe um SnackBar com uma mensagem de sucesso (fundo verde suave).
  static void showSuccess(String? text) {
    if (text == null || text.isEmpty) return;

    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: Colors.green.shade600,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Exibe um SnackBar com uma mensagem de erro (fundo vermelho pastel).
  static void showError(String? text) {
    if (text == null || text.isEmpty) return;

    final snackBar = SnackBar(
      content: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFFD32F2F),
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Exibe um SnackBar com uma mensagem informativa (fundo padrão).
  static void showInfo(String? text) {
    if (text == null || text.isEmpty) return;

    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: AppColors.textSecondary,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
