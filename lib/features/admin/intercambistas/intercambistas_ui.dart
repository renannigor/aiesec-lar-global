import 'package:flutter/material.dart';
import 'dart:math';

// Imports Core
import 'package:aiesec_lar_global/core/widgets/responsive.dart';

// Imports Data
import 'package:aiesec_lar_global/data/models/acesso_usuario.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/services/intercambista_service.dart';
import 'package:aiesec_lar_global/data/services/auth_service.dart';
import 'package:aiesec_lar_global/data/services/acesso_service.dart';
import 'package:aiesec_lar_global/data/services/comite_local_service.dart';

// Imports UI Components
import 'package:aiesec_lar_global/features/admin/intercambistas/components/detalhes_intercambista_sheet.dart';
import 'package:aiesec_lar_global/features/admin/intercambistas/components/intercambista_form_sheet.dart';
import 'package:aiesec_lar_global/features/admin/aplicantes/aplicantes_ui.dart';
import 'package:aiesec_lar_global/features/admin/intercambistas/components/intercambistas_filters.dart';
import 'package:aiesec_lar_global/features/admin/intercambistas/components/intercambistas_table.dart';

class IntercambistasUI extends StatefulWidget {
  const IntercambistasUI({super.key});

  @override
  State<IntercambistasUI> createState() => _IntercambistasUIState();
}

class _IntercambistasUIState extends State<IntercambistasUI> {
  late String _uid;

  // Filtros
  String? _filtroStatus;
  String _filtroHospedagem = 'Todos';
  String? _filtroArea;
  DateTime? _filtroDataInicio;
  DateTime? _filtroDataTermino;

