import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/services/comite_local_service.dart';
import 'package:flutter/material.dart';

class ComitesTable extends StatelessWidget {
  final List<ComiteLocal> comites;
  final bool isMobile;
  final Function(ComiteLocal) onEdit;

  const ComitesTable({
    super.key,
    required this.comites,
    required this.isMobile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Garante que a tabela tenha no mínimo 800px no celular para poder fazer o scroll horizontal,
          // mas preencha 100% (constraints.maxWidth) se estiver no Desktop.
          final double minTableWidth = isMobile ? 800 : constraints.maxWidth;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minTableWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.white),
                  dataRowMinHeight: 65,
                  dataRowMaxHeight: 65,
                  headingTextStyle: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  dividerThickness: 1,
                  columnSpacing: 24,
                  horizontalMargin: 24,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: minTableWidth * 0.35, // 35% do espaço
                        child: const Text('COMITÊ'),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: minTableWidth * 0.30, // 30% do espaço
                        child: const Text('LOCALIZAÇÃO'),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: minTableWidth * 0.15, // 15% do espaço
                        child: const Text('STATUS'),
                      ),
                    ),
                    const DataColumn(label: Text('AÇÕES')),
                  ],
                  rows: comites
                      .map(
                        (comite) =>
                            _buildDataRow(context, comite, minTableWidth),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  DataRow _buildDataRow(
    BuildContext context,
    ComiteLocal comite,
    double minTableWidth,
  ) {
    final isAtivo = comite.status == 'Ativo';

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: minTableWidth * 0.35,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    comite.nome.isNotEmpty ? comite.nome[0].toUpperCase() : '?',
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
                    comite.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: minTableWidth * 0.30,
            child: Text(
              "${comite.cidade} - ${comite.estado}",
              style: const TextStyle(color: Color(0xFF374151)),
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
                  color: isAtivo
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  comite.status.toUpperCase(),
                  style: TextStyle(
                    color: isAtivo ? Colors.green[700] : Colors.grey[700],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
                tooltip: 'Editar Comitê',
                onPressed: () => onEdit(comite),
                splashRadius: 20,
              ),
              IconButton(
                icon: Icon(
                  isAtivo ? Icons.block : Icons.check_circle_outline,
                  size: 20,
                  color: isAtivo ? Colors.red : Colors.green,
                ),
                tooltip: isAtivo ? 'Inativar Comitê' : 'Ativar Comitê',
                onPressed: () => _alternarStatus(context, comite),
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _alternarStatus(BuildContext context, ComiteLocal comite) async {
    try {
      final novoStatus = comite.status == 'Ativo' ? 'Inativo' : 'Ativo';

      final comiteAtualizado = ComiteLocal(
        comiteId: comite.comiteId,
        nome: comite.nome,
        cidade: comite.cidade,
        estado: comite.estado,
        status: novoStatus,
        nomePodio: comite.nomePodio,
        cnpj: comite.cnpj,
        dadosPresidente: comite.dadosPresidente,
        endereco: comite.endereco,
        testemunhas: comite.testemunhas,
      );

      await ComiteLocalService.instance.atualizarComiteLocal(
        comite: comiteAtualizado,
      );

      if (context.mounted) {
        SnackbarUtils.showInfo(
          "Comitê '${comite.nome}' agora está $novoStatus",
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showInfo("Erro ao atualizar status: $e");
      }
    }
  }
}
