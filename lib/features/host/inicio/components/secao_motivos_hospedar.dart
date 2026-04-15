import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SecaoMotivosHospedar extends StatelessWidget {
  const SecaoMotivosHospedar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título e Subtítulo
        const Text(
          "Por que hospedar um intercambista com a AIESEC?",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Descubra os benefícios e o impacto de ser um anfitrião.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 40),

        LayoutBuilder(
          builder: (context, constraints) {
            // Definição dos cards usando AppColors
            final cards = [
              const _MotivoCard(
                icon: Icons.translate,
                // Usando a nova cor PRIMÁRIA
                color: AppColors.primary,
                title: "Aprenda Novos Idiomas",
                subtitle: "Melhore sua comunicação",
                desc:
                    "Desenvolva suas habilidades linguísticas de forma natural, praticando no dia a dia com um falante nativo.",
              ),
              const _MotivoCard(
                icon: Icons.public,
                // Cor Teal/Azul
                color: AppColors.cardTeal,
                title: "Vivencie Trocas Culturais",
                subtitle: "Compartilhe experiências",
                desc:
                    "Conheça novos costumes e tradições sem sair de casa, apresentando também o melhor da cultura brasileira.",
              ),
              const _MotivoCard(
                icon: Icons.diversity_3,
                // Cor Laranja
                color: AppColors.cardOrange,
                title: "Conexões Internacionais",
                subtitle: "Amizades sem fronteiras",
                desc:
                    "Construa laços globais duradouros e expanda sua rede de contatos com jovens líderes de outros países.",
              ),
              const _MotivoCard(
                icon: Icons.volunteer_activism,
                // Cor Verde
                color: AppColors.cardGreen,
                title: "Apoie o Impacto Social",
                subtitle: "Potencialize mudanças locais",
                desc:
                    "Ao hospedar, você viabiliza o trabalho voluntário do intercambista em ONGs locais, multiplicando o impacto positivo na sua comunidade.",
              ),
            ];

            // 1. DESKTOP LARGE (4 em linha)
            if (constraints.maxWidth > 1100) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 24),
                  Expanded(child: cards[1]),
                  const SizedBox(width: 24),
                  Expanded(child: cards[2]),
                  const SizedBox(width: 24),
                  Expanded(child: cards[3]),
                ],
              );
            }
            // 2. TABLET / DESKTOP MENOR (Grid 2x2)
            else if (constraints.maxWidth > 650) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 24),
                      Expanded(child: cards[1]),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards[2]),
                      const SizedBox(width: 24),
                      Expanded(child: cards[3]),
                    ],
                  ),
                ],
              );
            }
            // 3. MOBILE (Um abaixo do outro)
            else {
              return Column(
                children: [
                  cards[0],
                  const SizedBox(height: 24),
                  cards[1],
                  const SizedBox(height: 24),
                  cards[2],
                  const SizedBox(height: 24),
                  cards[3],
                ],
              );
            }
          },
        ),
      ],
    );
  }
}

class _MotivoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String desc;

  const _MotivoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
