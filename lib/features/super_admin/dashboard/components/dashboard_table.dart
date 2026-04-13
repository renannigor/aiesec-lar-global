import 'package:aiesec_lar_global/data/models/area_filtro.dart';
import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/selector.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';
import 'package:aiesec_lar_global/data/services/aplicacao_service.dart';

// --- IMPORT PARA O BOTTOM SHEET DO FUNIL ---
import 'dashboard_funil_sheet.dart';

class DashboardTable extends StatelessWidget {
  final bool isMobile;
  final List<ComiteLocal> comites;
  final List<Intercambista> paginatedList;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int startIndex;
  final int endIndex;

  // Filtros
  final String filtroComite;
  final String filtroHospedagem;
  final String? filtroArea;
  final Function(String?) onComiteChanged;
  final Function(String?) onHospedagemChanged;
  final Function(String?) onAreaChanged;
  final Function(int) onPageChanged;
  final VoidCallback onClear;

  DashboardTable({
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
    required this.filtroArea,
    required this.onComiteChanged,
    required this.onHospedagemChanged,
    required this.onAreaChanged,
    required this.onPageChanged,
    required this.onClear,
  });

  final List<AreaFiltro> _opcoesAreas = [
    AreaFiltro(label: "Voluntário (iGV)", value: "iGV"),
    AreaFiltro(label: "Estágio Empresas (iGTa)", value: "iGTa"),
    AreaFiltro(label: "Estágio Ensino (iGTe)", value: "iGTe"),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

        // --- TABELA ---
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
                      "Nenhum intercambista encontrado com estes filtros.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final minTableWidth = isMobile
                        ? 1000.0
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
                                width: minTableWidth * 0.30,
                                child: const Text('INTERCAMBISTA'),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: minTableWidth * 0.20,
                                child: const Text('COMITÊ'),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: minTableWidth * 0.15,
                                child: const Text('PRECISA HOST?'),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: minTableWidth * 0.15,
                                child: const Text('APLICAÇÕES ATIVAS'),
                              ),
                            ),
                            const DataColumn(
                              label: Text('STATUS DOS HOSTS'),
                            ), // <--- NOVA COLUNA
                          ],
                          rows: paginatedList
                              .map(
                                (ep) =>
                                    _buildDataRow(context, ep, minTableWidth),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),

              // --- PAGINAÇÃO ---
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
    final hasActiveFilter =
        filtroComite != 'Todos' ||
        filtroHospedagem != 'Todos' ||
        filtroArea != null;

    final widgets = [
      SizedBox(
        width: 180,
        child: Selector<String>(
          isFilter: true,
          labelText: "Comitê",
          value: filtroComite,
          items: ['Todos', ...comites.map((c) => c.nomePodio).toList()..sort()],
          onChanged: onComiteChanged,
        ),
      ),
      SizedBox(
        width: 180,
        child: Selector<AreaFiltro>(
          isFilter: true,
          labelText: "Tipo (Área)",
          value: filtroArea != null
              ? _opcoesAreas.firstWhere((a) => a.value == filtroArea)
              : null,
          items: _opcoesAreas,
          itemLabelBuilder: (a) => a.label,
          onChanged: (val) => onAreaChanged(val?.value),
        ),
      ),
      SizedBox(
        width: 130,
        child: Selector<String>(
          isFilter: true,
          labelText: "Precisa Host?",
          value: filtroHospedagem,
          items: const ['Todos', 'Sim', 'Não'],
          onChanged: onHospedagemChanged,
        ),
      ),
      // --- NOVO: BOTÃO LIMPAR ---
      if (hasActiveFilter)
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

    if (isMobile) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: widgets,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        widgets[0],
        const SizedBox(width: 12),
        widgets[1],
        const SizedBox(width: 12),
        widgets[2],
        if (hasActiveFilter) const SizedBox(width: 12),
        if (hasActiveFilter) widgets[3],
      ],
    );
  }

  DataRow _buildDataRow(
    BuildContext context,
    Intercambista ep,
    double minTableWidth,
  ) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: minTableWidth * 0.30,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ep.nome,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        ep.area,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: minTableWidth * 0.20,
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
          SizedBox(
            width: minTableWidth * 0.15,
            child: FutureBuilder<int>(
              future: AplicacaoService.instance.getQuantidadeAplicacoesAtivas(
                ep.epId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
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
                      "$qtd Interessados",
                      style: TextStyle(
                        fontWeight: qtd > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: qtd > 0 ? AppColors.textPrimary : Colors.grey,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        DataCell(
          OutlinedButton.icon(
            onPressed: () => _abrirBottomSheetFunil(context, ep),
            icon: const Icon(
              Icons.analytics_outlined,
              size: 16,
              color: AppColors.primary,
            ),
            label: const Text(
              "Ver Funil",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  void _abrirBottomSheetFunil(BuildContext context, Intercambista ep) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.80,
        child: DashboardFunilSheet(ep: ep),
      ),
    );
  }
}
