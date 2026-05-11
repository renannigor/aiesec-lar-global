import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/models/comite_local.dart';
import 'package:aiesec_lar_global/data/services/usuario_service.dart';
import '../widgets/dropdown_perfil.dart';
import '../widgets/dropdown_comite.dart';
import '../widgets/user_name_badge.dart';

class UsuariosTableDesktop extends StatelessWidget {
  final List<Usuario> usuarios;
  final List<ComiteLocal> comites;
  final String? currentUserId;
  final bool isLoading;

  final Set<String> selecionados;
  final Function(bool?, List<Usuario>) onSelectAll;
  final Function(String, bool?) onSelectUser;

  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int startIndex;
  final int endIndex;
  final Function(int) onPageChanged;

  const UsuariosTableDesktop({
    super.key,
    required this.usuarios,
    required this.comites,
    required this.currentUserId,
    required this.isLoading,
    required this.selecionados,
    required this.onSelectAll,
    required this.onSelectUser,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.startIndex,
    required this.endIndex,
    required this.onPageChanged,
  });

  final TextStyle _headerTextStyle = const TextStyle(
    color: Color(0xFF6B7280),
    fontWeight: FontWeight.w600,
    fontSize: 12,
  );

  final TextStyle _cellTextStyle = const TextStyle(
    color: Color(0xFF111827),
    fontSize: 14,
  );

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  Future<void> _deletarApenasDoPodio(
    BuildContext context,
    Usuario usuario,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remover do Podio"),
        content: Text(
          "Tem certeza que deseja remover ${usuario.nome} apenas do CRM Podio? Os dados continuarão salvos no aplicativo.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Remover do Podio",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      try {
        SnackbarUtils.showInfo("Removendo do Podio...");
        await UsuarioService.instance.deletarUsuarioApenasDoPodio(
          uid: usuario.uid,
        );
        SnackbarUtils.showSuccess("Usuário removido do CRM com sucesso.");
      } catch (e) {
        SnackbarUtils.showError(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final double minTableWidth = constraints.maxWidth > 1100
                      ? constraints.maxWidth
                      : 1100;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: minTableWidth),
                      child: isLoading
                          ? const SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : usuarios.isEmpty
                          ? const SizedBox(
                              height: 200,
                              child: Center(
                                child: Text(
                                  "Nenhum usuário encontrado na busca.",
                                ),
                              ),
                            )
                          : DataTable(
                              showCheckboxColumn: true,
                              onSelectAll: (val) => onSelectAll(val, usuarios),
                              headingRowColor: WidgetStateProperty.all(
                                Colors.white,
                              ),
                              dividerThickness: 1,
                              dataRowMinHeight: 65,
                              dataRowMaxHeight: 65,
                              columnSpacing: 16,
                              horizontalMargin: 16,
                              columns: [
                                DataColumn(
                                  label: SizedBox(
                                    width: minTableWidth * 0.18,
                                    child: Text(
                                      'USUÁRIO',
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: minTableWidth * 0.18,
                                    child: Text(
                                      'EMAIL',
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: minTableWidth * 0.12,
                                    child: Text(
                                      'TIPO',
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: minTableWidth * 0.15,
                                    child: Text(
                                      'COMITÊ',
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: minTableWidth * 0.12,
                                    child: Text(
                                      'STATUS PODIO',
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: minTableWidth * 0.08,
                                    child: Text(
                                      'DATA',
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: minTableWidth * 0.08,
                                    child: Text(
                                      'AÇÕES',
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                              ],
                              rows: usuarios.map((usuario) {
                                final isMe = usuario.uid == currentUserId;
                                final inPodio = usuario.podioItemId != null;

                                return DataRow(
                                  selected: selecionados.contains(usuario.uid),
                                  onSelectChanged: (val) {
                                    if (!inPodio) {
                                      SnackbarUtils.showError(
                                        "Este usuário não está no CRM para ser removido.",
                                      );
                                    } else {
                                      onSelectUser(usuario.uid, val);
                                    }
                                  },
                                  cells: [
                                    DataCell(
                                      Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: ClipOval(
                                              child:
                                                  usuario
                                                      .fotoPerfilUrl
                                                      .isNotEmpty
                                                  ? Image.network(
                                                      usuario.fotoPerfilUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (_, __, ___) =>
                                                              _buildInitials(
                                                                usuario,
                                                              ),
                                                    )
                                                  : _buildInitials(usuario),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: UserNameBadge(
                                              usuario: usuario,
                                              currentUserId: currentUserId,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        usuario.email,
                                        style: _cellTextStyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    DataCell(
                                      DropdownPerfil(
                                        usuario: usuario,
                                        isDisabled: isMe,
                                      ),
                                    ),
                                    DataCell(
                                      DropdownComite(
                                        usuario: usuario,
                                        comites: comites,
                                        isDisabled: isMe,
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: inPodio
                                              ? Colors.green.shade50
                                              : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: inPodio
                                                ? Colors.green.shade200
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          inPodio
                                              ? "Sincronizado"
                                              : "Fora do CRM",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: inPodio
                                                ? Colors.green.shade700
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        _formatDate(usuario.criadoEm),
                                        style: _cellTextStyle,
                                      ),
                                    ),
                                    DataCell(
                                      inPodio
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                              tooltip: "Remover do Podio",
                                              splashRadius: 20,
                                              onPressed: () =>
                                                  _deletarApenasDoPodio(
                                                    context,
                                                    usuario,
                                                  ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                    ),
                  );
                },
              ),

              // --- RODAPÉ DE PAGINAÇÃO ---
              if (totalPages > 1 && !isLoading && usuarios.isNotEmpty) ...[
                Divider(height: 1, color: Colors.grey.shade200),
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
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
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
        ),
      ],
    );
  }

  Widget _buildInitials(Usuario usuario) {
    return Center(
      child: Text(
        usuario.nome.isNotEmpty ? usuario.nome[0].toUpperCase() : '?',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          fontSize: 12,
        ),
      ),
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
