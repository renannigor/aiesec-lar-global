import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/utils/form_validators.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';
import 'package:aiesec_lar_global/core/widgets/selector.dart';
import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/models/ibge_model.dart';
import 'package:aiesec_lar_global/data/services/comite_local_service.dart';
import 'package:aiesec_lar_global/data/services/ibge_service.dart';

class ComiteFormSheet extends StatefulWidget {
  final ComiteLocal? comite;

  const ComiteFormSheet({super.key, this.comite});

  @override
  State<ComiteFormSheet> createState() => _ComiteFormSheetState();
}

class _ComiteFormSheetState extends State<ComiteFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();

  // Variáveis para o IBGE
  List<Estado> _estados = [];
  List<Cidade> _cidades = [];
  Estado? _selectedEstado;
  Cidade? _selectedCidade;
  bool _isLoadingIbge = true;
  bool _isLoadingSaving = false;

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.comite?.nome ?? '';
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    try {
      final estados = await IbgeService.getEstados();
      Estado? estadoEncontrado;
      Cidade? cidadeEncontrada;
      List<Cidade> cidadesDoEstado = [];

      if (widget.comite != null) {
        try {
          estadoEncontrado = estados.firstWhere(
            (e) => e.sigla == widget.comite!.estado,
          );

          cidadesDoEstado = await IbgeService.getCidadesPorEstado(
            estadoEncontrado.id,
          );
          cidadeEncontrada = cidadesDoEstado.firstWhere(
            (c) => c.nome == widget.comite!.cidade,
          );
        } catch (e) {
          debugPrint("Erro ao mapear dados do IBGE na edição: $e");
        }
      }

      if (mounted) {
        setState(() {
          _estados = estados;
          _selectedEstado = estadoEncontrado;
          _cidades = cidadesDoEstado;
          _selectedCidade = cidadeEncontrada;
          _isLoadingIbge = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingIbge = false);
        SnackbarUtils.showError("Erro ao carregar IBGE: $e");
      }
    }
  }

  Future<void> _onEstadoChanged(Estado? novoEstado) async {
    if (novoEstado == null) return;

    setState(() {
      _selectedEstado = novoEstado;
      _selectedCidade = null;
      _cidades = [];
      _isLoadingIbge = true;
    });

    try {
      final cidades = await IbgeService.getCidadesPorEstado(novoEstado.id);
      if (mounted) {
        setState(() {
          _cidades = cidades;
          _isLoadingIbge = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingIbge = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEstado == null || _selectedCidade == null) {
      SnackbarUtils.showError('Selecione Estado e Cidade');
      return;
    }

    setState(() => _isLoadingSaving = true);

    try {
      final comiteModel = ComiteLocal(
        comiteId: widget.comite?.comiteId,
        nome: _nomeController.text.trim(),
        cidade: _selectedCidade!.nome,
        estado: _selectedEstado!.sigla,
        status: widget.comite?.status ?? 'Ativo',
        nomePodio: _nomeController.text.trim().split(' ').last.toUpperCase(),
        testemunhas: widget.comite?.testemunhas ?? [],
        cnpj: widget.comite?.cnpj,
        dadosPresidente: widget.comite?.dadosPresidente,
        endereco: widget.comite?.endereco,
      );

      if (widget.comite != null) {
        await ComiteLocalService.instance.atualizarComiteLocal(
          comite: comiteModel,
        );
      } else {
        await ComiteLocalService.instance.adicionarComiteLocal(
          comite: comiteModel,
        );
      }

      if (mounted) {
        Navigator.pop(context); // Fecha o modal
        SnackbarUtils.showSuccess('Comitê salvo com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError('Erro: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoadingSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Olha como o build fica infinitamente mais limpo!
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Cabeçalho Extraído
          _ComiteFormHeader(isEditing: widget.comite != null),

          // 2. Corpo Extraído
          Expanded(
            child: _isLoadingIbge && _estados.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _ComiteFormFields(
                    formKey: _formKey,
                    nomeController: _nomeController,
                    estados: _estados,
                    cidades: _cidades,
                    selectedEstado: _selectedEstado,
                    selectedCidade: _selectedCidade,
                    onEstadoChanged: _onEstadoChanged,
                    onCidadeChanged: (v) => setState(() => _selectedCidade = v),
                  ),
          ),

          // 3. Rodapé Extraído
          _ComiteFormFooter(isLoadingSaving: _isLoadingSaving, onSave: _salvar),
        ],
      ),
    );
  }
}

class _ComiteFormHeader extends StatelessWidget {
  final bool isEditing;

  const _ComiteFormHeader({required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isEditing ? "Editar Comitê" : "Cadastrar Comitê",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}

class _ComiteFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nomeController;
  final List<Estado> estados;
  final List<Cidade> cidades;
  final Estado? selectedEstado;
  final Cidade? selectedCidade;
  final Function(Estado?) onEstadoChanged;
  final Function(Cidade?) onCidadeChanged;

  const _ComiteFormFields({
    required this.formKey,
    required this.nomeController,
    required this.estados,
    required this.cidades,
    required this.selectedEstado,
    required this.selectedCidade,
    required this.onEstadoChanged,
    required this.onCidadeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 100,
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Editor(
              controller: nomeController,
              labelText: 'Nome do Comitê (Ex: AIESEC em Vitória)',
              isPassword: false,
              keyboardType: TextInputType.text,
              enabled: true,
              validator: FormValidators.notEmpty,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Selector<Estado>(
                    labelText: 'UF',
                    value: selectedEstado,
                    items: estados,
                    itemLabelBuilder: (estado) => estado.sigla,
                    onChanged: onEstadoChanged,
                    validator: FormValidators.selection,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Selector<Cidade>(
                    labelText: 'Cidade',
                    value: selectedCidade,
                    items: cidades,
                    itemLabelBuilder: (cidade) => cidade.nome,
                    onChanged: cidades.isEmpty ? null : onCidadeChanged,
                    validator: FormValidators.selection,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComiteFormFooter extends StatelessWidget {
  final bool isLoadingSaving;
  final VoidCallback onSave;

  const _ComiteFormFooter({
    required this.isLoadingSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          onPressed: isLoadingSaving ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoadingSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Salvar Comitê",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
