import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/selector.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';
import 'package:aiesec_lar_global/data/services/aplicacao_service.dart';

class DashboardTable extends StatelessWidget {
  final bool isMobile;
  final List<ComiteLocal> comites;
  final List<Intercambista> paginatedList;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int startIndex;
  final int endIndex;

  // Filtros Controlados pela Tela Principal
  final String filtroComite;
  final String filtroHospedagem;
  final Function(String?) onComiteChanged;
  final Function(String?) onHospedagemChanged;
  final Function(int) onPageChanged;

  const DashboardTable({
    super.key,
    required this.isMobile,
    required this.comites,
    required this.paginatedList,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.startIndex,
    required this.endIndex,
    required this.filtroComite,
    required this.filtroHospedagem,
    required this.onComiteChanged,
    required this.onHospedagemChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- 1. CABEÇALHO DA TABELA (TÍTULO E FILTROS) ---
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Monitoramento de Hosts por EP",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildFilters(isMobile),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Monitoramento de Hosts por EP",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildFilters(isMobile),
            ],
          ),
        const SizedBox(height: 16),

        // --- 2. TABELA EM SI ---
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              if (paginatedList.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      "Nenhum intercambista encontrado.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final minTableWidth = isMobile
                        ? 800.0
                        : constraints.maxWidth;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: minTableWidth),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            Colors.grey.shade50,
                          ),
                          dataRowMinHeight: 65,
                          dataRowMaxHeight: 65,
                          headingTextStyle: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          columns: [
                            DataColumn(
                              label: SizedBox(
                                width: minTableWidth * 0.35,
                                child: const Text('INTERCAMBISTA'),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: minTableWidth * 0.25,
                                child: const Text('COMITÊ'),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: minTableWidth * 0.15,
                                child: const Text('PRECISA HOST?'),
                              ),
                            ),
                            const DataColumn(label: Text('APLICAÇÕES ATIVAS')),
                          ],
                          rows: paginatedList
                              .map((ep) => _buildDataRow(ep, minTableWidth))
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),

              // --- 3. PAGINAÇÃO ---
              if (totalPages > 1) ...[
                Divider(height: 1, color: Colors.grey.shade200),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mostrando ${startIndex + 1} a $endIndex de $totalItems",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 18),
                            onPressed: currentPage > 1
                                ? () => onPageChanged(currentPage - 1)
                                : null,
                          ),
                          Text(
                            "$currentPage / $totalPages",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 18),
                            onPressed: currentPage < totalPages
                                ? () => onPageChanged(currentPage + 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(bool isMobile) {
    final widgets = [
      SizedBox(
        width: 180,
        child: Selector<String>(
          isFilter: true,
          labelText: "Filtrar Comitê",
          value: filtroComite,
          items: ['Todos', ...comites.map((c) => c.nomePodio).toList()..sort()],
          onChanged: onComiteChanged,
        ),
      ),
      SizedBox(
        width: 140,
        child: Selector<String>(
          isFilter: true,
          labelText: "Precisa Host?",
          value: filtroHospedagem,
          items: const ['Todos', 'Sim', 'Não'],
          onChanged: onHospedagemChanged,
        ),
      ),
    ];

    if (isMobile) {
      return Wrap(spacing: 12, runSpacing: 12, children: widgets);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [widgets[0], const SizedBox(width: 12), widgets[1]],
    );
  }

  DataRow _buildDataRow(Intercambista ep, double minTableWidth) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: minTableWidth * 0.35,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    ep.nome.isNotEmpty ? ep.nome[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ep.nome,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: minTableWidth * 0.25,
            child: Text(
              ep.comite,
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: minTableWidth * 0.15,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ep.precisaHospedagem
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ep.precisaHospedagem ? "SIM" : "NÃO",
                  style: TextStyle(
                    color: ep.precisaHospedagem
                        ? Colors.red.shade700
                        : Colors.green.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        DataCell(
          FutureBuilder<int>(
            future: AplicacaoService.instance.getQuantidadeAplicacoesAtivas(
              ep.epId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              final qtd = snapshot.data ?? 0;
              return Row(
                children: [
                  Icon(
                    qtd > 0 ? Icons.people : Icons.sentiment_dissatisfied,
                    size: 16,
                    color: qtd > 0 ? AppColors.primary : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$qtd Hosts interessados",
                    style: TextStyle(
                      fontWeight: qtd > 0 ? FontWeight.bold : FontWeight.normal,
                      color: qtd > 0 ? AppColors.textPrimary : Colors.grey,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
