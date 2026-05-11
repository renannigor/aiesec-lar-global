import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/nps_host.dart';
import 'nps_detalhes_sheet.dart';

class NpsFeedbacksSection extends StatefulWidget {
  final List<NpsHost> avaliacoes;

  const NpsFeedbacksSection({super.key, required this.avaliacoes});

  @override
  State<NpsFeedbacksSection> createState() => _NpsFeedbacksSectionState();
}

class _NpsFeedbacksSectionState extends State<NpsFeedbacksSection> {
  String _filtroHospedariaNovamente = 'Todos';
  String _filtroNota = 'Todos';
  int _currentPage = 1;
  final int _itemsPerPage = 6;

  void _atualizarFiltros() {
    setState(() => _currentPage = 1);
  }

  void _abrirDetalhesNps(NpsHost nps) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: NpsDetalhesSheet(nps: nps),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.avaliacoes.isEmpty) return const SizedBox.shrink();

    final isMobile = Responsive.isMobile(context);

    // Filtragem
    final listaExibida = widget.avaliacoes.where((nps) {
      bool matchNovamente =
          _filtroHospedariaNovamente == 'Todos' ||
          nps.serHostNovamente == _filtroHospedariaNovamente;
      bool matchNota = true;
      if (_filtroNota == 'Promotores (9-10)') {
        matchNota = nps.notaNps >= 9;
      } else if (_filtroNota == 'Neutros (7-8)') {
        matchNota = nps.notaNps == 7 || nps.notaNps == 8;
      } else if (_filtroNota == 'Detratores (1-6)') {
        matchNota = nps.notaNps <= 6;
      }
      return matchNovamente && matchNota;
    }).toList();

    // Paginação
    final totalItems = listaExibida.length;
    final totalPages = max(1, (totalItems / _itemsPerPage).ceil());
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = min(startIndex + _itemsPerPage, totalItems);
    final paginatedList = totalItems > 0
        ? listaExibida.sublist(startIndex, endIndex)
        : <NpsHost>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título e Filtros
        if (isMobile) ...[
          const Text(
            "Feedbacks Recentes",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildMobileFilters(),
        ] else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Feedbacks Recentes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              _buildDesktopFilters(),
            ],
          ),
        const SizedBox(height: 24),

        // Grid/Lista de Cards
        paginatedList.isEmpty
            ? Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Nenhuma avaliação encontrada com esses filtros.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  if (isMobile) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: paginatedList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) =>
                          _buildFeedbackCard(paginatedList[index], true),
                    );
                  } else {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: constraints.maxWidth > 1200 ? 3 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 280,
                      ),
                      itemCount: paginatedList.length,
                      itemBuilder: (context, index) =>
                          _buildFeedbackCard(paginatedList[index], false),
                    );
                  }
                },
              ),

        // Controles de Paginação
        if (totalPages > 1) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 1
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              Text(
                "Página $_currentPage de $totalPages",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < totalPages
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Wrap(
      spacing: 16,
      children: [
        _buildDropdown(
          "Hospedaria Novamente:",
          _filtroHospedariaNovamente,
          ['Todos', 'Sim', 'Talvez', 'Não'],
          (v) {
            _filtroHospedariaNovamente = v!;
            _atualizarFiltros();
          },
        ),
        _buildDropdown(
          "Nota:",
          _filtroNota,
          ['Todos', 'Promotores (9-10)', 'Neutros (7-8)', 'Detratores (1-6)'],
          (v) {
            _filtroNota = v!;
            _atualizarFiltros();
          },
        ),
      ],
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDropdown(
          "Hospedaria Novamente:",
          _filtroHospedariaNovamente,
          ['Todos', 'Sim', 'Talvez', 'Não'],
          (v) {
            _filtroHospedariaNovamente = v!;
            _atualizarFiltros();
          },
          isMobile: true,
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          "Nota:",
          _filtroNota,
          ['Todos', 'Promotores (9-10)', 'Neutros (7-8)', 'Detratores (1-6)'],
          (v) {
            _filtroNota = v!;
            _atualizarFiltros();
          },
          isMobile: true,
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged, {
    bool isMobile = false,
  }) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                items: items
                    .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 8),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                items: items
                    .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      );
    }
  }

  // Recebe a variável isMobile!
  Widget _buildFeedbackCard(NpsHost nps, bool isMobile) {
    Color corNota = Colors.orange;
    if (nps.notaNps >= 9) {
      corNota = Colors.green;
    } else if (nps.notaNps <= 6) {
      corNota = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade100,
                      child: const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nps.nomeHost,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Host de: ${nps.nomeIntercambista}",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: corNota,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      nps.notaNps.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            "O que mais gostou:",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          Text(
            nps.oQueAprendeu,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            "Ponto de melhoria:",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          Text(
            nps.oQueMelhorar,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),

          if (!isMobile) const Spacer(),
          if (isMobile) const SizedBox(height: 16),

          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat("dd/MM/yyyy").format(nps.criadoEm),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
              TextButton.icon(
                onPressed: () => _abrirDetalhesNps(nps),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text(
                  "Ver Detalhes",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
