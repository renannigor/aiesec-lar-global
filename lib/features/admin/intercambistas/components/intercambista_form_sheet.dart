import 'package:flutter/material.dart';

import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';
import 'package:aiesec_lar_global/core/widgets/selector.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/core/widgets/chip_input_field.dart';
import 'package:aiesec_lar_global/core/utils/date_text_formatter.dart'; 

import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';
import 'package:aiesec_lar_global/data/models/intercambista/descricoes.dart';
import 'package:aiesec_lar_global/data/models/intercambista/infos_pessoais.dart';
import 'package:aiesec_lar_global/data/models/ibge_model.dart';
import 'package:aiesec_lar_global/data/services/intercambista_service.dart';
import 'package:aiesec_lar_global/data/services/ibge_service.dart';

class IntercambistaFormSheet extends StatefulWidget {
  final Intercambista intercambista;

  const IntercambistaFormSheet({super.key, required this.intercambista});

  @override
  State<IntercambistaFormSheet> createState() => _IntercambistaFormSheetState();
}

class _IntercambistaFormSheetState extends State<IntercambistaFormSheet> {
  final _formKey = GlobalKey<FormState>();

  // Controllers Editáveis
  final _nacionalidadeCtrl = TextEditingController();
  final _idadeCtrl = TextEditingController();
  final _dataChegadaCtrl = TextEditingController();
  final _dataPartidaCtrl = TextEditingController();
  final _formacaoCtrl = TextEditingController();
  final _sobreMimCtrl = TextEditingController();
  final _hobbiesCtrl = TextEditingController();
  final _motivacaoCtrl = TextEditingController();
  final _alergiasCtrl = TextEditingController();
  final _restricoesCtrl = TextEditingController();

  List<String> _listaIdiomas = [];
  List<String> _listaInteresses = [];

  Pais? _paisSelecionado;
  bool _isFumante = false;
  List<Pais> _paises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final paises = await IbgeService.getPaises();
      final i = widget.intercambista;

      _idadeCtrl.text = i.idade?.toString() ?? '';
      _nacionalidadeCtrl.text = i.nacionalidade ?? '';
      _dataChegadaCtrl.text = i.dataChegada ?? '';
      _dataPartidaCtrl.text = i.dataPartida ?? '';
      _formacaoCtrl.text = i.formacao ?? '';
      _listaIdiomas = List.from(i.idiomas ?? []);
      _listaInteresses = List.from(i.interesses ?? []);
      _sobreMimCtrl.text = i.descricoes?.sobreMim ?? '';
      _hobbiesCtrl.text = i.descricoes?.hobbies ?? '';
      _motivacaoCtrl.text = i.descricoes?.motivacao ?? '';
      _alergiasCtrl.text = i.infosPessoais?.alergias ?? '';
      _restricoesCtrl.text = i.infosPessoais?.restricoes ?? '';
      _isFumante = i.infosPessoais?.fumante ?? false;

