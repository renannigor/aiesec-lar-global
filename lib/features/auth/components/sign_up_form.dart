import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/form_validators.dart';
import '../../../data/services/viacep_service.dart';

class SignUpForm extends StatefulWidget {
  final VoidCallback onSwitchToSignIn;

  const SignUpForm({super.key, required this.onSwitchToSignIn});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para todos os campos do formulário
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _addressFieldsEnabled =
      false; // Controla se os campos de endereço estão habilitados

  // Máscara para o campo de CEP
  final _cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
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

  /// Busca o endereço na API do ViaCEP e preenche os campos.
  Future<void> _buscarEnderecoPorCep(String cep) async {
    // Só busca se o CEP estiver completo
    if (cep.replaceAll(RegExp(r'[^0-9]'), '').length != 8) return;

    final endereco = await ViaCepService.buscarCep(cep);

    if (mounted) {
      if (endereco != null) {
        _logradouroController.text = endereco['logradouro'] ?? '';
        _bairroController.text = endereco['bairro'] ?? '';
        _cidadeController.text = endereco['localidade'] ?? '';
        _ufController.text = endereco['uf'] ?? '';
        setState(() => _addressFieldsEnabled = true); // Habilita os campos
        // Foca no campo "Número" após preencher o endereço
        FocusScope.of(context).nextFocus();
      } else {
        SnackbarUtils.showError('CEP não encontrado ou inválido.');
        _clearAddressFields();
      }
    }
  }

  /// Limpa os campos de endereço caso o CEP seja inválido ou apagado.
  void _clearAddressFields() {
    _logradouroController.clear();
    _bairroController.clear();
    _cidadeController.clear();
    _ufController.clear();
    setState(() => _addressFieldsEnabled = false); // Desabilita os campos
  }

  /// Valida o formulário e chama a lógica de cadastro.
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthProvider>().signUp(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
        cep: _cepController.text.trim(),
        logradouro: _logradouroController.text.trim(),
        numero: _numeroController.text.trim(),
        bairro: _bairroController.text.trim(),
        cidade: _cidadeController.text.trim(),
        estado: _ufController.text.trim(),
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
              controller: _cepController,
              labelText: 'CEP',
              keyboardType: TextInputType.number,
              isPassword: false,
              inputFormatters: [_cepMaskFormatter],
              validator: (value) =>
                  FormValidators.notEmpty(value, fieldName: 'CEP'),
              onChanged: (value) {
                // Quando o CEP está completo (ex: 88000-000), a busca é disparada
                if (value.length == 9) {
                  _buscarEnderecoPorCep(value);
                } else {
                  // Limpa os campos se o CEP for apagado
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
