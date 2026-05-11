import 'package:flutter/material.dart';

// Imports Core
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';

// Imports Data
import 'package:aiesec_lar_global/data/models/acesso_usuario.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';
import 'package:aiesec_lar_global/data/models/comite_local.dart';
import 'package:aiesec_lar_global/data/models/nps_host.dart';
import 'package:aiesec_lar_global/data/services/intercambista_service.dart';
import 'package:aiesec_lar_global/data/services/auth_service.dart';
import 'package:aiesec_lar_global/data/services/acesso_service.dart';
import 'package:aiesec_lar_global/data/services/comite_local_service.dart';
import 'package:aiesec_lar_global/data/services/nps_service.dart';

// Imports Components
import 'components/dashboard_metric_card.dart';
import 'components/nps_feedbacks_section.dart';

class DashboardUI extends StatefulWidget {
  const DashboardUI({super.key});

  @override
  State<DashboardUI> createState() => _DashboardUIState();
}

class _DashboardUIState extends State<DashboardUI> {
  late String _uid;

  @override
  void initState() {
    super.initState();
    _uid = AuthService.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<AcessoUsuario?>(
        stream: AcessoService.instance.getAcessoStream(uid: _uid),
        builder: (context, acessoSnapshot) {
          if (acessoSnapshot.connectionState == ConnectionState.waiting &&
              !acessoSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final comiteIdLogado = acessoSnapshot.data?.comiteGerenciado;
          if (comiteIdLogado == null) {
            return const Center(child: Text("Sem comitê vinculado."));
          }

          return FutureBuilder<ComiteLocal?>(
            future: ComiteLocalService.instance.getComiteLocal(
              comiteId: comiteIdLogado,
            ),
            builder: (context, comiteSnapshot) {
              if (comiteSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final comiteNome =
                  comiteSnapshot.data?.nomePodio.toUpperCase() ?? '';
              return _buildDashboard(comiteNome);
            },
          );
        },
      ),
    );
  }

  Widget _buildDashboard(String comiteNomeLogado) {
    final isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: StreamBuilder<List<Intercambista>>(
        stream: IntercambistaService.instance.getIntercambistasStream(),
        builder: (context, epSnapshot) {
          return StreamBuilder<List<NpsHost>>(
            stream: NpsService.instance.getNpsPorComite(comiteNomeLogado),
            builder: (context, npsSnapshot) {
              if (epSnapshot.connectionState == ConnectionState.waiting ||
                  npsSnapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // --- CÁLCULOS DE OPERAÇÕES (EPS) ---
              final listaEps = (epSnapshot.data ?? [])
                  .where((i) => i.comite == comiteNomeLogado)
                  .toList();
              final totalEps = listaEps.length;
              final precisamHost = listaEps
                  .where((ep) => ep.precisaHospedagem)
                  .length;
              final garantidos = totalEps - precisamHost;

              // --- CÁLCULOS DE EXPERIÊNCIA (NPS) ---
              final avaliacoes = npsSnapshot.data ?? [];
              final totalAvaliacoes = avaliacoes.length;
              int promotores = avaliacoes.where((n) => n.notaNps >= 9).length;
              int detratores = avaliacoes.where((n) => n.notaNps <= 6).length;

              int npsScore = 0;
              double mediaNotas = 0;

              if (totalAvaliacoes > 0) {
                npsScore = (((promotores - detratores) / totalAvaliacoes) * 100)
                    .round();
                mediaNotas =
                    avaliacoes.fold(0, (sum, item) => sum + item.notaNps) /
                    totalAvaliacoes;
              }

              Color corNps = Colors.grey;
              if (totalAvaliacoes > 0) {
                if (npsScore >= 75) {
                  corNps = Colors.green;
                } else if (npsScore >= 50) {
                  corNps = Colors.blue;
                } else if (npsScore >= 0) {
                  corNps = Colors.orange;
                } else {
                  corNps = Colors.red;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- CABEÇALHO ---
                  Text(
                    "Dashboard Geral - $comiteNomeLogado",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Acompanhe o status das acomodações e a satisfação dos Hosts.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // --- SEÇÃO 1: VISÃO GERAL (MÉTRICAS UNIFICADAS) ---
                  _buildSectionTitle(
                    "Visão Geral do Comitê",
                    Icons.insights_rounded,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      // Cartões de Operações
                      DashboardMetricCard(
                        isMobile: isMobile,
                        titulo: "Total de EPs",
                        valor: totalEps.toString(),
                        icone: Icons.people_outline,
                        cor: Colors.blue,
                      ),
                      DashboardMetricCard(
                        isMobile: isMobile,
                        titulo: "Precisam de Host",
                        valor: precisamHost.toString(),
                        icone: Icons.home_work_outlined,
                        cor: Colors.orange,
                      ),
                      DashboardMetricCard(
                        isMobile: isMobile,
                        titulo: "Acomodação OK",
                        valor: garantidos.toString(),
                        icone: Icons.check_circle_outline,
                        cor: Colors.green,
                      ),
                      // Cartões de NPS
                      DashboardMetricCard(
                        isMobile: isMobile,
                        titulo: "Score NPS",
                        valor: totalAvaliacoes > 0 ? "$npsScore" : "-",
                        icone: Icons.speed,
                        cor: corNps,
                      ),
                      DashboardMetricCard(
                        isMobile: isMobile,
                        titulo: "Média das Notas",
                        valor: totalAvaliacoes > 0
                            ? mediaNotas.toStringAsFixed(1)
                            : "-",
                        icone: Icons.star_rate_rounded,
                        cor: Colors.amber,
                      ),
                      DashboardMetricCard(
                        isMobile: isMobile,
                        titulo: "Total Avaliações",
                        valor: totalAvaliacoes.toString(),
                        icone: Icons.fact_check_outlined,
                        cor: Colors.purple,
                      ),
                      DashboardMetricCard(
                        isMobile: isMobile,
                        titulo: "Promotores (9-10)",
                        valor: promotores.toString(),
                        icone: Icons.favorite_border,
                        cor: Colors.pink,
                      ),
                    ],
                  ),

                  // --- SEÇÃO 2: FEEDBACKS NPS ---
                  if (avaliacoes.isNotEmpty) ...[
                    const SizedBox(height: 48),
                    NpsFeedbacksSection(avaliacoes: avaliacoes),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
