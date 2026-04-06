import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/data/models/comite_local/testemunha.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class TestemunhaFormSheet extends StatefulWidget {
  final Testemunha?
  testemunha; // Se vier nulo, é criação. Se vier preenchido, é edição.

  const TestemunhaFormSheet({super.key, this.testemunha});

  @override
  State<TestemunhaFormSheet> createState() => _TestemunhaFormSheetState();
}

class _TestemunhaFormSheetState extends State<TestemunhaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _rgCtrl = TextEditingController();
  final _orgaoCtrl = TextEditingController();

  final _cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    // Se for edição, preenche os campos
    if (widget.testemunha != null) {
      _nomeCtrl.text = widget.testemunha!.nomeCompleto;
      _cpfCtrl.text = widget.testemunha!.cpf;
      _rgCtrl.text = widget.testemunha!.rg;
      _orgaoCtrl.text = widget.testemunha!.orgaoEmissor;
    }
  }

  void _salvarTestemunha() {
    if (_formKey.currentState?.validate() ?? false) {
      final novaTestemunha = Testemunha(
        nomeCompleto: _nomeCtrl.text.trim(),
        cpf: _cpfCtrl.text.trim(),
        rg: _rgCtrl.text.trim(),
        orgaoEmissor: _orgaoCtrl.text
            .trim()
            .toUpperCase(), // Padrão colocar órgão emissor em maiúsculo (Ex: SSP)
      );

      // Fecha o BottomSheet e devolve o objeto criado para a tela de trás
      Navigator.pop(context, novaTestemunha);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Text(
                  widget.testemunha == null
                      ? "Nova Testemunha"
                      : "Editar Testemunha",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 24,
                ),
              ],
            ),
          ),

          // CORPO DO FORMULÁRIO ROLÁVEL
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                    100, // Espaço para o teclado e botão de salvar
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Editor(
                      controller: _nomeCtrl,
                      labelText: "Nome Completo",
                      isPassword: false,
                      enabled: true,
                      keyboardType: TextInputType.name,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),

                    if (isMobile) ...[
                      Editor(
                        controller: _cpfCtrl,
                        labelText: "CPF",
                        isPassword: false,
                        enabled: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_cpfMaskFormatter],
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      Editor(
                        controller: _rgCtrl,
                        labelText: "RG",
                        isPassword: false,
                        enabled: true,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      Editor(
                        controller: _orgaoCtrl,
                        labelText: "Órgão Emissor (Ex: SSP)",
                        isPassword: false,
                        enabled: true,
                        keyboardType: TextInputType.text,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Obrigatório' : null,
                      ),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Editor(
                              controller: _cpfCtrl,
                              labelText: "CPF",
                              isPassword: false,
                              enabled: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_cpfMaskFormatter],
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Campo obrigatório'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Editor(
                              controller: _rgCtrl,
                              labelText: "RG",
                              isPassword: false,
                              enabled: true,
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Campo obrigatório'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Editor(
                              controller: _orgaoCtrl,
                              labelText: "Órgão Emissor",
                              isPassword: false,
                              enabled: true,
                              keyboardType: TextInputType.text,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Obrigatório' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // RODAPÉ COM O BOTÃO DE SALVAR A TESTEMUNHA
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
                onPressed: _salvarTestemunha,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Confirmar Testemunha",
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
}
