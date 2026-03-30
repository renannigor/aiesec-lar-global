import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class InicioHeader extends StatelessWidget {
  final VoidCallback onStartPressed;
  final VoidCallback onProfilePressed;

  const InicioHeader({
    super.key,
    required this.onStartPressed,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder para responsividade interna
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

        return Container(
          width: double.infinity,
          height: 700,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/home_banner.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Overlay escuro
              Container(color: Colors.black.withValues(alpha: 0.6)),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Título Responsivo e Limpo
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile
                                  ? 36
                                  : 48, // Fonte menor no mobile
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                              height: 1.2,
                            ),
                            children: const [
                              TextSpan(text: "Receba "),
                              TextSpan(
                                text: "Jovens Internacionais",
                                style: TextStyle(color: AppColors.primary),
                              ),
                              TextSpan(text: "\nem sua casa"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Subtítulo
                        Text(
                          "A AIESEC conecta você a jovens de diversos países, prontos para viver uma experiência de intercâmbio. Complete seu perfil e comece sua jornada.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isMobile ? 16 : 18,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Botões Responsivos
                        Wrap(
                          spacing: 24, // Espaço horizontal
                          runSpacing: 16, // Espaço vertical
                          alignment: WrapAlignment.center,
                          children: [
                            // Botão Primário
                            ElevatedButton(
                              onPressed: onStartPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text("COMEÇAR BUSCA"),
                            ),

                            // Botão Secundário
                            ElevatedButton(
                              onPressed: onProfilePressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  side: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text("COMPLETAR PERFIL"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
