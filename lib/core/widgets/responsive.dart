import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // --- Breakpoints para os tamanhos de tela ---

  /// Tela é considerada mobile se a largura for menor que 650 pixels.
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  /// Tela é considerada tablet se a largura estiver entre 650 e 1100 pixels.
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  /// Tela é considerada desktop se a largura for de 1100 pixels ou mais.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder nos dá as restrições do widget pai.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        // Se a largura for de 1100 ou mais, exibimos o layout de desktop.
        if (width >= 1100) {
          return desktop;
        }
        // Se a largura for de 650 ou mais (mas menor que 1100), exibimos o tablet.
        else if (width >= 650) {
          // Se um layout de tablet não for fornecido, usamos o de mobile como fallback.
          return tablet ?? mobile;
        }
        // Caso contrário, exibimos o layout de mobile.
        else {
          return mobile;
        }
      },
    );
  }
}
