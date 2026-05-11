import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // NOVO IMPORT

// --- IMPORTS CORE ---
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/core/utils/form_validators.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';
import 'package:aiesec_lar_global/core/widgets/selector.dart';
import 'package:aiesec_lar_global/core/constants/nps_constantes.dart';

// --- IMPORTS DATA ---
import 'package:aiesec_lar_global/data/models/aplicacao.dart';
import 'package:aiesec_lar_global/data/models/nps_host.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/services/nps_service.dart';
import 'package:aiesec_lar_global/data/services/usuario_service.dart';
import 'package:aiesec_lar_global/data/services/podio_service.dart'; // NOVO IMPORT

class NpsFormSheet extends StatefulWidget {
  final Aplicacao aplicacao;

  const NpsFormSheet({super.key, required this.aplicacao});

  @override
  State<NpsFormSheet> createState() => _NpsFormSheetState();
}

class _NpsFormSheetState extends State<NpsFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  Usuario? _hostAtual;

  // --- SELETOR DE IMAGENS ---
  final ImagePicker _picker = ImagePicker();
  XFile? _fotoSelecionada;

  // --- VARIÁVEIS DE ESTADO DO FORMULÁRIO ---
  String? _primeiraVez;
  String? _termoFirmado;
  String? _acompanhamento;
  String? _comunicacao;
  String? _objetivos;

  final TextEditingController _aprendeuCtrl = TextEditingController();
  final TextEditingController _melhorarCtrl = TextEditingController();

  int? _notaNps;
  String? _novamente;
  final TextEditingController _motivoCtrl = TextEditingController();
  final TextEditingController _indicacaoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  @override
  void dispose() {
    _aprendeuCtrl.dispose();
    _melhorarCtrl.dispose();
    _motivoCtrl.dispose();
    _indicacaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosIniciais() async {
    try {
      _hostAtual = await UsuarioService.instance.getUsuario(
        uid: widget.aplicacao.hostUid,
      );
    } catch (e) {
      debugPrint("Erro ao carregar Host para o NPS: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selecionarFoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _fotoSelecionada = image;
        });
      }
    } catch (e) {
      SnackbarUtils.showError("Erro ao acessar galeria: $e");
    }
  }

  Future<void> _enviarAvaliacao() async {
    if (_notaNps == null) {
      SnackbarUtils.showError("Por favor, selecione uma nota de 1 a 10.");
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      SnackbarUtils.showError(
        "Por favor, preencha todos os campos obrigatórios (*).",
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      int? arquivoId;

      if (_fotoSelecionada != null) {
        SnackbarUtils.showInfo("Fazendo upload da foto para o CRM...");

        // --- TRECHO MODIFICADO ---
        final bytesDaFoto = await _fotoSelecionada!.readAsBytes();

        arquivoId = await PodioService().uploadArquivoNps(
          bytes: bytesDaFoto,
          fileName: _fotoSelecionada!.name,
        );
        // -------------------------

        if (arquivoId == null) {
          SnackbarUtils.showError(
            "Aviso: Falha ao enviar foto para o CRM. A avaliação será salva sem a imagem.",
          );
        }
      }

      final String novoId = FirebaseFirestore.instance
          .collection('avaliacoesNps')
          .doc()
          .id;

      final nps = NpsHost(
        id: novoId,
        hostUid: widget.aplicacao.hostUid,
        criadoEm: DateTime.now(),
        nomeHost: _hostAtual?.nome ?? "Host Desconhecido",
        comiteLocal: widget.aplicacao.comiteLocal,
        nomeIntercambista: widget.aplicacao.epNome,
        primeiraVezHost: _primeiraVez!,
        termoFirmado: _termoFirmado!,
        avaliacaoAcompanhamento: _acompanhamento!,
        comunicacaoClara: _comunicacao!,
        objetivosAlcancados: _objetivos!,
        oQueAprendeu: _aprendeuCtrl.text.trim(),
        oQueMelhorar: _melhorarCtrl.text.trim(),
        notaNps: _notaNps!,
        serHostNovamente: _novamente!,
        motivoNaoTalvez: _motivoCtrl.text.trim().isEmpty
            ? null
            : _motivoCtrl.text.trim(),
        indicacaoAmigo: _indicacaoCtrl.text.trim().isEmpty
            ? null
            : _indicacaoCtrl.text.trim(),
        fotoPodioId:
            arquivoId, // Adicionamos o ID que o Podio gerou para atrelar ao Card
      );

      await NpsService.instance.enviarNps(avaliacao: nps);

      if (mounted) {
        Navigator.pop(context);
        SnackbarUtils.showSuccess(
          "Avaliação enviada com sucesso! Muito obrigado.",
        );
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError("Erro ao enviar avaliação: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- CABEÇALHO ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Avaliar Experiência (Lar Global)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
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

          // --- CORPO ROLÁVEL COM FORM ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Sua avaliação sobre hospedar ${widget.aplicacao.epNome} nos ajuda a melhorar a experiência para futuros voluntários e hosts.\n\nAtenção: O envio desta avaliação é definitivo e não poderá ser alterado posteriormente.",
                                    style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // --- SESSÃO 1: IDENTIFICAÇÃO ---
                          _buildSectionTitle("1. Identificação"),
                          Selector(
                            labelText:
                                "Foi sua primeira vez sendo Host com a AIESEC? *",
                            value: _primeiraVez,
                            items: NpsConstantes.simNao,
                            validator: (val) => FormValidators.selection(
                              val,
                              fieldName: 'opção',
                            ),
                            onChanged: (val) =>
                                setState(() => _primeiraVez = val),
                          ),
                          const SizedBox(height: 32),

                          // --- SESSÃO 2: SUPORTE ---
                          _buildSectionTitle("2. Suporte da AIESEC"),
                          Selector(
                            labelText:
                                "A AIESEC firmou o Termo de Compromisso de Hospedagem com você? *",
                            value: _termoFirmado,
                            items: NpsConstantes.simNao,
                            validator: (val) => FormValidators.selection(
                              val,
                              fieldName: 'opção',
                            ),
                            onChanged: (val) =>
                                setState(() => _termoFirmado = val),
                          ),
                          const SizedBox(height: 24),
                          Selector(
                            labelText:
                                "Como avalia o acompanhamento da AIESEC durante a hospedagem? *",
                            value: _acompanhamento,
                            items: NpsConstantes.acompanhamento,
                            validator: (val) => FormValidators.selection(
                              val,
                              fieldName: 'opção',
                            ),
                            onChanged: (val) =>
                                setState(() => _acompanhamento = val),
                          ),
                          const SizedBox(height: 24),
                          Selector(
                            labelText:
                                "Houve comunicação clara sobre as regras da sua casa com o intercambista? *",
                            value: _comunicacao,
                            items: NpsConstantes.simNaoParcialmente,
                            validator: (val) => FormValidators.selection(
                              val,
                              fieldName: 'opção',
                            ),
                            onChanged: (val) =>
                                setState(() => _comunicacao = val),
                          ),
                          const SizedBox(height: 32),

                          // --- SESSÃO 3: A EXPERIÊNCIA ---
                          _buildSectionTitle("3. Sobre a Experiência"),
                          Selector(
                            labelText:
                                "Seus objetivos iniciais com essa experiência foram alcançados? *",
                            value: _objetivos,
                            items: NpsConstantes.simParcialmenteNao,
                            validator: (val) => FormValidators.selection(
                              val,
                              fieldName: 'opção',
                            ),
                            onChanged: (val) =>
                                setState(() => _objetivos = val),
                          ),
                          const SizedBox(height: 24),
                          Editor(
                            controller: _aprendeuCtrl,
                            labelText:
                                "O que você mais gostou ou aprendeu sendo Host? *",
                            hintText: "Compartilhe um pouco da sua vivência...",
                            keyboardType: TextInputType.multiline,
                            isPassword: false,
                            enabled: true,
                            validator: (val) => FormValidators.notEmpty(
                              val,
                              fieldName: 'relato do que aprendeu',
                            ),
                          ),
                          const SizedBox(height: 24),
                          Editor(
                            controller: _melhorarCtrl,
                            labelText:
                                "O que a AIESEC deve melhorar no programa Lar Global? *",
                            hintText: "Deixe suas críticas construtivas...",
                            keyboardType: TextInputType.multiline,
                            isPassword: false,
                            enabled: true,
                            validator: (val) => FormValidators.notEmpty(
                              val,
                              fieldName: 'sugestão de melhoria',
                            ),
                          ),
                          const SizedBox(height: 32),

                          // --- SESSÃO 4: NPS ---
                          _buildSectionTitle("4. Avaliação Final"),
                          const Text(
                            "Em uma escala de 1 a 10, o quanto você recomendaria a experiência de ser Host para um amigo ou familiar? *",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(10, (index) {
                              final number = index + 1;
                              final isSelected = _notaNps == number;
                              return InkWell(
                                onTap: () => setState(() => _notaNps = number),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      number.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 32),
                          Selector(
                            labelText:
                                "Você gostaria de ser Host novamente no futuro? *",
                            value: _novamente,
                            items: NpsConstantes.simNaoTalvez,
                            validator: (val) => FormValidators.selection(
                              val,
                              fieldName: 'opção',
                            ),
                            onChanged: (val) {
                              setState(() {
                                _novamente = val;
                                if (val == 'Sim') _motivoCtrl.clear();
                              });
                            },
                          ),
                          if (_novamente == 'Não' ||
                              _novamente == 'Talvez') ...[
                            const SizedBox(height: 24),
                            Editor(
                              controller: _motivoCtrl,
                              labelText: "Por qual motivo? *",
                              hintText: "Explique brevemente...",
                              keyboardType: TextInputType.multiline,
                              isPassword: false,
                              enabled: true,
                              validator: (val) {
                                if (_novamente == 'Não' ||
                                    _novamente == 'Talvez') {
                                  return FormValidators.notEmpty(
                                    val,
                                    fieldName: 'motivo',
                                  );
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 32),

                          // --- SESSÃO 5: FOTO E INDICAÇÃO ---
                          _buildSectionTitle("5. Memórias e Indicações"),
                          const Text(
                            "Deixe uma foto da sua experiência sendo Host! (Opcional)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _selecionarFoto,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: _fotoSelecionada != null
                                  ? FutureBuilder<Uint8List>(
                                      // --- TRECHO MODIFICADO (FutureBuilder) ---
                                      future: _fotoSelecionada!.readAsBytes(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        if (snapshot.hasError ||
                                            !snapshot.hasData) {
                                          return const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                            ),
                                          );
                                        }
                                        // Usa Image.memory que funciona 100% na Web e no Mobile
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        );
                                      },
                                    )
                                  // -----------------------------------------------------
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo_outlined,
                                          color: Colors.grey.shade400,
                                          size: 36,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Toque para anexar uma imagem",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Editor(
                            controller: _indicacaoCtrl,
                            labelText:
                                "Tem algum amigo ou parente para indicar? (Deixe Nome e Celular)",
                            hintText: "Opcional",
                            keyboardType: TextInputType.multiline,
                            isPassword: false,
                            enabled: true,
                          ),
                          const SizedBox(height: 48),

                          // --- BOTÃO ENVIAR ---
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _enviarAvaliacao,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Enviar Avaliação",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Divider(color: Colors.grey.shade300, thickness: 1),
        ],
      ),
    );
  }
}
