import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';

class DashboardStatesCards extends StatelessWidget {
  final List<ComiteLocal> comites;

  const DashboardStatesCards({super.key, required this.comites});

  @override
  Widget build(BuildContext context) {
    // 1. Agrupar os comitês por Estado
    final Map<String, List<ComiteLocal>> agrupados = {};
    for (var comite in comites) {
      final uf = comite.estado;
      if (!agrupados.containsKey(uf)) agrupados[uf] = [];
      agrupados[uf]!.add(comite);
    }

    // 2. Ordenar os estados alfabeticamente
    final estadosOrdenados = agrupados.keys.toList()..sort();

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: estadosOrdenados.map((uf) {
        final listaUf = agrupados[uf]!;
        final ativos = listaUf.where((c) => c.status == 'Ativo').length;
        final inativos = listaUf.length - ativos;

        return Container(
          width: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.grey.shade100,
                    child: Text(
                      uf,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${listaUf.length} Comitês",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ativos: $ativos",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Inativos: $inativos",
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
