import 'package:aiesec_lar_global/data/models/intercambista/descricoes.dart';
import 'package:aiesec_lar_global/data/models/intercambista/infos_pessoais.dart';
import 'package:flutter/material.dart';

// Imports Core
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';
import 'package:aiesec_lar_global/core/widgets/selector.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/core/utils/form_validators.dart';
import 'package:aiesec_lar_global/core/utils/date_text_formatter.dart';
import 'package:aiesec_lar_global/core/widgets/chip_input_field.dart';

// Imports Data
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';
import 'package:aiesec_lar_global/data/models/ibge_model.dart';
import 'package:aiesec_lar_global/data/services/intercambista_service.dart';
import 'package:aiesec_lar_global/data/services/ibge_service.dart';

class IntercambistaFormUI extends StatefulWidget {
  final Intercambista? intercambista;
  final String comiteLocalId;

  const IntercambistaFormUI({
    super.key,
    this.intercambista,
    required this.comiteLocalId,
  });

  @override
  State<IntercambistaFormUI> createState() => _IntercambistaFormUIState();
}

class _IntercambistaFormUIState extends State<IntercambistaFormUI> {
  // Chaves para validar cada Step
  final _stepKeys = List.generate(4, (_) => GlobalKey<FormState>());

  int _currentStep = 0;

  // Controllers
  final _nomeCtrl = TextEditingController();
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
  String _statusSelecionado = 'Approved'; // Status padrão do Podio
  bool _isFumante = false;

