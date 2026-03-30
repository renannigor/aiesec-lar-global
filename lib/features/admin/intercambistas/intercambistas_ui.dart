import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Imports Core
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/core/widgets/selector.dart';

// Imports Data
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';
import 'package:aiesec_lar_global/data/models/ibge_model.dart';
import 'package:aiesec_lar_global/data/services/intercambista_service.dart';
import 'package:aiesec_lar_global/data/services/auth_service.dart';
import 'package:aiesec_lar_global/data/services/usuario_service.dart';
import 'package:aiesec_lar_global/data/services/ibge_service.dart';

// Imports Widgets Locais
import './widgets/intercambista_card.dart';
import './intercambista_form_ui.dart';
import 'intercambista_detalhes_ui.dart';

class IntercambistasUI extends StatefulWidget {
  const IntercambistasUI({super.key});

  @override
  State<IntercambistasUI> createState() => _IntercambistasUIState();
}

class _IntercambistasUIState extends State<IntercambistasUI> {
  // Dados
  List<Intercambista> _todosIntercambistas = [];
  List<Intercambista> _listaExibida = [];
  String?
  _comiteLogado; // O Podio traz o nome do comitê em String ("FORTALEZA")
  bool _isLoading = true;

  // Listas para Filtros
  List<Pais> _paisesDisponiveis = [];

