import 'dart:math';
import 'package:aiesec_lar_global/features/admin/dashboard/components/dashboard_metric_card.dart';
import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';

// --- IMPORTS DOS MODELS E SERVICES ---
import 'package:aiesec_lar_global/data/models/comite_local.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';
import 'package:aiesec_lar_global/data/models/nps_host.dart';
import 'package:aiesec_lar_global/data/services/comite_local_service.dart';
import 'package:aiesec_lar_global/data/services/intercambista_service.dart';
import 'package:aiesec_lar_global/data/services/nps_service.dart';

// --- IMPORTS DOS COMPONENTES ---
import 'components/dashboard_kpis.dart';
import 'components/dashboard_states_cards.dart';
import 'components/dashboard_ranking.dart';
import 'components/dashboard_table.dart';
import 'components/nps_charts_section.dart';

class DashboardUI extends StatefulWidget {
  const DashboardUI({super.key});

  @override
  State<DashboardUI> createState() => _DashboardUIState();
}

class _DashboardUIState extends State<DashboardUI> {
  // Filtros da Tabela de Funil
  String _filtroComiteDash = 'Todos';
  String _filtroHospedagem = 'Todos';
  String? _filtroArea;

  // Paginação da Tabela de Funil
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  void _atualizarTabela() {
    setState(() => _currentPage = 1);
  }