  List<Pais> _paises = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    try {
      // Carrega apenas os países, já que cidade/estado agora ficam na Oportunidade
      final paises = await IbgeService.getPaises();

      if (widget.intercambista != null) {
        final i = widget.intercambista!;
        _nomeCtrl.text = i.nome;
        _idadeCtrl.text = i.idade?.toString() ?? '';
        _nacionalidadeCtrl.text = i.nacionalidade ?? '';
        _formacaoCtrl.text = i.formacao ?? '';

        _listaIdiomas = List.from(i.idiomas ?? []);
        _listaInteresses = List.from(i.interesses ?? []);

        _sobreMimCtrl.text = i.descricoes?.sobreMim ?? '';
        _hobbiesCtrl.text = i.descricoes?.hobbies ?? '';
        _motivacaoCtrl.text = i.descricoes?.motivacao ?? '';

        _alergiasCtrl.text = i.infosPessoais?.alergias ?? '';
        _restricoesCtrl.text = i.infosPessoais?.restricoes ?? '';
        _isFumante = i.infosPessoais?.fumante ?? false;

        _dataChegadaCtrl.text = i.dataChegada ?? '';
        _dataPartidaCtrl.text = i.dataPartida ?? '';

        // Mantém o status original ou define um padrão
        if (i.status.isNotEmpty) _statusSelecionado = i.status;

        try {
          // Tenta selecionar o país (ou a entidadeAbroad caso não tenha país manual)
          String nomePais = i.pais ?? i.entidadeAbroad;
          _paisSelecionado = paises.firstWhere((p) => p.nome == nomePais);
        } catch (_) {}
      }

      setState(() {
        _paises = paises;
      });
    } catch (e) {
      SnackbarUtils.showError("Erro: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- LÓGICA DE VALIDAÇÃO E NAVEGAÇÃO ---

  bool _isCurrentStepValid() {
    bool isFormValid =
        _stepKeys[_currentStep].currentState?.validate() ?? false;

    if (_currentStep == 0 && _paisSelecionado == null) {
      SnackbarUtils.showError("Selecione o País de Origem.");
      return false;
    }

    return isFormValid;
  }

  void _onStepContinue() {
    if (_isCurrentStepValid()) {
      if (_currentStep < 3) {
        setState(() => _currentStep += 1);
      } else {
        _salvar();
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.pop(context);
    }
  }

  void _onStepTapped(int step) {
    if (step < _currentStep) {
      setState(() => _currentStep = step);
    }
  }

  Future<void> _salvar() async {
    if (_paisSelecionado == null) return;

    setState(() => _isLoading = true);

    try {
      final old = widget.intercambista;

      final novo = Intercambista(
        // Mantém os dados vitais do Podio intocados
        epId: old?.epId ?? '',
        opId: old?.opId ?? '',
        comite: old?.comite ?? widget.comiteLocalId,
        area: old?.area ?? 'Não informada',
        dataRePresencial: old?.dataRePresencial ?? '',
        dataFinPresencial: old?.dataFinPresencial ?? '',
        entidadeAbroad: old?.entidadeAbroad ?? _paisSelecionado!.nome,
        precisaHospedagem: old?.precisaHospedagem ?? true,

        // Atualiza os dados manuais
        nome: _nomeCtrl.text.trim(),
        status: _statusSelecionado,
        pais: _paisSelecionado!.nome,
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

      // Usando a nova função "Upsert" do Serviço
      await IntercambistaService.instance.salvarIntercambista(
        intercambista: novo,
      );

      if (mounted) Navigator.pop(context);
      SnackbarUtils.showInfo("Intercambista salvo com sucesso!");
    } catch (e) {
      SnackbarUtils.showError("Erro ao salvar: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.intercambista == null ? "Cadastrar EP" : "Editar EP",
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.intercambista == null
                          ? "Novo Registro"
                          : "Atualizar Registro",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Complemente as informações pessoais do intercambista.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                  ],
                ),
              ),

              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(
                      context,
                    ).colorScheme.copyWith(primary: AppColors.primary),
                  ),
                  child: Stepper(
                    type: StepperType.vertical,
                    currentStep: _currentStep,
                    onStepContinue: _onStepContinue,
                    onStepCancel: _onStepCancel,
                    onStepTapped: _onStepTapped,
                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 32.0),
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _currentStep == 3 ? "SALVAR TUDO" : "PRÓXIMO",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: details.onStepCancel,
                              child: Text(
                                _currentStep > 0 ? "VOLTAR" : "CANCELAR",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    steps: [
                      // --- STEP 1: DADOS BÁSICOS ---
                      Step(
                        title: const Text("Dados Pessoais e Origem"),
                        isActive: _currentStep >= 0,
                        state: _currentStep > 0
                            ? StepState.complete
                            : StepState.indexed,
                        content: Form(
                          key: _stepKeys[0],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              Editor(
                                controller: _nomeCtrl,
                                labelText: "Nome Completo *",
                                isPassword: false,
                                keyboardType: TextInputType.name,
                                validator: FormValidators.notEmpty,
                                enabled: true,
                              ),
                              const SizedBox(height: 24),
                              _buildResponsiveRow(isMobile, [
                                Editor(
                                  controller: _idadeCtrl,
                                  labelText: "Idade",
                                  isPassword: false,
                                  keyboardType: TextInputType.number,
                                  enabled: true,
                                ),
                                Editor(
                                  controller: _nacionalidadeCtrl,
                                  labelText: "Nacionalidade",
                                  isPassword: false,
                                  keyboardType: TextInputType.text,
                                  enabled: true,
                                ),
                              ]),
                              const SizedBox(height: 24),
                              Selector<Pais>(
                                labelText: "País de Residência *",
                                items: _paises,
                                value: _paisSelecionado,
                                itemLabelBuilder: (p) => p.nome,
                                onChanged: (p) =>
                                    setState(() => _paisSelecionado = p),
                                validator: FormValidators.selection,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- STEP 2: VOOS / HOSPEDAGEM ---
                      Step(
                        title: const Text("Período de Hospedagem (Voos)"),
                        isActive: _currentStep >= 1,
                        state: _currentStep > 1
                            ? StepState.complete
                            : StepState.indexed,
                        content: Form(
                          key: _stepKeys[1],
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              const Text(
                                "As datas de chegada e partida podem diferir das datas do projeto no Podio. Preencha conforme a passagem aérea do intercambista.",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildResponsiveRow(isMobile, [
                                Editor(
                                  controller: _dataChegadaCtrl,
                                  labelText: "Data de Chegada (Voo)",
                                  hintText: "DD/MM/AAAA",
                                  isPassword: false,
                                  keyboardType: TextInputType.datetime,
                                  prefixIcon: Icons.flight_land,
                                  inputFormatters: [DateTextFormatter()],
                                  enabled: true,
                                ),
                                Editor(
                                  controller: _dataPartidaCtrl,
                                  labelText: "Data de Partida (Voo)",
                                  hintText: "DD/MM/AAAA",
                                  isPassword: false,
                                  keyboardType: TextInputType.datetime,
                                  prefixIcon: Icons.flight_takeoff,
                                  inputFormatters: [DateTextFormatter()],
                                  enabled: true,
                                ),
                              ]),
                              const SizedBox(height: 24),
                              Selector<String>(
                                labelText: "Status Atual *",
                                items: const [
                                  'Approved',
                                  'Realized',
                                  'Finished',
                                  'Completed',
                                ], // Status do Podio
                                value: _statusSelecionado,
                                onChanged: (v) =>
                                    setState(() => _statusSelecionado = v!),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- STEP 3: PERFIL ---
                      Step(
                        title: const Text("Perfil e Habilidades"),
                        isActive: _currentStep >= 2,
                        state: _currentStep > 2
                            ? StepState.complete
                            : StepState.indexed,
                        content: Form(
                          key: _stepKeys[2],
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              Editor(
                                controller: _formacaoCtrl,
                                labelText: "Formação Acadêmica",
                                isPassword: false,
                                keyboardType: TextInputType.text,
                                enabled: true,
                              ),
                              const SizedBox(height: 24),
                              ChipInputField(
                                label: "Idiomas",
                                hint: "Digite e pressione enter",
                                items: _listaIdiomas,
                                onChanged: (list) =>
                                    setState(() => _listaIdiomas = list),
                              ),
                              const SizedBox(height: 24),
                              ChipInputField(
                                label: "Interesses",
                                hint: "Digite e pressione enter",
                                items: _listaInteresses,
                                onChanged: (list) =>
                                    setState(() => _listaInteresses = list),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- STEP 4: DETALHES ---
                      Step(
                        title: const Text("Detalhes e Saúde"),
                        isActive: _currentStep >= 3,
                        state: StepState.indexed,
                        content: Form(
                          key: _stepKeys[3],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              Editor(
                                controller: _sobreMimCtrl,
                                labelText: "Um pouco sobre o intercambista",
                                isPassword: false,
                                keyboardType: TextInputType.multiline,
                                enabled: true,
                              ),
                              const SizedBox(height: 24),
                              _buildResponsiveRow(isMobile, [
                                Editor(
                                  controller: _hobbiesCtrl,
                                  labelText: "Hobbies",
                                  isPassword: false,
                                  keyboardType: TextInputType.multiline,
                                  enabled: true,
                                ),
                                Editor(
                                  controller: _motivacaoCtrl,
                                  labelText: "Motivação",
                                  isPassword: false,
                                  keyboardType: TextInputType.multiline,
                                  enabled: true,
                                ),
                              ]),
                              const SizedBox(height: 32),
                              const Text(
                                "Preferências e Saúde",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              CheckboxListTile(
                                title: const Text("Fumante"),
                                value: _isFumante,
                                onChanged: (v) =>
                                    setState(() => _isFumante = v!),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                              const SizedBox(height: 16),
                              _buildResponsiveRow(isMobile, [
                                Editor(
                                  controller: _alergiasCtrl,
                                  labelText: "Alergias",
                                  isPassword: false,
                                  keyboardType: TextInputType.text,
                                  enabled: true,
                                ),
                                Editor(
                                  controller: _restricoesCtrl,
                                  labelText: "Restrições Alimentares/Outras",
                                  isPassword: false,
                                  keyboardType: TextInputType.text,
                                  enabled: true,
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResponsiveRow(bool isMobile, List<Widget> children) {
    if (isMobile) {
      return Column(
        children: children
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 24), child: c),
            )
            .toList(),
      );
    } else {
      return Row(
        children: children.asMap().entries.map((entry) {
          final idx = entry.key;
          final widget = entry.value;
          return Expanded(
            child: Row(
              children: [
                Expanded(child: widget),
                if (idx < children.length - 1) const SizedBox(width: 24),
              ],
            ),
          );
        }).toList(),
      );
    }
  }
}
