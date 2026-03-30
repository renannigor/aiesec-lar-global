import 'package:aiesec_lar_global/data/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/aplicacao.dart';
import 'package:aiesec_lar_global/data/services/aplicacao_service.dart';

import 'widgets/aplicacao_card.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';

class InteressesUI extends StatefulWidget {
  const InteressesUI({super.key});

  @override
  State<InteressesUI> createState() => _InteressesUIState();
}

class _InteressesUIState extends State<InteressesUI> {
  final String? _hostUid = AuthService.instance.currentUser?.uid;
  late Stream<List<Aplicacao>> _aplicacoesStream;

  @override
  void initState() {
    super.initState();
    if (_hostUid != null) {
      _aplicacoesStream = AplicacaoService.instance.getAplicacoesDoHostStream(
        hostUid: _hostUid,
      );
    } else {
      _aplicacoesStream = const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hostUid == null) {
      return const Center(child: Text("Erro: Usuário não autenticado."));
    }

    final isMobile = Responsive.isMobile(context);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        // FUNDO BRANCO NA ÁREA DOS CARDS
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // --- CABEÇALHO CINZA CLARO ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F8), // Fundo cinza na parte de cima
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                  ), // Linha sutil dividindo as áreas
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top:
                          MediaQuery.of(context).padding.top +
                          (isMobile ? 24 : 40),
                      left: isMobile ? 16 : 24,
                      right: isMobile ? 16 : 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Minhas aplicações",
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Gerencie seus hóspedes e solicitações",
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ABAS DE NAVEGAÇÃO
                        TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          dividerColor: Colors
                              .transparent, // Removemos o divider interno da TabBar pois o Container já tem borda
                          labelColor: Colors.black87,
                          unselectedLabelColor: Colors.grey.shade500,
                          indicatorColor: AppColors.primary,
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(text: "Ativos"),
                            Tab(text: "Hospedando"),
                            Tab(text: "Concluídos"),
                            Tab(text: "Cancelados"),
                            Tab(text: "Não Aprovados"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- CONTEÚDO (LISTA DE CARDS) ---
            Expanded(
              child: StreamBuilder<List<Aplicacao>>(
                stream: _aplicacoesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Erro ao carregar aplicações."),
                    );
                  }

                  final todasAplicacoes = snapshot.data ?? [];

                  if (todasAplicacoes.isEmpty) {
                    return _buildEmptyState();
                  }

                  final ativos = todasAplicacoes
                      .where(
                        (a) =>
                            a.status != StatusAplicacao.hospedando &&
                            a.status != StatusAplicacao.concluida &&
                            a.status != StatusAplicacao.cancelada &&
                            a.status != StatusAplicacao.rejeitada,
                      )
                      .toList();

                  final hospedando = todasAplicacoes
                      .where((a) => a.status == StatusAplicacao.hospedando)
                      .toList();
                  final concluidos = todasAplicacoes
                      .where((a) => a.status == StatusAplicacao.concluida)
                      .toList();
                  final cancelados = todasAplicacoes
                      .where((a) => a.status == StatusAplicacao.cancelada)
                      .toList();
                  final rejeitados = todasAplicacoes
                      .where((a) => a.status == StatusAplicacao.rejeitada)
                      .toList();

                  return TabBarView(
                    children: [
                      _buildListView(ativos, isMobile),
                      _buildListView(hospedando, isMobile),
                      _buildListView(concluidos, isMobile),
                      _buildListView(cancelados, isMobile),
                      _buildListView(rejeitados, isMobile),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Você ainda não tem aplicações nesta categoria.",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Aplicacao> lista, bool isMobile) {
    if (lista.isEmpty) {
      return _buildEmptyState();
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: 32,
          ),
          itemCount: lista.length,
          separatorBuilder: (context, index) =>
              Divider(height: 48, color: Colors.grey.shade300),
          itemBuilder: (context, index) {
            return AplicacaoCard(aplicacao: lista[index]);
          },
        ),
      ),
    );
  }
}