  void _limparFiltros() {
    setState(() {
      _filtroComiteDash = 'Todos';
      _filtroHospedagem = 'Todos';
      _filtroArea = null;
      _currentPage = 1;
    });
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
                isMobile ? 16 : 32,
                isMobile ? 24 : 32,
                isMobile ? 16 : 32,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dashboard Nacional",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Acompanhe o engajamento dos comitês e o panorama geral das experiências.",
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
                    stream: IntercambistaService.instance
                        .getIntercambistasStream(),
                    builder: (context, epsSnapshot) {
                      return StreamBuilder<List<NpsHost>>(
                        stream: NpsService.instance.getTodasAvaliacoesNps(),
                        builder: (context, npsSnapshot) {
                          if (comitesSnapshot.connectionState ==
                                  ConnectionState.waiting ||
                              epsSnapshot.connectionState ==
                                  ConnectionState.waiting ||
                              npsSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }

                          final comites = comitesSnapshot.data ?? [];
                          final todosIntercambistas = epsSnapshot.data ?? [];
                          final avaliacoesNps = npsSnapshot.data ?? [];

                          // --- Lógica de Filtro da Tabela de Funil ---
                          final epsFiltrados = todosIntercambistas.where((ep) {
                            bool matchComite =
                                _filtroComiteDash == 'Todos' ||
                                ep.comite == _filtroComiteDash;
                            bool matchHospedagem =
                                _filtroHospedagem == 'Todos' ||
                                (_filtroHospedagem == 'Sim' &&
                                    ep.precisaHospedagem) ||
                                (_filtroHospedagem == 'Não' &&
                                    !ep.precisaHospedagem);
                            bool matchArea =
                                _filtroArea == null || ep.area == _filtroArea;

                            return matchComite && matchHospedagem && matchArea;
                          }).toList();

                          // --- Lógica de Paginação da Tabela de Funil ---
                          final totalItems = epsFiltrados.length;
                          final totalPages = max(
                            1,
                            (totalItems / _itemsPerPage).ceil(),
                          );
                          final startIndex = (_currentPage - 1) * _itemsPerPage;
                          final endIndex = min(
                            startIndex + _itemsPerPage,
                            totalItems,
                          );
                          final paginatedList = totalItems > 0
                              ? epsFiltrados.sublist(startIndex, endIndex)
                              : <Intercambista>[];

                          return SingleChildScrollView(
                            padding: EdgeInsets.all(isMobile ? 16 : 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ==========================================
                                // SEÇÃO 1: KPIs GERAIS (OPERAÇÕES E COMITÊS)
                                // ==========================================
                                DashboardKPIs(
                                  isMobile: isMobile,
                                  comites: comites,
                                  eps: todosIntercambistas,
                                ),
                                const SizedBox(height: 32),

                                // ==========================================
                                // SEÇÃO 2: RANKING E ESTADOS
                                // ==========================================
                                if (isMobile) ...[
                                  DashboardRanking(eps: todosIntercambistas),
                                  const SizedBox(height: 32),
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
                                ] else
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 35,
                                        child: DashboardRanking(
                                          eps: todosIntercambistas,
                                        ),
                                      ),
                                      const SizedBox(width: 32),
                                      Expanded(
                                        flex: 65,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Comitês por Estado",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            DashboardStatesCards(
                                              comites: comites,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                const SizedBox(height: 48),

                                // ==========================================
                                // SEÇÃO 3: ANÁLISE NACIONAL DE EXPERIÊNCIA (NPS)
                                // ==========================================
                                _buildSectionTitle(
                                  "Análise Nacional de Qualidade (NPS)",
                                  Icons.analytics_outlined,
                                ),
                                const SizedBox(height: 16),
                                _buildNpsOverview(isMobile, avaliacoesNps),
                                const SizedBox(height: 32),

                                // NOVO: COMPONENTE DE GRÁFICOS AGREGADOS
                                if (avaliacoesNps.isNotEmpty)
                                  NpsChartsSection(avaliacoes: avaliacoesNps),
                                if (avaliacoesNps.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "Ainda não há avaliações cadastradas a nível nacional.",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),

                                const SizedBox(height: 48),

                                // ==========================================
                                // SEÇÃO 4: FUNIL DE INTERCAMBISTAS (TABELA)
                                // ==========================================
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
                                  filtroArea: _filtroArea,
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
                                  onAreaChanged: (val) {
                                    setState(() => _filtroArea = val);
                                    _atualizarTabela();
                                  },
                                  onPageChanged: (page) {
                                    setState(() => _currentPage = page);
                                  },
                                  onClear: _limparFiltros,
                                ),
                              ],
                            ),
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

  // --- COMPONENTES AUXILIARES ---

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
            maxLines: 2, // Permite quebrar em 2 linhas se necessário
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNpsOverview(bool isMobile, List<NpsHost> avaliacoes) {
    final totalAvaliacoes = avaliacoes.length;
    int promotores = avaliacoes.where((n) => n.notaNps >= 9).length;
    int detratores = avaliacoes.where((n) => n.notaNps <= 6).length;

    int npsScore = 0;
    double mediaNotas = 0;

    if (totalAvaliacoes > 0) {
      npsScore = (((promotores - detratores) / totalAvaliacoes) * 100).round();
      mediaNotas =
          avaliacoes.fold(0, (sum, item) => sum + item.notaNps) /
          totalAvaliacoes;
    }

    Color corNps = Colors.grey;
    if (totalAvaliacoes > 0) {
      if (npsScore >= 75)
        corNps = Colors.green;
      else if (npsScore >= 50)
        corNps = Colors.blue;
      else if (npsScore >= 0)
        corNps = Colors.orange;
      else
        corNps = Colors.red;
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        DashboardMetricCard(
          isMobile: isMobile,
          titulo: "Score NPS Nacional",
          valor: totalAvaliacoes > 0 ? "$npsScore" : "-",
          icone: Icons.speed,
          cor: corNps,
        ),
        DashboardMetricCard(
          isMobile: isMobile,
          titulo: "Média Nacional",
          valor: totalAvaliacoes > 0 ? mediaNotas.toStringAsFixed(1) : "-",
          icone: Icons.star_rate_rounded,
          cor: Colors.amber,
        ),
        DashboardMetricCard(
          isMobile: isMobile,
          titulo: "Total de Avaliações",
          valor: totalAvaliacoes.toString(),
          icone: Icons.fact_check_outlined,
          cor: Colors.purple,
        ),
        DashboardMetricCard(
          isMobile: isMobile,
          titulo: "Promotores Globais",
          valor: promotores.toString(),
          icone: Icons.favorite_border,
          cor: Colors.pink,
        ),
      ],
    );
  }
}
