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
  final Function(Usuario) onUpdateUser;
  final bool isLoading;
  final Widget? loadMoreButton;

  const UsuariosTableDesktop({
    super.key,
    required this.usuarios,
    required this.comites,
    required this.currentUserId,
    required this.onUpdateUser,
    required this.isLoading,
    this.loadMoreButton,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Limite mínimo para não espremer muito no desktop pequeno
              final double minTableWidth = constraints.maxWidth > 900
                  ? constraints.maxWidth
                  : 900;

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
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
                              child: Text("Nenhum usuário encontrado."),
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
                                  width: minTableWidth * 0.25, // 25% da tela
                                  child: Text(
                                    'USUÁRIO',
                                    style: _headerTextStyle,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: minTableWidth * 0.25, // 25% da tela
                                  child: Text('EMAIL', style: _headerTextStyle),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: minTableWidth * 0.15, // 15% da tela
                                  child: Text('TIPO', style: _headerTextStyle),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: minTableWidth * 0.20, // 20% da tela
                                  child: Text(
                                    'COMITÊ',
                                    style: _headerTextStyle,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: minTableWidth * 0.15, // 15% da tela
                                  child: Text('DATA', style: _headerTextStyle),
                                ),
                              ),
                            ],
                            rows: usuarios.map((usuario) {
                              // --- TRAVA DE SEGURANÇA ---
                              final isMe = usuario.uid == currentUserId;

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        // --- APLICAÇÃO DA SUA SOLUÇÃO COM ERROR BUILDER ---
                                        Container(
                                          width: 32, // O dobro do radius (16)
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: ClipOval(
                                            child:
                                                usuario.fotoPerfilUrl.isNotEmpty
                                                ? Image.network(
                                                    usuario.fotoPerfilUrl,
                                                    fit: BoxFit.cover,
                                                    // Captura falhas (ex: Erro 429) e exibe o inicial do nome ou '?'
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Center(
                                                            child: Text(
                                                              usuario
                                                                      .nome
                                                                      .isNotEmpty
                                                                  ? usuario
                                                                        .nome[0]
                                                                        .toUpperCase()
                                                                  : '?',
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppColors
                                                                    .primary,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                  )
                                                : Center(
                                                    child: Text(
                                                      usuario.nome.isNotEmpty
                                                          ? usuario.nome[0]
                                                                .toUpperCase()
                                                          : '?',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            AppColors.primary,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        // ----------------------------------------------------
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
                                      onUpdate: onUpdateUser,
                                      isDisabled: isMe, // Passa o bloqueio
                                    ),
                                  ),
                                  DataCell(
                                    DropdownComite(
                                      usuario: usuario,
                                      comites: comites,
                                      onUpdate: onUpdateUser,
                                      isDisabled: isMe, // Passa o bloqueio
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
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        if (loadMoreButton != null) loadMoreButton!,
      ],
    );
  }
}
