import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/features/super_admin/comite_local/widgets/comite_card.dart';
import 'package:aiesec_lar_global/features/super_admin/comite_local/widgets/comite_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/services/comite_local_service.dart';

class ComitesUI extends StatelessWidget {
  const ComitesUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. CABEÇALHO ---
            Responsive(
              mobile: _buildHeaderMobile(context),
              desktop: _buildHeaderDesktop(context),
            ),

            Divider(height: 1, thickness: 1, color: AppColors.greyLight),

            // --- 2. GRID ---
            Expanded(
              child: StreamBuilder<List<ComiteLocal>>(
                stream: ComiteLocalService.instance.getComitesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final comites = snapshot.data!;

                  if (comites.isEmpty) {
                    return _buildEmptyState();
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount;
                      double childAspectRatio;
                      double padding;

                      if (Responsive.isDesktop(context)) {
                        crossAxisCount = 4; // Desktop largo
                        childAspectRatio = 1.3;
                        padding = 32;
                      } else if (Responsive.isTablet(context)) {
                        crossAxisCount = 2; // Tablet
                        childAspectRatio = 1.3;
                        padding = 24;
                      } else {
                        crossAxisCount = 1; // Mobile
                        childAspectRatio = 1.6;
                        padding = 16;
                      }

                      // Ajuste fino para telas ultra-wide
                      if (constraints.maxWidth > 1600) crossAxisCount = 5;

                      return GridView.builder(
                        padding: EdgeInsets.all(padding),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: comites.length,
                        itemBuilder: (context, index) {
                          final comite = comites[index];
                          return ComiteCard(
                            comite: comite,
                            onEdit: () => _abrirDialogoFormulario(
                              context,
                              comite: comite,
                            ),
                            onToggleStatus: () =>
                                _alternarStatus(context, comite),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Nenhum comitê encontrado",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Cabeçalho para Desktop
  Widget _buildHeaderDesktop(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Gerenciamento de Comitês",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Gerencie as unidades locais e altere o status (Ativo/Inativo).",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildAddButton(context),
        ],
      ),
    );
  }

  // Cabeçalho para Mobile
  Widget _buildHeaderMobile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gerenciamento de Comitês",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Gerencie as unidades locais e altere o status.",
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: _buildAddButton(context)),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _abrirDialogoFormulario(context),
      icon: const Icon(Icons.add, size: 20, color: Colors.white),
      label: const Text(
        "Novo Comitê",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  void _abrirDialogoFormulario(BuildContext context, {ComiteLocal? comite}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(comite == null ? "Cadastrar Comitê" : "Editar Comitê"),
          content: SizedBox(
            width: Responsive.isMobile(context) ? double.maxFinite : 500,
            child: ComiteFormContent(
              comite: comite,
              onClose: () => Navigator.pop(ctx),
            ),
          ),
        );
      },
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
