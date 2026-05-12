import 'dart:math';
import 'package:flutter/material.dart';

import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/data/models/nps_host.dart';

// --- IMPORTS DOS NOVOS COMPONENTES E CONSTANTES ---
import 'package:aiesec_lar_global/features/admin/dashboard/nps_filter_constantes.dart';
import 'nps_expansion_card.dart';
import 'nps_filter_dropdown.dart';

class NpsFeedbacksSection extends StatefulWidget {
  final List<NpsHost> avaliacoes;

  const NpsFeedbacksSection({super.key, required this.avaliacoes});

  @override
  State<NpsFeedbacksSection> createState() => _NpsFeedbacksSectionState();
}

class _NpsFeedbacksSectionState extends State<NpsFeedbacksSection> {
  // --- USANDO A NOVA CLASSE NpsFilterConstantes ---
  String _filtroHospedariaNovamente = NpsFilterConstantes.novamente.first;
  String _filtroNota = NpsFilterConstantes.notas.first;

  int _currentPage = 1;
  final int _itemsPerPage = 10;

  void _atualizarFiltros() {
    setState(() => _currentPage = 1);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.avaliacoes.isEmpty) return const SizedBox.shrink();

    final isMobile = Responsive.isMobile(context);

    // --- Filtragem ---
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

    // --- Paginação ---
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
        // --- TÍTULO E FILTROS ---
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

        // --- LISTA EXPANSÍVEL ---
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
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: paginatedList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    NpsExpansionCard(nps: paginatedList[index]),
              ),

        // --- CONTROLES DE PAGINAÇÃO ---
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

  // --- RENDERS DOS FILTROS ---
  Widget _buildDesktopFilters() {
    return Wrap(
      spacing: 16,
      children: [
        NpsFilterDropdown(
          label: "Hospedaria Novamente:",
          value: _filtroHospedariaNovamente,
          items: NpsFilterConstantes.novamente, // Atualizado
          onChanged: (v) {
            _filtroHospedariaNovamente = v!;
            _atualizarFiltros();
          },
        ),
        NpsFilterDropdown(
          label: "Nota:",
          value: _filtroNota,
          items: NpsFilterConstantes.notas, // Atualizado
          onChanged: (v) {
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
        NpsFilterDropdown(
          label: "Hospedaria Novamente:",
          value: _filtroHospedariaNovamente,
          items: NpsFilterConstantes.novamente, // Atualizado
          isMobile: true,
          onChanged: (v) {
            _filtroHospedariaNovamente = v!;
            _atualizarFiltros();
          },
        ),
        const SizedBox(height: 12),
        NpsFilterDropdown(
          label: "Nota:",
          value: _filtroNota,
          items: NpsFilterConstantes.notas, // Atualizado
          isMobile: true,
          onChanged: (v) {
            _filtroNota = v!;
            _atualizarFiltros();
          },
        ),
      ],
    );
  }
}
