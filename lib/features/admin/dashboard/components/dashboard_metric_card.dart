import 'package:flutter/material.dart';

class DashboardMetricCard extends StatelessWidget {
  final bool isMobile;
  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;
  final String? trendPercentage;
  final bool? trendUp;

  const DashboardMetricCard({
    super.key,
    required this.isMobile,
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
    this.trendPercentage,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? double.infinity : 240,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF1E293B,
            ).withValues(alpha: 0.03), // Azul/Preto muito sutil
            blurRadius: 15,
            offset: const Offset(0, 10), // Empurra a sombra para baixo
          ),
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.01),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: cor, size: 24),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título (Cinza médio, peso médio, estilo Referência 1)
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500, // Mais claro que o preto
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Valor Principal (Grande e Bold)
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),

                // Detalhe de Tendência
                // Aparece apenas se você passar os dados
                if (trendPercentage != null) ...[
                  const SizedBox(height: 8),
                  _buildTrendIndicator(trendPercentage!, trendUp ?? true),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para construir o indicador de tendência
  Widget _buildTrendIndicator(String percentage, bool up) {
    // Cores exatas de dashboards (Verde sucesso / Vermelho erro)
    Color trendColor = up ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    IconData trendIcon = up ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(trendIcon, size: 14, color: trendColor),
        const SizedBox(width: 4),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: trendColor,
          ),
        ),
        const SizedBox(width: 4),
        // Texto de contexto (pequeno e cinza claro)
        Text(
          "vs mës ant.",
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        ),
      ],
    );
  }
}
