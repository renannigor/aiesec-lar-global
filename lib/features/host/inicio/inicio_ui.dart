import 'package:aiesec_lar_global/data/models/area_filtro.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';
import 'package:aiesec_lar_global/data/services/intercambista_service.dart';

import 'package:aiesec_lar_global/features/host/inicio/components/inicio_header.dart';
import 'package:aiesec_lar_global/features/host/inicio/components/secao_motivos_hospedar.dart';
import 'widgets/intercambista_card.dart';
import 'inicio_constantes.dart';

import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/core/widgets/selector.dart'; // <-- IMPORT DO SEU SELECTOR

class InicioUI extends StatefulWidget {
  final VoidCallback onIrParaPerfil;
  final VoidCallback onIrParaInteresses;

  const InicioUI({
    super.key,
    required this.onIrParaPerfil,
    required this.onIrParaInteresses,
  });

  @override
  State<InicioUI> createState() => _InicioUIState();
}

class _InicioUIState extends State<InicioUI> {
  String? _entidadeSelecionada;
  String? _comiteSelecionado;
  String? _filtroAcomodacao;
  String? _areaSelecionada;
  DateTimeRange? _periodoChegada;

  int _quantidadeExibida = 6;
  late Stream<List<Intercambista>> _streamIntercambistas;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _filtrosKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _streamIntercambistas = IntercambistaService.instance
        .getIntercambistasStream();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _rolarParaFiltros() {
    final context = _filtrosKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        alignment: 0.0,
      );
    }
  }

  void _voltarParaTopo() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _limparFiltros() {
    setState(() {
      _entidadeSelecionada = null;
      _comiteSelecionado = null;
      _filtroAcomodacao = null;
      _areaSelecionada = null;
      _periodoChegada = null;
      _quantidadeExibida = 6;
    });
  }

  void _carregarMais() {
    setState(() {
      _quantidadeExibida += 6;
    });
  }

  Future<void> _escolherPeriodo() async {
    final DateTimeRange? selecionado = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _periodoChegada,
      saveText: 'Aplicar',
      cancelText: 'Cancelar',
      helpText: 'Selecione o período de chegada',
    );

    if (selecionado != null) {
      setState(() {
        _periodoChegada = selecionado;
        _quantidadeExibida = 6;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Intercambista>>(
        stream: _streamIntercambistas,
        builder: (context, snapshot) {
          final isLoadingData =
              snapshot.connectionState == ConnectionState.waiting;
          final todosIntercambistas = snapshot.data ?? [];

          final comitesDisponiveis =
              todosIntercambistas
                  .map((e) => e.comite)
                  .where((c) => c.isNotEmpty && c != 'Não preenchido')
                  .toSet()
                  .toList()
                ..sort();

          final entidadesDisponiveis =
              todosIntercambistas
                  .map((e) => e.entidadeAbroad)
                  .where((ent) => ent.isNotEmpty && ent != 'Não preenchido')
                  .toSet()
                  .toList()
                ..sort();

          final listaFiltrada = todosIntercambistas.where((i) {
            if (_entidadeSelecionada != null &&
                i.entidadeAbroad != _entidadeSelecionada) {
              return false;
            }
            if (_comiteSelecionado != null && i.comite != _comiteSelecionado) {
              return false;
            }

            // FILTRO DE ÁREA
            if (_areaSelecionada != null && i.area != _areaSelecionada) {
              return false;
            }

            if (_filtroAcomodacao != null) {
              bool buscaPorNecessidade = _filtroAcomodacao == 'Sim';
              if (i.precisaHospedagem != buscaPorNecessidade) return false;
            }

            if (_periodoChegada != null) {
              final dataChegadaStr = i.dataChegada ?? i.dataRePresencial;
              if (dataChegadaStr.isEmpty || dataChegadaStr == 'Não informado') {
                return false;
              }
              try {
                final dataChegadaEp = DateTime.parse(dataChegadaStr);
                final chegadaLimpa = DateTime(
                  dataChegadaEp.year,
                  dataChegadaEp.month,
                  dataChegadaEp.day,
                );
                final inicioFiltro = DateTime(
                  _periodoChegada!.start.year,
                  _periodoChegada!.start.month,
                  _periodoChegada!.start.day,
                );
                final fimFiltro = DateTime(
                  _periodoChegada!.end.year,
                  _periodoChegada!.end.month,
                  _periodoChegada!.end.day,
                );

                if (chegadaLimpa.isBefore(inicioFiltro) ||
                    chegadaLimpa.isAfter(fimFiltro)) {
                  return false;
                }
              } catch (e) {
                return false;
              }
            }
            return true;
          }).toList();

          final listaPaginada = listaFiltrada.take(_quantidadeExibida).toList();

          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                InicioHeader(
                  onStartPressed: _rolarParaFiltros,
                  onProfilePressed: widget.onIrParaPerfil,
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      key: _filtrosKey,
                      padding: const EdgeInsets.symmetric(
                        vertical: 60,
                        horizontal: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  "Filtros de Busca",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Encontre o intercambista ideal filtrando por comitê, área de atuação e país de origem.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          Center(
                            child: Column(
                              children: [
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    // 1. FILTRO PAÍS
                                    SizedBox(
                                      width: 220,
                                      child: Selector<String>(
                                        labelText:
                                            "Países com intercambistas agora",
                                        value: _entidadeSelecionada,
                                        items: entidadesDisponiveis,
                                        onChanged: (val) => setState(() {
                                          _entidadeSelecionada = val;
                                          _quantidadeExibida = 6;
                                        }),
                                        isFilter: true,
                                      ),
                                    ),

                                    // 2. FILTRO COMITÊ
                                    SizedBox(
                                      width: 220,
                                      child: Selector<String>(
                                        labelText: "Comitês recebendo agora",
                                        value: _comiteSelecionado,
                                        items: comitesDisponiveis,
                                        onChanged: (val) => setState(() {
                                          _comiteSelecionado = val;
                                          _quantidadeExibida = 6;
                                        }),
                                        isFilter: true,
                                      ),
                                    ),

                                    // 3. FILTRO DE ÁREA (COM SEU ITEM LABEL BUILDER)
                                    SizedBox(
                                      width: 220,
                                      child: Selector<AreaFiltro>(
                                        labelText: "Tipo de Intercâmbio",
                                        // Recuperamos o objeto AreaFiltro baseado na string salva
                                        value: _areaSelecionada != null
                                            ? InicioConstantes.opcoesAreas
                                                  .firstWhere(
                                                    (a) =>
                                                        a.value ==
                                                        _areaSelecionada,
                                                    orElse: () =>
                                                        InicioConstantes
                                                            .opcoesAreas
                                                            .first,
                                                  )
                                            : null,
                                        items: InicioConstantes.opcoesAreas,
                                        itemLabelBuilder: (area) => area.label,
                                        onChanged: (val) => setState(() {
                                          _areaSelecionada = val?.value;
                                          _quantidadeExibida = 6;
                                        }),
                                        isFilter: true,
                                      ),
                                    ),

                                    // 4. FILTRO ACOMODAÇÃO
                                    SizedBox(
                                      width: 220,
                                      child: Selector<String>(
                                        labelText: "Precisa acomodação?",
                                        value: _filtroAcomodacao,
                                        items:
                                            InicioConstantes.filtroAcomodacao,
                                        onChanged: (val) => setState(() {
                                          _filtroAcomodacao = val;
                                          _quantidadeExibida = 6;
                                        }),
                                        isFilter: true,
                                      ),
                                    ),

                                    // 5. FILTRO DE DATAS (Mantém o visual customizado)
                                    InkWell(
                                      onTap: _escolherPeriodo,
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _periodoChegada != null
                                                ? Colors.blue
                                                : Colors.grey.shade400,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          color: _periodoChegada != null
                                              ? Colors.blue.shade50
                                              : Colors.transparent,
                                        ),
                                        width: 220,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_month,
                                              size: 16,
                                              color: _periodoChegada != null
                                                  ? Colors.blue
                                                  : Colors.grey.shade700,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _periodoChegada == null
                                                    ? "Período de Chegada"
                                                    : "${DateFormat('dd/MM/yy').format(_periodoChegada!.start)} a ${DateFormat('dd/MM/yy').format(_periodoChegada!.end)}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: _periodoChegada != null
                                                      ? Colors.blue.shade700
                                                      : Colors.grey.shade700,
                                                  fontWeight:
                                                      _periodoChegada != null
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                TextButton.icon(
                                  onPressed: _limparFiltros,
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text("Limpar Filtros"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              isLoadingData
                                  ? "Carregando..."
                                  : "${listaFiltrada.length} intercambistas encontrados",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (isLoadingData)
                            const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (listaPaginada.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Nenhum resultado para os filtros aplicados.",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Column(
                              children: [
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent:
                                            Responsive.isMobile(context)
                                            ? MediaQuery.of(context).size.width
                                            : 350,
                                        mainAxisExtent: 440,
                                        crossAxisSpacing: 24,
                                        mainAxisSpacing: 24,
                                      ),
                                  itemCount: listaPaginada.length,
                                  itemBuilder: (context, index) {
                                    final ep = listaPaginada[index];
                                    return IntercambistaCard(
                                      intercambista: ep,
                                      onInteresseSalvo:
                                          widget.onIrParaInteresses,
                                    );
                                  },
                                ),

                                const SizedBox(height: 40),

                                Column(
                                  children: [
                                    if (listaFiltrada.length >
                                        _quantidadeExibida)
                                      ElevatedButton(
                                        onPressed: _carregarMais,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          "Carregar mais",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (listaFiltrada.length >
                                        _quantidadeExibida)
                                      const SizedBox(height: 16),

                                    OutlinedButton(
                                      onPressed: _voltarParaTopo,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black87,
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Voltar para o topo",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          const SizedBox(height: 100),
                          const SecaoMotivosHospedar(),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
