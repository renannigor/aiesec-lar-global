import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';
import 'package:provider/provider.dart' hide Selector;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/form_validators.dart';
import '../../../data/services/viacep_service.dart';

// --- NOVOS IMPORTS ---
import 'package:aiesec_lar_global/core/widgets/selector.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/services/comite_local_service.dart';

class SignUpForm extends StatefulWidget {
  final VoidCallback onSwitchToSignIn;

  const SignUpForm({super.key, required this.onSwitchToSignIn});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _addressFieldsEnabled = false;

  // --- VARIÁVEIS PARA O COMITÊ ---
  String? _comiteSelecionado; // Vai guardar o nome ou ID do comitê
  List<ComiteLocal> _listaComites = [];
  bool _carregandoComites = true;

  final _cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    _buscarComitesLocais();
  }

  // --- FUNÇÃO PARA BUSCAR OS COMITÊS ---
  Future<void> _buscarComitesLocais() async {
    try {
      // Como o seu getComitesStream retorna um Stream, vamos pegar apenas o primeiro evento
      // para preencher a lista de opções do dropdown.
      final comites = await ComiteLocalService.instance
          .getComitesStream()
          .first;
      if (mounted) {
        setState(() {
          // Filtra apenas os ativos (opcional) e ordena alfabeticamente
          _listaComites = comites.where((c) => c.status == 'Ativo').toList()
            ..sort((a, b) => a.nome.compareTo(b.nome));
          _carregandoComites = false;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar comitês: $e");
      if (mounted) {
        setState(() => _carregandoComites = false);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _buscarEnderecoPorCep(String cep) async {
    if (cep.replaceAll(RegExp(r'[^0-9]'), '').length != 8) return;

    final endereco = await ViaCepService.buscarCep(cep);

    if (mounted) {
      if (endereco != null) {
        _logradouroController.text = endereco['logradouro'] ?? '';
        _bairroController.text = endereco['bairro'] ?? '';
        _cidadeController.text = endereco['localidade'] ?? '';
        _ufController.text = endereco['uf'] ?? '';
        setState(() => _addressFieldsEnabled = true);
        FocusScope.of(context).nextFocus();
      } else {
        SnackbarUtils.showError('CEP não encontrado ou inválido.');
        _clearAddressFields();
      }
    }
  }

  void _clearAddressFields() {
    _logradouroController.clear();
    _bairroController.clear();
    _cidadeController.clear();
    _ufController.clear();
    setState(() => _addressFieldsEnabled = false);
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Validação extra para o Comitê (já que ele não é um Editor com validator padrão)
      if (_comiteSelecionado == null) {
        SnackbarUtils.showError("Por favor, selecione a AIESEC mais próxima.");
        return;
      }

      context.read<AuthProvider>().signUp(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.trim(),
        password: _senhaController.text.trim(),
        cep: _cepController.text.trim(),
        logradouro: _logradouroController.text.trim(),
        numero: _numeroController.text.trim(),
        bairro: _bairroController.text.trim(),
        cidade: _cidadeController.text.trim(),
        estado: _ufController.text.trim(),
        comiteLocal: _comiteSelecionado!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Crie sua conta',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: widget.onSwitchToSignIn,
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(text: 'Já tem uma conta? '),
                    TextSpan(
                      text: 'Faça login',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Editor(
              controller: _nomeController,
              labelText: 'Nome',
              isPassword: false,
              keyboardType: TextInputType.name,
              enabled: true,
              validator: (value) =>
                  FormValidators.notEmpty(value, fieldName: 'nome'),
            ),
            const SizedBox(height: 16),
            Editor(
              controller: _emailController,
              labelText: 'Email',
              isPassword: false,
              keyboardType: TextInputType.emailAddress,
              enabled: true,
              validator: FormValidators.email,
            ),
            const SizedBox(height: 16),
            Editor(
              controller: _telefoneController,
              labelText: 'Telefone',
              isPassword: false,
              keyboardType: TextInputType.phone,
              inputFormatters: [_phoneMaskFormatter],
              enabled: true,
              validator: (value) =>
                  FormValidators.notEmpty(value, fieldName: 'telefone'),
            ),

            // --- NOVO CAMPO: SELETOR DE COMITÊ ---
            const SizedBox(height: 16),
            _carregandoComites
                ? const Center(child: CircularProgressIndicator())
                : Selector<String>(
                    labelText: 'AIESEC mais próxima',
                    value: _comiteSelecionado,
                    items: _listaComites.map((c) => c.nome).toList(),
                    onChanged: (val) {
                      setState(() {
                        _comiteSelecionado = val;
                      });
                    },
                  ),

            const SizedBox(height: 16),
            Editor(
              controller: _cepController,
              labelText: 'CEP',
              keyboardType: TextInputType.number,
              isPassword: false,
              inputFormatters: [_cepMaskFormatter],
              validator: (value) =>
                  FormValidators.notEmpty(value, fieldName: 'CEP'),
              onChanged: (value) {
                if (value.length == 9) {
                  _buscarEnderecoPorCep(value);
                } else {
                  if (_addressFieldsEnabled) _clearAddressFields();
                }
              },
              enabled: true,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Editor(
                    controller: _logradouroController,
                    labelText: 'Logradouro',
                    enabled: _addressFieldsEnabled,
                    isPassword: false,
                    keyboardType: TextInputType.text,
                    validator: (value) =>
                        FormValidators.notEmpty(value, fieldName: 'logradouro'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Editor(
                    controller: _numeroController,
                    labelText: 'Nº',
                    enabled: _addressFieldsEnabled,
                    keyboardType: TextInputType.number,
                    isPassword: false,
                    validator: (value) =>
                        FormValidators.notEmpty(value, fieldName: 'número'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Editor(
                    controller: _bairroController,
                    labelText: 'Bairro',
                    enabled: _addressFieldsEnabled,
                    isPassword: false,
                    keyboardType: TextInputType.text,
                    validator: (value) =>
                        FormValidators.notEmpty(value, fieldName: 'bairro'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Editor(
                    controller: _cidadeController,
                    labelText: 'Cidade',
                    enabled: _addressFieldsEnabled,
                    isPassword: false,
                    keyboardType: TextInputType.text,
                    validator: (value) =>
                        FormValidators.notEmpty(value, fieldName: 'cidade'),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 80,
                  child: Editor(
                    controller: _ufController,
                    labelText: 'UF',
                    enabled: _addressFieldsEnabled,
                    isPassword: false,
                    keyboardType: TextInputType.text,
                    validator: (value) =>
                        FormValidators.notEmpty(value, fieldName: 'UF'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Editor(
              controller: _senhaController,
              labelText: 'Senha',
              isPassword: true,
              keyboardType: TextInputType.text,
              validator: FormValidators.password,
              enabled: true,
            ),
            const SizedBox(height: 16),
            Editor(
              controller: _confirmarSenhaController,
              labelText: 'Confirmar Senha',
              isPassword: true,
              keyboardType: TextInputType.text,
              validator: (value) =>
                  FormValidators.confirmPassword(value, _senhaController.text),
              enabled: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Cadastrar',
                style: TextStyle(color: AppColors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