      try {
        String nomePais = i.pais ?? i.entidadeAbroad;
        _paisSelecionado = paises.firstWhere((p) => p.nome == nomePais);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _paises = paises;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarUtils.showError("Erro: $e");
      }
    }
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final old = widget.intercambista;

      final novo = Intercambista(
        // DADOS DO PODIO (Intocáveis)
        epId: old.epId,
        opId: old.opId,
        comite: old.comite,
        area: old.area,
        nome: old.nome,
        status: old.status,
        dataRePresencial: old.dataRePresencial,
        dataFinPresencial: old.dataFinPresencial,
        entidadeAbroad: old.entidadeAbroad,
        precisaHospedagem: old.precisaHospedagem,

        // DADOS ENRIQUECIDOS (Pelo Admin)
        pais: _paisSelecionado?.nome,
        nacionalidade: _nacionalidadeCtrl.text.trim(),
        idade: int.tryParse(_idadeCtrl.text),
        dataChegada: _dataChegadaCtrl.text.trim().isEmpty
            ? null
            : _dataChegadaCtrl.text.trim(), 
        dataPartida: _dataPartidaCtrl.text.trim().isEmpty
            ? null
            : _dataPartidaCtrl.text.trim(), 
        formacao: _formacaoCtrl.text.trim(),
        idiomas: _listaIdiomas,
        interesses: _listaInteresses,
        infosPessoais: InfosPessoais(
          fumante: _isFumante,
          alergias: _alergiasCtrl.text.trim(),
          restricoes: _restricoesCtrl.text.trim(),
        ),
        descricoes: Descricoes(
          sobreMim: _sobreMimCtrl.text.trim(),
          hobbies: _hobbiesCtrl.text.trim(),
          motivacao: _motivacaoCtrl.text.trim(),
        ),
      );

      await IntercambistaService.instance.salvarIntercambista(
        intercambista: novo,
      );

      if (mounted) {
        Navigator.pop(context);
        SnackbarUtils.showSuccess("Informações atualizadas!");
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError("Erro ao salvar: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // CABEÇALHO DO BOTTOM SHEET
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Enriquecer Perfil",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 24,
                ),
              ],
            ),
          ),

          // CORPO ROLÁVEL
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 100,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SEÇÃO 1: INFOS DO PODIO (Bloqueadas) ---
                    _buildSectionTitle("Informações Base (Podio)"),
                    const SizedBox(height: 16),
                    _buildResponsiveRow(isMobile, [
                      Editor(
                        controller: TextEditingController(
                          text: widget.intercambista.nome,
                        ),
                        labelText: "Nome do EP",
                        enabled: false,
                        isPassword: false,
                        keyboardType: TextInputType.name,
                      ),
                      Editor(
                        controller: TextEditingController(
                          text: widget.intercambista.status,
                        ),
                        labelText: "Status (EXPA)",
                        enabled: false,
                        isPassword: false,
                        keyboardType: TextInputType.text,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildResponsiveRow(isMobile, [
                      Editor(
                        controller: TextEditingController(
                          text: widget.intercambista.dataRePresencial,
                        ),
                        labelText: "Início do Projeto (Podio)",
                        prefixIcon: Icons.work_outline,
                        enabled: false,
                        isPassword: false,
                        keyboardType: TextInputType.text,
                      ),
                      Editor(
                        controller: TextEditingController(
                          text: widget.intercambista.dataFinPresencial,
                        ),
                        labelText: "Fim do Projeto (Podio)",
                        prefixIcon: Icons.work_off_outlined,
                        enabled: false,
                        isPassword: false,
                        keyboardType: TextInputType.text,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildResponsiveRow(isMobile, [
                      Editor(
                        controller: TextEditingController(
                          text: widget.intercambista.entidadeAbroad,
                        ),
                        labelText: "Entidade Abroad",
                        enabled: false,
                        isPassword: false,
                        keyboardType: TextInputType.text,
                      ),
                      Editor(
                        controller: TextEditingController(
                          text: widget.intercambista.area,
                        ),
                        labelText: "Área",
                        enabled: false,
                        isPassword: false,
                        keyboardType: TextInputType.text,
                      ),
                    ]),

                    const SizedBox(height: 32),

                    // --- SEÇÃO 1.5: DATAS DE VOO (Novos campos) ---
                    _buildSectionTitle("Hospedagem e Voos"),
                    const SizedBox(height: 8),
                    const Text(
                      "As datas de chegada e partida podem diferir das datas do projeto no Podio. Preencha conforme a passagem aérea do intercambista.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    _buildResponsiveRow(isMobile, [
                      Editor(
                        controller: _dataChegadaCtrl,
                        labelText: "Voo de Chegada",
                        hintText: "DD/MM/AAAA",
                        prefixIcon: Icons.flight_land,
                        inputFormatters: [DateTextFormatter()],
                        isPassword: false,
                        enabled: true,
                        keyboardType: TextInputType.text,
                      ),
                      Editor(
                        controller: _dataPartidaCtrl,
                        labelText: "Voo de Partida",
                        hintText: "DD/MM/AAAA",
                        prefixIcon: Icons.flight_takeoff,
                        inputFormatters: [DateTextFormatter()],
                        isPassword: false,
                        enabled: true,
                        keyboardType: TextInputType.text,
                      ),
                    ]),

                    const SizedBox(height: 32),

                    // --- SEÇÃO 2: DADOS PESSOAIS ---
                    _buildSectionTitle("Dados Pessoais"),
                    const SizedBox(height: 16),
                    _buildResponsiveRow(isMobile, [
                      Editor(
                        controller: _idadeCtrl,
                        labelText: "Idade",
                        keyboardType: TextInputType.number,
                        isPassword: false,
                        enabled: true,
                      ),
                      Editor(
                        controller: _nacionalidadeCtrl,
                        labelText: "Nacionalidade",
                        isPassword: false,
                        enabled: true,
                        keyboardType: TextInputType.text,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Selector<Pais>(
                      labelText: "País de Origem",
                      items: _paises,
                      value: _paisSelecionado,
                      itemLabelBuilder: (p) => p.nome,
                      onChanged: (p) => setState(() => _paisSelecionado = p),
                    ),

                    const SizedBox(height: 32),

                    // --- SEÇÃO 3: HABILIDADES E INTERESSES ---
                    _buildSectionTitle("Habilidades e Interesses"),
                    const SizedBox(height: 16),
                    Editor(
                      controller: _formacaoCtrl,
                      labelText: "Formação Acadêmica",
                      isPassword: false,
                      enabled: true,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    ChipInputField(
                      label: "Idiomas",
                      hint: "Digite e dê enter",
                      items: _listaIdiomas,
                      onChanged: (list) => setState(() => _listaIdiomas = list),
                    ),
                    const SizedBox(height: 16),
                    ChipInputField(
                      label: "Interesses",
                      hint: "Digite e dê enter",
                      items: _listaInteresses,
                      onChanged: (list) =>
                          setState(() => _listaInteresses = list),
                    ),

                    const SizedBox(height: 32),

                    // --- SEÇÃO 4: MAIS SOBRE O EP ---
                    _buildSectionTitle("Mais sobre o EP"),
                    const SizedBox(height: 16),
                    Editor(
                      controller: _sobreMimCtrl,
                      labelText: "Sobre Mim",
                      keyboardType: TextInputType.multiline,
                      isPassword: false,
                      enabled: true,
                    ),
                    const SizedBox(height: 16),
                    Editor(
                      controller: _hobbiesCtrl,
                      labelText: "Hobbies",
                      keyboardType: TextInputType.multiline,
                      isPassword: false,
                      enabled: true,
                    ),
                    const SizedBox(height: 16),
                    Editor(
                      controller: _motivacaoCtrl,
                      labelText: "Motivação",
                      keyboardType: TextInputType.multiline,
                      isPassword: false,
                      enabled: true,
                    ),

                    const SizedBox(height: 32),

                    // --- SEÇÃO 5: SAÚDE E RESTRIÇÕES ---
                    _buildSectionTitle("Saúde e Restrições"),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text("É Fumante?"),
                      value: _isFumante,
                      onChanged: (v) => setState(() => _isFumante = v!),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                    Editor(
                      controller: _alergiasCtrl,
                      labelText: "Alergias",
                      isPassword: false,
                      enabled: true,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    Editor(
                      controller: _restricoesCtrl,
                      labelText: "Restrições Alimentares",
                      isPassword: false,
                      enabled: true,
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // RODAPÉ FIXO COM O BOTÃO DE SALVAR
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Salvar Alterações",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildResponsiveRow(bool isMobile, List<Widget> children) {
    if (isMobile) {
      return Column(
        children: children
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 16), child: c),
            )
            .toList(),
      );
    } else {
      return Row(
        children: children.asMap().entries.map((entry) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: entry.key < children.length - 1 ? 16 : 0,
              ),
              child: entry.value,
            ),
          );
        }).toList(),
      );
    }
  }
}
