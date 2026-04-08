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

class ComiteFormContent extends StatefulWidget {
  final ComiteLocal? comite;
  final VoidCallback onClose;

  const ComiteFormContent({super.key, this.comite, required this.onClose});

  @override
  State<ComiteFormContent> createState() => _ComiteFormContentState();
}

class _ComiteFormContentState extends State<ComiteFormContent> {
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

      if (mounted) widget.onClose();
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
    if (_isLoadingIbge && _estados.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo Nome
          Editor(
            controller: _nomeController,
            labelText: 'Nome do Comitê',
            isPassword: false,
            keyboardType: TextInputType.text,
            enabled: true,
            validator: FormValidators.notEmpty,
          ),

          const SizedBox(height: 16),

          // Linha de Estado e Cidade
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SELETOR DE ESTADO ---
              Expanded(
                flex: 1,
                child: Selector<Estado>(
                  labelText: 'UF',
                  value: _selectedEstado,
                  items: _estados,
                  itemLabelBuilder: (estado) => estado.sigla,
                  onChanged: _onEstadoChanged,
                  validator: FormValidators.selection,
                ),
              ),

              const SizedBox(width: 16),

              // --- SELETOR DE CIDADE ---
              Expanded(
                flex: 2,
                child: Selector<Cidade>(
                  labelText: 'Cidade',
                  value: _selectedCidade,
                  items: _cidades,
                  itemLabelBuilder: (cidade) => cidade.nome,
                  onChanged: _cidades.isEmpty
                      ? null
                      : (v) => setState(() => _selectedCidade = v),
                  validator: FormValidators.selection,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Botões de Ação
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onClose,
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isLoadingSaving ? null : _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoadingSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Salvar",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