  // Estados dos Filtros
  String? _filtroStatus;
  Pais? _filtroPais;
  DateTime? _filtroDataInicio;
  DateTime? _filtroDataTermino;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    setState(() => _isLoading = true);
    try {
      // 1. Identificar o Admin e seu Comitê
      final uid = AuthService.instance.currentUser?.uid;
      if (uid != null) {
        final u = await UsuarioService.instance.getUsuario(uid: uid);
        // Considerando que u?.comiteLocalId seja o NOME do comitê agora (para bater com o Podio)
        _comiteLogado = u?.comiteLocalId;
      }

      // 2. Carregar lista de Países para o filtro
      _paisesDisponiveis = await IbgeService.getPaises();

      // 3. Ouvir Stream de Intercambistas
      IntercambistaService.instance.getIntercambistasStream().listen((lista) {
        if (!mounted) return;
        setState(() {
          // Filtra: Apenas os que PRECISAM DE HOSPEDAGEM
          _todosIntercambistas = lista
              .where((i) => i.precisaHospedagem == true)
              .toList();
          _aplicarFiltros();
          _isLoading = false;
        });
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarUtils.showError("Erro ao carregar dados: $e");
      }
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _listaExibida = _todosIntercambistas.where((i) {
        // 1. Status
        bool matchStatus =
            _filtroStatus == null ||
            _filtroStatus == 'Todos' ||
            i.status.toLowerCase() == _filtroStatus!.toLowerCase();

        // 2. País (Usa pais manual ou a entidadeAbroad do Podio)
        final String paisAtual = i.pais ?? i.entidadeAbroad;
        bool matchPais = _filtroPais == null || paisAtual == _filtroPais!.nome;

        // 3. Datas (Convertendo string do Podio para DateTime seguro)
        DateTime? dtInicioPodio = DateTime.tryParse(i.dataRePresencial);
        bool matchInicio =
            _filtroDataInicio == null ||
            (dtInicioPodio != null &&
                !dtInicioPodio.isBefore(_filtroDataInicio!));

        DateTime? dtFimPodio = DateTime.tryParse(i.dataFinPresencial);
        bool matchFim =
            _filtroDataTermino == null ||
            (dtFimPodio != null && !dtFimPodio.isAfter(_filtroDataTermino!));

        return matchStatus && matchPais && matchInicio && matchFim;
      }).toList();
    });
  }

  // --- AÇÕES ---

  void _navegarParaFormulario({Intercambista? intercambista}) {
    if (_comiteLogado == null) {
      SnackbarUtils.showError("Sem comitê vinculado.");
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IntercambistaFormUI(
          intercambista: intercambista,
          comiteLocalId: _comiteLogado!,
        ),
      ),
    );
  }

  void _verDetalhes(Intercambista i) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IntercambistaDetalhesUI(intercambista: i),
      ),
    );
  }

  Future<void> _deletar(String epId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Intercambista"),
        content: const Text("Tem certeza? Essa ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await IntercambistaService.instance.deletarIntercambista(epId: epId);
      SnackbarUtils.showInfo("Excluído com sucesso.");
    }
  }

  Future<void> _pickFilterDate(bool isInicio) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (d != null) {
      setState(() => isInicio ? _filtroDataInicio = d : _filtroDataTermino = d);
      _aplicarFiltros();
    }
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- CABEÇALHO ---
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Intercambistas",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Gerencie os EPs que precisam de hospedagem.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navegarParaFormulario(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Novo Intercambista",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Intercambistas",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Gerencie seus intercambistas que precisam de hospedagem",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _navegarParaFormulario(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      "Novo Intercambista",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            // --- FILTROS ---
            isMobile
                ? Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.start,
                    children: _buildFilterWidgets(isMobile: true),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: _buildFilterWidgets(isMobile: false)),
                  ),

            const SizedBox(height: 24),

            // --- LISTA ---
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_listaExibida.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text("Nenhum resultado encontrado."),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _listaExibida.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => IntercambistaCard(
                  intercambista: _listaExibida[i],
                  onEdit: () =>
                      _navegarParaFormulario(intercambista: _listaExibida[i]),
                  onDelete: () => _deletar(_listaExibida[i].epId),
                  onViewDetails: () => _verDetalhes(_listaExibida[i]),
                  onViewApplicants: () =>
                      SnackbarUtils.showInfo("Lista de aplicantes em breve"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilterWidgets({required bool isMobile}) {
    final double width = isMobile
        ? (MediaQuery.of(context).size.width / 2) - 24
        : 160;

    return [
      SizedBox(
        width: width,
        child: Selector<String>(
          labelText: "Status",
          // Ajustado para status que fazem sentido no ecossistema do Podio (EXPA)
          items: const [
            'Todos',
            'Approved',
            'Realized',
            'Finished',
            'Completed',
          ],
          value: _filtroStatus,
          onChanged: (v) {
            _filtroStatus = v;
            _aplicarFiltros();
          },
        ),
      ),
      if (!isMobile) const SizedBox(width: 12),

      SizedBox(
        width: width,
        child: Selector<Pais>(
          labelText: "País",
          items: _paisesDisponiveis,
          itemLabelBuilder: (p) => p.nome,
          value: _filtroPais,
          onChanged: (v) {
            _filtroPais = v;
            _aplicarFiltros();
          },
        ),
      ),
      if (!isMobile) const SizedBox(width: 12),

      SizedBox(
        width: width,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.date_range, size: 16),
          label: Text(
            _filtroDataInicio == null
                ? "Início >="
                : "> ${_formatDate(_filtroDataInicio!)}",
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          ),
          onPressed: () => _pickFilterDate(true),
        ),
      ),
      if (!isMobile) const SizedBox(width: 8),

      SizedBox(
        width: width,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.date_range, size: 16),
          label: Text(
            _filtroDataTermino == null
                ? "Fim <="
                : "< ${_formatDate(_filtroDataTermino!)}",
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          ),
          onPressed: () => _pickFilterDate(false),
        ),
      ),
      if (!isMobile) const SizedBox(width: 12),

      SizedBox(
        width: isMobile ? double.infinity : null,
        child: TextButton(
          onPressed: () {
            setState(() {
              _filtroStatus = null;
              _filtroPais = null;
              _filtroDataInicio = null;
              _filtroDataTermino = null;
              _aplicarFiltros();
            });
          },
          child: const Text(
            "Limpar Filtros",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    ];
  }

  String _formatDate(DateTime d) => DateFormat('dd/MM').format(d);
}
