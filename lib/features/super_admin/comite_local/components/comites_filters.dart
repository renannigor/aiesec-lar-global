import 'package:aiesec_lar_global/core/widgets/selector.dart';
import 'package:flutter/material.dart';

class ComitesFilters extends StatelessWidget {
  final bool isMobile;
  final List<String> estadosDisponiveis;
  final String? filtroEstado;
  final String filtroStatus;
  final Function(String?) onEstadoChanged;
  final Function(String?) onStatusChanged;
  final VoidCallback onClear;

  const ComitesFilters({
    super.key,
    required this.isMobile,
    required this.estadosDisponiveis,
    required this.filtroEstado,
    required this.filtroStatus,
    required this.onEstadoChanged,
    required this.onStatusChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = isMobile
        ? (MediaQuery.of(context).size.width / 2) - 24
        : 200;

    final widgets = [
      // Filtro de Estado (UF)
      SizedBox(
        width: fieldWidth,
        child: Selector<String>(
          labelText: "Estado (UF)",
          value: filtroEstado,
          items: estadosDisponiveis,
          isFilter: true,
          onChanged: onEstadoChanged,
        ),
      ),

      // Filtro de Status
      SizedBox(
        width: fieldWidth,
        child: Selector<String>(
          labelText: "Status",
          value: filtroStatus == 'Todos' ? null : filtroStatus,
          items: const ['Ativo', 'Inativo'],
          isFilter: true,
          onChanged: onStatusChanged,
        ),
      ),

      // Botão Limpar (Aparece apenas se algum filtro estiver ativo)
      if (filtroEstado != null || filtroStatus != 'Todos')
        SizedBox(
          height: 48,
          child: TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 16),
            label: const Text("Limpar"),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
          ),
        ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: widgets,
    );
  }
}