  // Paginação
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _uid = AuthService.instance.currentUser?.uid ?? '';
  }

  void _atualizarTela() => setState(() => _currentPage = 1);

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
          if (comiteIdLogado == null) return _buildBody(null);

          return FutureBuilder<ComiteLocal?>(
            future: ComiteLocalService.instance.getComiteLocal(
              comiteId: comiteIdLogado,
            ),
            builder: (context, comiteSnapshot) {
              if (comiteSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final comiteNome = comiteSnapshot.data?.nomePodio.toUpperCase();

              return _buildBody(comiteNome);
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(String? comiteNomeLogado) {
    final isMobile = Responsive.isMobile(context);

    return StreamBuilder<List<Intercambista>>(
      stream: IntercambistaService.instance.getIntercambistasStream(),
      builder: (context, epSnapshot) {
        if (epSnapshot.connectionState == ConnectionState.waiting &&
            !epSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final todosIntercambistas = epSnapshot.data ?? [];

        // 1. Filtragem de Dados
        final listaExibida = todosIntercambistas.where((i) {
          if (comiteNomeLogado != null && i.comite != comiteNomeLogado) {
            return false;
          }
          bool matchStatus =
              _filtroStatus == null ||
              _filtroStatus == 'Todos' ||
              i.status.toLowerCase() == _filtroStatus!.toLowerCase();

          bool matchHospedagem =
              _filtroHospedagem == 'Todos' ||
              (_filtroHospedagem == 'Sim' && i.precisaHospedagem) ||
              (_filtroHospedagem == 'Não' && !i.precisaHospedagem);

          bool matchArea = _filtroArea == null || i.area == _filtroArea;

          DateTime? dtInicioPodio = DateTime.tryParse(i.dataRePresencial);
          bool matchInicio =
              _filtroDataInicio == null ||
              (dtInicioPodio != null &&
                  !dtInicioPodio.isBefore(_filtroDataInicio!));

          DateTime? dtFimPodio = DateTime.tryParse(i.dataFinPresencial);
          bool matchFim =
              _filtroDataTermino == null ||
              (dtFimPodio != null && !dtFimPodio.isAfter(_filtroDataTermino!));

          return matchStatus &&
              matchHospedagem &&
              matchArea &&
              matchInicio &&
              matchFim;
        }).toList();

        // 2. Cálculos de Paginação
        final totalItems = listaExibida.length;
        final totalPages = (totalItems / _itemsPerPage).ceil();
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = min(startIndex + _itemsPerPage, totalItems);
        final paginatedList = totalItems > 0
            ? listaExibida.sublist(startIndex, endIndex)
            : <Intercambista>[];

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- CABEÇALHO E FILTROS ---
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(comiteNomeLogado, totalItems),
                    const SizedBox(height: 24),
                    _buildFilters(isMobile),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(comiteNomeLogado, totalItems),
                    const SizedBox(width: 24),
                    _buildFilters(isMobile),
                  ],
                ),

              const SizedBox(height: 32),

              // --- MINI DASHBOARD LOCAL ---
              _buildMiniDash(listaExibida, isMobile),

              const SizedBox(height: 32),

              // --- TABELA ---
              IntercambistasTable(
                isMobile: isMobile,
                listaExibida: listaExibida,
                paginatedList: paginatedList,
                totalItems: totalItems,
                totalPages: totalPages,
                currentPage: _currentPage,
                startIndex: startIndex,
                endIndex: endIndex,
                comiteNomeLogado: comiteNomeLogado,
                onPageChanged: (page) => setState(() => _currentPage = page),
                onVerAplicantes: (ep) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AplicantesUI(intercambista: ep),
                  ),
                ),
                onEditar: (ep) => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => FractionallySizedBox(
                    heightFactor: 0.92,
                    child: IntercambistaFormSheet(intercambista: ep),
                  ),
                ),
                onVerDetalhes: (ep) => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => FractionallySizedBox(
                    heightFactor: 0.92,
                    child: DetalhesIntercambistaSheets(intercambista: ep),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitle(String? comiteNomeLogado, int totalItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Intercambistas ${comiteNomeLogado != null ? '- $comiteNomeLogado' : ''}",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Encontramos $totalItems resultados baseados nos filtros.",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ],
    );
  }

  // --- MÉTODO DO DASHBOARD ---
  Widget _buildMiniDash(List<Intercambista> lista, bool isMobile) {
    if (lista.isEmpty) return const SizedBox.shrink();

    final total = lista.length;
    final precisamHost = lista.where((ep) => ep.precisaHospedagem).length;
    final garantidos = total - precisamHost;

    // EPs chegando nos próximos 30 dias que ainda precisam de Host
    final hoje = DateTime.now();
    final limite30Dias = hoje.add(const Duration(days: 30));
    final chegandoEmBreve = lista.where((ep) {
      if (!ep.precisaHospedagem) return false;
      DateTime? dtChegada = DateTime.tryParse(
        ep.dataChegada ?? ep.dataRePresencial,
      );
      if (dtChegada == null) return false;
      return dtChegada.isAfter(hoje) && dtChegada.isBefore(limite30Dias);
    }).length;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildDashCard(
          isMobile,
          titulo: "Total de EPs",
          valor: total.toString(),
          icone: Icons.people_outline,
          cor: Colors.blue,
        ),
        _buildDashCard(
          isMobile,
          titulo: "Precisam de Host",
          valor: precisamHost.toString(),
          icone: Icons.home_work_outlined,
          cor: Colors.orange,
        ),
        _buildDashCard(
          isMobile,
          titulo: "Acomodação OK",
          valor: garantidos.toString(),
          icone: Icons.check_circle_outline,
          cor: Colors.green,
        ),
        _buildDashCard(
          isMobile,
          titulo: "Chegando (< 30 dias)",
          valor: chegandoEmBreve.toString(),
          icone: Icons.warning_amber_rounded,
          cor: chegandoEmBreve > 0 ? Colors.red : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildDashCard(
    bool isMobile, {
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {
    return Container(
      width: isMobile ? double.infinity : 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: cor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isMobile) {
    return IntercambistasFilters(
      isMobile: isMobile,
      filtroStatus: _filtroStatus,
      filtroHospedagem: _filtroHospedagem,
      filtroArea: _filtroArea,
      filtroDataInicio: _filtroDataInicio,
      filtroDataTermino: _filtroDataTermino,
      onStatusChanged: (v) {
        _filtroStatus = v;
        _atualizarTela();
      },
      onHospedagemChanged: (v) {
        _filtroHospedagem = v ?? 'Todos';
        _atualizarTela();
      },
      onAreaChanged: (v) {
        _filtroArea = v;
        _atualizarTela();
      },
      onDateChanged: (d, isInicio) {
        isInicio ? _filtroDataInicio = d : _filtroDataTermino = d;
        _atualizarTela();
      },
      onClear: () {
        _filtroStatus = null;
        _filtroHospedagem = 'Todos';
        _filtroArea = null;
        _filtroDataInicio = null;
        _filtroDataTermino = null;
        _atualizarTela();
      },
    );
  }
}
