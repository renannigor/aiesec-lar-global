import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import '../widgets/dropdown_perfil.dart';
import '../widgets/dropdown_comite.dart';
import '../widgets/user_name_badge.dart';

class UsuariosTableDesktop extends StatelessWidget {
  final List<Usuario> usuarios;
  final List<ComiteLocal> comites;
  final String? currentUserId;
  final bool isLoading;

  // Paginação
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
                  final double minTableWidth = constraints.maxWidth > 900
                      ? constraints.maxWidth
                      : 900;

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
                              headingRowColor: WidgetStateProperty.all(
                                Colors.white,
                              ),
                              dividerThickness: 1,
                              dataRowMinHeight: 65,
                              dataRowMaxHeight: 65,
                              columnSpacing: 24,
                              horizontalMargin: 24,
                              columns: [
                                DataColumn(
                                  label: SizedBox(
                                    width: minTableWidth * 0.25,
                                    child: Text(
                                      'USUÁRIO',
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: minTableWidth * 0.25,
                                    child: Text(
                                      'EMAIL',
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: minTableWidth * 0.15,
                                    child: Text(
                                      'TIPO',
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: minTableWidth * 0.20,
                                    child: Text(
                                      'COMITÊ',
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: minTableWidth * 0.15,
                                    child: Text(
                                      'DATA',
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                              ],
                              rows: usuarios.map((usuario) {
                                final isMe = usuario.uid == currentUserId;
                                return DataRow(
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
                                      Text(
                                        _formatDate(usuario.criadoEm),
                                        style: _cellTextStyle,
                                      ),
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
