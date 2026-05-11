import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// --- IMPORTS CORE ---
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';

// --- IMPORTS DATA ---
import 'package:aiesec_lar_global/data/models/comite_local.dart';
import 'package:aiesec_lar_global/data/services/auth_service.dart';
import 'package:aiesec_lar_global/data/services/acesso_service.dart';
import 'package:aiesec_lar_global/data/services/comite_local_service.dart';

class ComiteUI extends StatefulWidget {
  const ComiteUI({super.key});

  @override
  State<ComiteUI> createState() => _ComiteUIState();
}

class _ComiteUIState extends State<ComiteUI> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  ComiteLocal? _comite;

  // --- CONTROLLERS (Apenas os editáveis do novo model) ---
  final _telefoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // --- MÁSCARA ---
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    _carregarDadosDoComite();
  }

  @override
  void dispose() {
    _telefoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosDoComite() async {
    try {
      final uid = AuthService.instance.currentUser?.uid;
      if (uid == null) throw Exception("Usuário não está logado.");

      final acesso = await AcessoService.instance
          .getAcessoStream(uid: uid)
          .first;
      final comiteId = acesso?.comiteGerenciado;

      debugPrint("Acesso do usuário $uid ao comitê $comiteId");

      if (comiteId == null) throw Exception("Você não gerencia nenhum comitê.");

      final comiteLocal = await ComiteLocalService.instance.getComiteLocal(
        comiteId: comiteId,
      );

      if (comiteLocal == null) {
        throw Exception("Dados do comitê não encontrados no banco.");
      }

      _preencherControllers(comiteLocal);

      if (mounted) {
        setState(() {
          _comite = comiteLocal;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarUtils.showError("Erro ao carregar comitê: $e");
      }
    }
  }

  void _preencherControllers(ComiteLocal c) {
    _telefoneCtrl.text = c.telefone ?? '';
    _emailCtrl.text = c.email ?? '';
  }

  Future<void> _salvarAlteracoes() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_comite == null || _comite!.comiteId == null) return;

    setState(() => _isSaving = true);

    try {
      // Cria o objeto atualizado mesclando os dados originais com os editados
      final comiteAtualizado = ComiteLocal(
        comiteId: _comite!.comiteId,
        nome: _comite!.nome,
        cidade: _comite!.cidade,
        estado: _comite!.estado,
        status: _comite!.status,
        nomePodio: _comite!.nomePodio,
        telefone: _telefoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );

      await ComiteLocalService.instance.atualizarComiteLocal(
        comite: comiteAtualizado,
      );

      if (mounted) {
        SnackbarUtils.showSuccess(
          "Dados de contato do comitê salvos com sucesso!",
        );
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError("Erro ao salvar: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_comite == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text("Nenhum comitê vinculado à sua conta.")),
      );
    }

    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _salvarAlteracoes,
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(Icons.save, color: Colors.white, size: 20),
        label: Text(
          _isSaving ? "Salvando..." : "Salvar Contato",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 16 : 32,
          isMobile ? 16 : 32,
          isMobile ? 16 : 32,
          100, // Padding para o FAB
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CABEÇALHO DA TELA
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Configurações do Comitê",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Gerencie os dados institucionais da ${_comite!.nome} para o programa Lar Global.",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 1. INFORMAÇÕES BASE (Apenas leitura)
                  _buildCardWrapper(
                    title: "Informações Básicas (Somente Leitura)",
                    child: _buildResponsiveRow(isMobile, [
                      Editor(
                        controller: TextEditingController(text: _comite!.nome),
                        labelText: "Nome do Comitê",
                        enabled: false,
                        isPassword: false,
                        keyboardType: TextInputType.text,
                      ),
                      Editor(
                        controller: TextEditingController(
                          text: "${_comite!.cidade} - ${_comite!.estado}",
                        ),
                        labelText: "Localização",
                        enabled: false,
                        isPassword: false,
                        keyboardType: TextInputType.text,
                      ),
                      Editor(
                        controller: TextEditingController(
                          text: _comite!.status,
                        ),
                        labelText: "Status",
                        enabled: false,
                        isPassword: false,
                        keyboardType: TextInputType.text,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // 2. CONTATO (Editável)
                  _buildCardWrapper(
                    title: "Informações de Contato",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Estes são os canais oficiais do Comitê para a comunicação com os Hosts.",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        _buildResponsiveRow(isMobile, [
                          Editor(
                            controller: _emailCtrl,
                            labelText: "E-mail Oficial",
                            enabled: true,
                            isPassword: false,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          Editor(
                            controller: _telefoneCtrl,
                            labelText: "Telefone de Contato (WhatsApp)",
                            enabled: true,
                            isPassword: false,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [_phoneMaskFormatter],
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildCardWrapper({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
