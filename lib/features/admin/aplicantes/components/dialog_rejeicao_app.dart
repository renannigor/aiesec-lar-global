import 'package:flutter/material.dart';

// Imports Core
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';

// Imports Data
import 'package:aiesec_lar_global/data/models/mensagem_rejeicao.dart';
import 'package:aiesec_lar_global/data/services/mensagem_rejeicao_service.dart';

class DialogRejeicaoApp extends StatefulWidget {
  const DialogRejeicaoApp({super.key});

  @override
  State<DialogRejeicaoApp> createState() => _DialogRejeicaoAppState();
}

class _DialogRejeicaoAppState extends State<DialogRejeicaoApp> {
  String? _opcaoSelecionadaId;
  String? _descricaoSelecionada;
  final TextEditingController _motivoPersonalizadoCtrl =
      TextEditingController();

  void _confirmar() {
    if (_opcaoSelecionadaId == null) {
      SnackbarUtils.showError("Selecione um motivo.");
      return;
    }

    if (_opcaoSelecionadaId == 'outro') {
      if (_motivoPersonalizadoCtrl.text.trim().isEmpty) {
        SnackbarUtils.showError("Digite o motivo da rejeição.");
        return;
      }
      Navigator.pop(context, _motivoPersonalizadoCtrl.text.trim());
    } else {
      Navigator.pop(context, _descricaoSelecionada);
    }
  }

  @override
  void dispose() {
    _motivoPersonalizadoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Motivo da Rejeição"),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selecione um motivo abaixo. O Host receberá esse feedback em sua tela de acompanhamento.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Busca as mensagens padronizadas do Banco de Dados
            FutureBuilder<List<MensagemRejeicao>>(
              future: MensagemRejeicaoService.instance.getMensagens(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    "Erro ao carregar opções: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  );
                }

                final mensagens = snapshot.data ?? [];

                return RadioGroup<String>(
                  groupValue: _opcaoSelecionadaId,
                  onChanged: (val) {
                    setState(() {
                      _opcaoSelecionadaId = val;
                      if (val == 'outro') {
                        _descricaoSelecionada = null;
                      } else {
                        // Quando selecionado, busca a descrição correspondente na lista
                        try {
                          _descricaoSelecionada = mensagens
                              .firstWhere((m) => m.id == val)
                              .descricao;
                        } catch (e) {
                          _descricaoSelecionada = null;
                        }
                      }
                    });
                  },
                  child: Column(
                    children: [
                      ...mensagens.map((msg) {
                        return RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            msg.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            msg.descricao,
                            style: const TextStyle(fontSize: 12),
                          ),
                          value: msg.id,
                          activeColor: Colors.red,
                        );
                      }),

                      // OPÇÃO "OUTRO"
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          "Outro Motivo Específico",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        value: 'outro',
                        activeColor: Colors.red,
                      ),

                      // CAMPO DE TEXTO ABERTO
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _opcaoSelecionadaId == 'outro'
                            ? Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Editor(
                                  controller: _motivoPersonalizadoCtrl,
                                  labelText:
                                      "Descreva o motivo detalhadamente...",
                                  isPassword: false,
                                  keyboardType: TextInputType.multiline,
                                  enabled: true,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _confirmar,
          child: const Text(
            "Rejeitar Candidatura",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
