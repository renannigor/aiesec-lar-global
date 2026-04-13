import 'dart:math';
import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';

// --- IMPORTS DOS MODELS E SERVICES ---
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';
import 'package:aiesec_lar_global/data/services/comite_local_service.dart';
import 'package:aiesec_lar_global/data/services/intercambista_service.dart';

// --- IMPORTS DOS COMPONENTES (CRIADOS ABAIXO) ---
import 'components/dashboard_kpis.dart';
import 'components/dashboard_states_cards.dart';
import 'components/dashboard_table.dart';

class DashboardUI extends StatefulWidget {
  const DashboardUI({super.key});

  @override
  State<DashboardUI> createState() => _DashboardUIState();
}

class _DashboardUIState extends State<DashboardUI> {
  // Filtros da Tabela
  String _filtroComiteDash = 'Todos';
  String _filtroHospedagem = 'Todos';

  // Paginação da Tabela
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  void _atualizarTabela() {
    setState(() => _currentPage = 1);
  }

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
            Padding(
              padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 32, isMobile ? 24 : 32, isMobile ? 16 : 32, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dashboard Global",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Acompanhe o engajamento dos comitês e o status das hospedagens.",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: AppColors.greyLight),

            // --- 2. CORPO DO DASHBOARD ---
            Expanded(
              child: StreamBuilder<List<ComiteLocal>>(
                stream: ComiteLocalService.instance.getComitesStream(),
                builder: (context, comitesSnapshot) {
                  return StreamBuilder<List<Intercambista>>(
                    stream: IntercambistaService.instance.getIntercambistasStream(),
                    builder: (context, epsSnapshot) {
                      if (comitesSnapshot.connectionState == ConnectionState.waiting ||
                          epsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        );
                      }

                      final comites = comitesSnapshot.data ?? [];
                      final todosIntercambistas = epsSnapshot.data ?? [];

                      // --- Lógica de Filtro da Tabela ---
                      final epsFiltrados = todosIntercambistas.where((ep) {
                        bool matchComite = _filtroComiteDash == 'Todos' || ep.comite == _filtroComiteDash;
                        bool matchHospedagem = _filtroHospedagem == 'Todos' ||
                            (_filtroHospedagem == 'Sim' && ep.precisaHospedagem) ||
                            (_filtroHospedagem == 'Não' && !ep.precisaHospedagem);

                        return matchComite && matchHospedagem;
                      }).toList();

                      // --- Lógica de Paginação da Tabela ---
                      final totalItems = epsFiltrados.length;
                      final totalPages = (totalItems / _itemsPerPage).ceil();
                      final startIndex = (_currentPage - 1) * _itemsPerPage;
                      final endIndex = min(startIndex + _itemsPerPage, totalItems);
                      final paginatedList = totalItems > 0
                          ? epsFiltrados.sublist(startIndex, endIndex)
                          : <Intercambista>[];

                      return SingleChildScrollView(
                        padding: EdgeInsets.all(isMobile ? 16 : 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // SEÇÃO 1: KPIs GERAIS
                            DashboardKPIs(
                              isMobile: isMobile,
                              comites: comites,
                              eps: todosIntercambistas,
                            ),
                            const SizedBox(height: 32),

                            // SEÇÃO 2: COMITÊS POR ESTADO
                            const Text(
                              "Comitês por Estado",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DashboardStatesCards(comites: comites),
                            const SizedBox(height: 40),

                            // SEÇÃO 3: FUNIL DE INTERCAMBISTAS (TABELA PAGINADA)
                            DashboardTable(
                              isMobile: isMobile,
                              comites: comites,
                              paginatedList: paginatedList,
                              totalItems: totalItems,
                              totalPages: totalPages,
                              currentPage: _currentPage,
                              startIndex: startIndex,
                              endIndex: endIndex,
                              filtroComite: _filtroComiteDash,
                              filtroHospedagem: _filtroHospedagem,
                              onComiteChanged: (val) {
                                if (val != null) {
                                  setState(() => _filtroComiteDash = val);
                                  _atualizarTabela();
                                }
                              },
                              onHospedagemChanged: (val) {
                                if (val != null) {
                                  setState(() => _filtroHospedagem = val);
                                  _atualizarTabela();
                                }
                              },
                              onPageChanged: (page) {
                                setState(() => _currentPage = page);
                              },
                            ),
                          ],
                        ),
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
}