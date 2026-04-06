import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/core/utils/csv_exporter.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';

class IntercambistasTable extends StatelessWidget {
  final bool isMobile;
  final List<Intercambista> listaExibida;
  final List<Intercambista> paginatedList;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int startIndex;
  final int endIndex;
  final String? comiteNomeLogado;

  // Callbacks de Ação
  final Function(int) onPageChanged;
  final Function(Intercambista) onVerAplicantes;
  final Function(Intercambista) onEditar;
  final Function(Intercambista) onVerDetalhes;

  const IntercambistasTable({
    super.key,
    required this.isMobile,
    required this.listaExibida,
    required this.paginatedList,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.startIndex,
    required this.endIndex,
    this.comiteNomeLogado,
    required this.onPageChanged,
    required this.onVerAplicantes,
    required this.onEditar,
    required this.onVerDetalhes,
  });

  final Color _borderColor = const Color(0xFFEAEAEA);
  final TextStyle _headerTextStyle = const TextStyle(
    color: Color(0xFF6B7280),
    fontWeight: FontWeight.w600,
    fontSize: 12,
  );
  final TextStyle _cellTextStyle = const TextStyle(
    color: Color(0xFF111827),
    fontSize: 13,
  );

  String _formatDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
        // Sombra super suave para dar destaque sobre o fundo branco
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // CABEÇALHO INTERNO DA TABELA
          Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Lista de EPs",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "$totalItems Total",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text("Exportar CSV"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: _borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await CsvExporter.exportIntercambistas(listaExibida);
                      SnackbarUtils.showSuccess(
                        "Download iniciado com sucesso!",
                      );
                    } catch (e) {
                      SnackbarUtils.showError("Erro ao exportar: $e");
                    }
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, color: _borderColor),

          // CORPO DA TABELA
          if (paginatedList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(80.0),
              child: Center(
                child: Text(
                  "Nenhum resultado encontrado.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final double availableWidth = max(
                  constraints.maxWidth - 48,
                  750.0,
                );

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.white),
                      dataRowMinHeight: 65,
                      dataRowMaxHeight: 65,
                      headingTextStyle: _headerTextStyle,
                      dividerThickness: 1,
                      columnSpacing: 16,
                      horizontalMargin: 24,
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: availableWidth * 0.28,
                            child: const Text('NOME DO EP'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: availableWidth * 0.15,
                            child: const Text('PAÍS'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: availableWidth * 0.12,
                            child: const Text('STATUS'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: availableWidth * 0.12,
                            child: const Text('PRECISA HOST'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: availableWidth * 0.18,
                            child: const Text('PERÍODO (PODIO)'),
                          ),
                        ),
                        const DataColumn(label: Text('AÇÕES')),
                      ],
                      rows: paginatedList
                          .map((ep) => _buildDataRow(ep, availableWidth))
                          .toList(),
                    ),
                  ),
                );
              },
            ),

          // RODAPÉ (PAGINAÇÃO)
          if (totalPages > 1) ...[
            Divider(height: 1, color: _borderColor),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  Text(
                    "Mostrando ${startIndex + 1} a $endIndex de $totalItems resultados",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildPaginationControls(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  DataRow _buildDataRow(Intercambista ep, double width) {
    final isDisponivel =
        ep.status.toLowerCase() == 'approved' ||
        ep.status.toLowerCase() == 'disponivel';
    final statusColor = isDisponivel ? Colors.green : Colors.orange;

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: width * 0.28,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    ep.nome.isNotEmpty ? ep.nome[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ep.nome,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: width * 0.15,
            child: Text(
              ep.pais ?? ep.entidadeAbroad,
              overflow: TextOverflow.ellipsis,
              style: _cellTextStyle,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: width * 0.12,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ep.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
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
            width: width * 0.12,
            child: Text(
              ep.precisaHospedagem ? "Sim" : "Não",
              style: _cellTextStyle,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: width * 0.18,
            child: Text(
              "${_formatDate(DateTime.tryParse(ep.dataRePresencial) ?? DateTime.now())} - ${_formatDate(DateTime.tryParse(ep.dataFinPresencial) ?? DateTime.now())}",
              style: _cellTextStyle,
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.maps_home_work_outlined,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
                tooltip: 'Ver Hosts Interessados',
                onPressed: () => onVerAplicantes(ep),
                splashRadius: 20,
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
                tooltip: 'Editar Dados',
                onPressed: () => onEditar(ep),
                splashRadius: 20,
              ),
              IconButton(
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
                tooltip: 'Ver Detalhes',
                onPressed: () => onVerDetalhes(ep),
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPaginationControls() {
    return [
      IconButton(
        icon: const Icon(Icons.chevron_left, size: 18),
        onPressed: currentPage > 1
            ? () => onPageChanged(currentPage - 1)
            : null,
      ),
      Text(
        "$currentPage / $totalPages",
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      IconButton(
        icon: const Icon(Icons.chevron_right, size: 18),
        onPressed: currentPage < totalPages
            ? () => onPageChanged(currentPage + 1)
            : null,
      ),
    ];
  }
}
