import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import '../widgets/dropdown_perfil.dart';
import '../widgets/dropdown_comite.dart';
import '../widgets/user_name_badge.dart';

class UsuariosListMobile extends StatelessWidget {
  final List<Usuario> usuarios;
  final List<ComiteLocal> comites;
  final String? currentUserId;
  final Function(Usuario) onUpdateUser;
  final bool isLoading;
  final Widget? loadMoreButton;

  const UsuariosListMobile({
    super.key,
    required this.usuarios,
    required this.comites,
    required this.currentUserId,
    required this.onUpdateUser,
    required this.isLoading,
    this.loadMoreButton,
  });

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (usuarios.isEmpty) {
      return const Center(child: Text("Nenhum usuário encontrado."));
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: usuarios.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final usuario = usuarios[index];
            final isMe =
                usuario.uid == currentUserId; // <--- IDENTIFICA O LOGADO

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // --- APLICAÇÃO DO ERROR BUILDER NO MOBILE ---
                      Container(
                        width: 40, // Equivalente ao radius 20
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: usuario.fotoPerfilUrl.isNotEmpty
                              ? Image.network(
                                  usuario.fotoPerfilUrl,
                                  fit: BoxFit.cover,
                                  // Captura falhas (ex: Erro 429) e exibe as iniciais
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        usuario.nome.isNotEmpty
                                            ? usuario.nome[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Text(
                                    usuario.nome.isNotEmpty
                                        ? usuario.nome[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // --------------------------------------------
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserNameBadge(
                              usuario: usuario,
                              currentUserId: currentUserId,
                            ),
                            Text(
                              usuario.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(usuario.criadoEm),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text(
                    "Configurações de Acesso:",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tipo",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            DropdownPerfil(
                              usuario: usuario,
                              onUpdate: onUpdateUser,
                              isDisabled: isMe, // <--- PASSA O BLOQUEIO
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Comitê",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            DropdownComite(
                              usuario: usuario,
                              comites: comites,
                              onUpdate: onUpdateUser,
                              isDisabled: isMe, // <--- PASSA O BLOQUEIO
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        if (loadMoreButton != null) loadMoreButton!,
      ],
    );
  }
}
