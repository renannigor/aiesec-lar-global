import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';

class DashboardKPIs extends StatelessWidget {
  final bool isMobile;
  final List<ComiteLocal> comites;
  final List<Intercambista> eps;

  const DashboardKPIs({
    super.key,
    required this.isMobile,
    required this.comites,
    required this.eps,
  });

  @override
  Widget build(BuildContext context) {
    final comitesAtivos = comites.where((c) => c.status == 'Ativo').length;
    final epsPrecisamHost = eps.where((e) => e.precisaHospedagem).length;

    final cards = [
      _KpiCard(
        title: "Comitês Ativos",
        value: "$comitesAtivos",
        subtitle: "de ${comites.length} cadastrados",
        icon: Icons.business,
        color: Colors.blue,
      ),
      _KpiCard(
        title: "EPs na Base",
        value: "${eps.length}",
        subtitle: "Aprovados/Realizados",
        icon: Icons.flight_takeoff,
        color: Colors.purple,
      ),
      _KpiCard(
        title: "Precisam de Host",
        value: "$epsPrecisamHost",
        subtitle: "Atenção necessária",
        icon: Icons.warning_amber_rounded,
        color: Colors.orange,
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
            )
            .toList(),
      );
    }
    return Row(
      children: cards
          .map(
            (c) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: c,
              ),
            ),
          )
          .toList(),
    );
  }
}

// Widget auxiliar apenas para esta seção
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
