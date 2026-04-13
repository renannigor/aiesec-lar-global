import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:aiesec_lar_global/data/models/endereco.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';
import 'package:aiesec_lar_global/data/services/viacep_service.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';

class FormEndereco extends StatefulWidget {
  final Endereco? enderecoAtual;
  final Function(Endereco novoEndereco) onChanged;

  const FormEndereco({
    super.key,
    required this.enderecoAtual,
    required this.onChanged,
  });

  @override
  State<FormEndereco> createState() => _FormEnderecoState();
}

class _FormEnderecoState extends State<FormEndereco> {
  late TextEditingController cepController;
  late TextEditingController logradouroController;
  late TextEditingController numeroController;
  late TextEditingController complementoController;
  late TextEditingController bairroController;
  late TextEditingController cidadeController;
  late TextEditingController estadoController;

  final _cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    final end = widget.enderecoAtual;
    cepController = TextEditingController(text: end?.cep ?? "");
    logradouroController = TextEditingController(text: end?.logradouro ?? "");
    numeroController = TextEditingController(text: end?.numero ?? "");
    complementoController = TextEditingController(text: end?.complemento ?? "");
    bairroController = TextEditingController(text: end?.bairro ?? "");
    cidadeController = TextEditingController(text: end?.cidade ?? "");
    estadoController = TextEditingController(text: end?.estado ?? "");
  }

  void _atualizar() {
    widget.onChanged(
      Endereco(
        cep: cepController.text,
        logradouro: logradouroController.text,
        numero: numeroController.text,
        complemento: complementoController.text,
        bairro: bairroController.text,
        cidade: cidadeController.text,
        estado: estadoController.text,
      ),
    );
  }

  Future<void> _buscarEnderecoPorCep(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepLimpo.length != 8) return;

    final enderecoMap = await ViaCepService.buscarCep(cepLimpo);

    if (mounted) {
      if (enderecoMap != null) {
        setState(() {
          logradouroController.text = enderecoMap['logradouro'] ?? '';
          bairroController.text = enderecoMap['bairro'] ?? '';
          cidadeController.text = enderecoMap['localidade'] ?? '';
          estadoController.text = enderecoMap['uf'] ?? '';
        });
        _atualizar();
        FocusScope.of(context).nextFocus();
      } else {
        SnackbarUtils.showError('CEP não encontrado ou inválido.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ESPAÇO EXTRA NO TOPO
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: Editor(
                controller: cepController,
                labelText: "CEP",
                hintText: "00000-000",
                enabled: true,
                isPassword: false,
                keyboardType: TextInputType.number,
                inputFormatters: [_cepMaskFormatter],
                onChanged: (value) {
                  if (_cepMaskFormatter.getUnmaskedText().length == 8) {
                    _buscarEnderecoPorCep(value);
                  }
                  _atualizar();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Editor(
                controller: numeroController,
                labelText: "Número",
                hintText: "Nº 123",
                enabled: true,
                isPassword: false,
                keyboardType: TextInputType.text,
                onChanged: (_) => _atualizar(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Editor(
          controller: logradouroController,
          labelText: "Endereço",
          hintText: "Rua, Avenida, Alameda...",
          enabled: true,
          isPassword: false,
          keyboardType: TextInputType.streetAddress,
          prefixIcon: Icons.location_on_outlined,
          onChanged: (_) => _atualizar(),
        ),

        const SizedBox(height: 24),

        Editor(
          controller: complementoController,
          labelText: "Complemento (Opcional)",
          hintText: "Ex: Apto 101, Bloco C",
          enabled: true,
          isPassword: false,
          keyboardType: TextInputType.text,
          onChanged: (_) => _atualizar(),
        ),

        const SizedBox(height: 24),

        Editor(
          controller: bairroController,
          labelText: "Bairro",
          hintText: "Nome do bairro",
          enabled: true,
          isPassword: false,
          keyboardType: TextInputType.text,
          onChanged: (_) => _atualizar(),
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: Editor(
                controller: cidadeController,
                labelText: "Cidade",
                hintText: "Sua cidade",
                enabled: true,
                isPassword: false,
                keyboardType: TextInputType.text,
                onChanged: (_) => _atualizar(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Editor(
                controller: estadoController,
                labelText: "UF",
                hintText: "SP",
                enabled: true,
                isPassword: false,
                keyboardType: TextInputType.text,
                onChanged: (_) => _atualizar(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
