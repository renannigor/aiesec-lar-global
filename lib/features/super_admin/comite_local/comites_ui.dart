import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/services/comite_local_service.dart';
import 'package:flutter/material.dart';

// Imports dos novos componentes
import 'package:aiesec_lar_global/features/super_admin/comite_local/components/comite_form_sheet.dart';
import 'package:aiesec_lar_global/features/super_admin/comite_local/components/comites_filters.dart';
import 'package:aiesec_lar_global/features/super_admin/comite_local/components/comites_table.dart';

class ComitesUI extends StatefulWidget {
  const ComitesUI({super.key});

  @override
  State<ComitesUI> createState() => _ComitesUIState();
}

class _ComitesUIState extends State<ComitesUI> {
  // Lógica de Filtros
  String? _filtroEstado;
  String _filtroStatus = 'Todos';

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. CABEÇALHO ---
            Responsive(
              mobile: _buildHeaderMobile(context),
              desktop: _buildHeaderDesktop(context),
            ),

            Divider(height: 1, thickness: 1, color: AppColors.greyLight),

            // --- 2. CONTEÚDO (Filtros + Tabela) ---
            Expanded(
              child: StreamBuilder<List<ComiteLocal>>(
                stream: ComiteLocalService.instance.getComitesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final todosComites = snapshot.data ?? [];

                  // Pega todos os estados únicos disponíveis na base para o Dropdown
                  final estadosDisponiveis =
                      todosComites
                          .map((c) => c.estado)
                          .where((e) => e.isNotEmpty)
                          .toSet()
                          .toList()
                        ..sort();

                  // Aplica os filtros localmente
                  final comitesFiltrados = todosComites.where((c) {
                    if (_filtroEstado != null && c.estado != _filtroEstado) {
                      return false;
                    }
                    if (_filtroStatus != 'Todos' && c.status != _filtroStatus) {
                      return false;
                    }
                    return true;
                  }).toList();

                  return Padding(
                    padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- FILTROS ---
                        ComitesFilters(
                          isMobile: isMobile,
                          estadosDisponiveis: estadosDisponiveis,
                          filtroEstado: _filtroEstado,
                          filtroStatus: _filtroStatus,
                          onEstadoChanged: (v) =>
                              setState(() => _filtroEstado = v),
                          onStatusChanged: (v) =>
                              setState(() => _filtroStatus = v ?? 'Todos'),
                          onClear: () => setState(() {
                            _filtroEstado = null;
                            _filtroStatus = 'Todos';
                          }),
                        ),

                        const SizedBox(height: 24),

                        // --- TABELA ---
                        Expanded(
                          child: comitesFiltrados.isEmpty
                              ? _buildEmptyState()
                              : ComitesTable(
                                  comites: comitesFiltrados,
                                  isMobile: isMobile,
                                  onEdit: (comite) =>
                                      _abrirBottomSheetFormulario(
                                        context,
                                        comite: comite,
                                      ),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES (Cabeçalhos e Empty State mantidos) ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.business_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Nenhum comitê encontrado com estes filtros.",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

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
                  "Gerencie as unidades locais da AIESEC no sistema.",
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
            "Gerencie as unidades locais no sistema.",
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
      onPressed: () => _abrirBottomSheetFormulario(context),
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

  void _abrirBottomSheetFormulario(
    BuildContext context, {
    ComiteLocal? comite,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.90,
          child: ComiteFormSheet(comite: comite),
        );
      },
    );
  }
}
