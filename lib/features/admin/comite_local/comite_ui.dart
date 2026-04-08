import 'package:aiesec_lar_global/data/models/comite_local/dados_presidente.dart';
import 'package:aiesec_lar_global/features/admin/comite_local/components/testemunha_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// --- IMPORTS CORE ---
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';

// --- IMPORTS DATA ---
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/models/comite_local/testemunha.dart';
import 'package:aiesec_lar_global/data/models/endereco.dart';
import 'package:aiesec_lar_global/data/services/auth_service.dart';
import 'package:aiesec_lar_global/data/services/acesso_service.dart';
import 'package:aiesec_lar_global/data/services/comite_local_service.dart';
import 'package:aiesec_lar_global/data/services/viacep_service.dart';

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

  // --- CONTROLLERS ---
  final _cnpjCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  final _presNomeCtrl = TextEditingController();
  final _presEstadoCivilCtrl = TextEditingController();
  final _presEmailCtrl = TextEditingController();
  final _presTelefoneCtrl = TextEditingController();
  final _presRgCtrl = TextEditingController();
  final _presOrgaoEmissorCtrl = TextEditingController();
  final _presCpfCtrl = TextEditingController();

  final _endCepCtrl = TextEditingController();
  final _endLogradouroCtrl = TextEditingController();
  final _endNumeroCtrl = TextEditingController();
  final _endComplementoCtrl = TextEditingController();
  final _endBairroCtrl = TextEditingController();

  // Testemunhas na Memória
  List<Testemunha> _testemunhasAtuais = [];

  // --- MÁSCARAS ---
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
    _carregarDadosDoComite();
  }

  Future<void> _carregarDadosDoComite() async {
    try {
      final uid = AuthService.instance.currentUser?.uid;
      if (uid == null) throw Exception("Usuário não está logado.");

      final acesso = await AcessoService.instance
          .getAcessoStream(uid: uid)
          .first;
      final comiteId = acesso?.comiteGerenciado;

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
    _cnpjCtrl.text = c.cnpj ?? '';
    _telefoneCtrl.text = c.telefone ?? '';
    _emailCtrl.text = c.email ?? '';

    if (c.dadosPresidente != null) {
      _presNomeCtrl.text = c.dadosPresidente!.nomeCompleto;
      _presEstadoCivilCtrl.text = c.dadosPresidente!.estadoCivil;
      _presEmailCtrl.text = c.dadosPresidente!.email;
      _presTelefoneCtrl.text = c.dadosPresidente!.telefone;
      _presRgCtrl.text = c.dadosPresidente!.rg;
      _presOrgaoEmissorCtrl.text = c.dadosPresidente!.orgaoEmissor;
      _presCpfCtrl.text = c.dadosPresidente!.cpf;
    }

    if (c.endereco != null) {
      _endCepCtrl.text = c.endereco!.cep;
      _endLogradouroCtrl.text = c.endereco!.logradouro;
      _endNumeroCtrl.text = c.endereco!.numero;
      _endComplementoCtrl.text = c.endereco!.complemento ?? '';
      _endBairroCtrl.text = c.endereco!.bairro;
    }

    _testemunhasAtuais = List.from(c.testemunhas);
  }

  Future<void> _buscarEnderecoPorCep(String cep) async {
    if (cep.replaceAll(RegExp(r'[^0-9]'), '').length != 8) return;

    final endereco = await ViaCepService.buscarCep(cep);

    if (mounted) {
      if (endereco != null) {
        setState(() {
          _endLogradouroCtrl.text =
              endereco['logradouro'] ?? _endLogradouroCtrl.text;
          _endBairroCtrl.text = endereco['bairro'] ?? _endBairroCtrl.text;
        });
        FocusScope.of(context).nextFocus();
      } else {
        SnackbarUtils.showError('CEP não encontrado ou inválido.');
      }
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_comite == null || _comite!.comiteId == null) return;

    setState(() => _isSaving = true);

    try {
      final enderecoAtualizado = Endereco(
        cep: _endCepCtrl.text.trim(),
        logradouro: _endLogradouroCtrl.text.trim(),
        numero: _endNumeroCtrl.text.trim(),
        complemento: _endComplementoCtrl.text.trim(),
        bairro: _endBairroCtrl.text.trim(),
        cidade: _comite!.cidade,
        estado: _comite!.estado,
      );

      final presidenteAtualizado = DadosPresidente(
        nomeCompleto: _presNomeCtrl.text.trim(),
        estadoCivil: _presEstadoCivilCtrl.text.trim(),
        email: _presEmailCtrl.text.trim(),
        telefone: _presTelefoneCtrl.text.trim(),
        rg: _presRgCtrl.text.trim(),
        orgaoEmissor: _presOrgaoEmissorCtrl.text.trim(),
        cpf: _presCpfCtrl.text.trim(),
      );

      final comiteAtualizado = ComiteLocal(
        comiteId: _comite!.comiteId,
        nome: _comite!.nome,
        cidade: _comite!.cidade,
        estado: _comite!.estado,
        status: _comite!.status,
        nomePodio: _comite!.nomePodio,
        cnpj: _cnpjCtrl.text.trim(),
        telefone: _telefoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        dadosPresidente: presidenteAtualizado,
        endereco: enderecoAtualizado,
        testemunhas: _testemunhasAtuais,
      );

      await ComiteLocalService.instance.atualizarComiteLocal(
        comite: comiteAtualizado,
      );

      if (mounted) {
        SnackbarUtils.showSuccess("Dados do comitê salvos com sucesso!");
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError("Erro ao salvar: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- MÉTODOS DE TESTEMUNHAS ---
  void _removerTestemunha(int index) {
    setState(() {
      _testemunhasAtuais.removeAt(index);
    });
  }

  Future<void> _abrirFormularioTestemunha({int? index}) async {
    final testemunhaAtual = index != null ? _testemunhasAtuais[index] : null;

    final Testemunha? resultado = await showModalBottomSheet<Testemunha>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: TestemunhaFormSheet(testemunha: testemunhaAtual),
        );
      },
    );

    if (resultado != null) {
      setState(() {
        if (index != null) {
          _testemunhasAtuais[index] = resultado;
        } else {
          _testemunhasAtuais.add(resultado);
        }
      });
    }
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white, // Fundo Branco
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_comite == null) {
      return const Scaffold(
        backgroundColor: Colors.white, // Fundo Branco
        body: Center(child: Text("Nenhum comitê vinculado à sua conta.")),
      );
    }

    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white, // Fundo Branco na base
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
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
                        "Gerencie os dados institucionais da ${_comite!.nome}.",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 1. INFORMAÇÕES BASE
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

                  // 2. DADOS JURÍDICOS E CONTATO
                  _buildCardWrapper(
                    title: "Dados Institucionais de Contato",
                    child: _buildResponsiveRow(isMobile, [
                      Editor(
                        controller: _cnpjCtrl,
                        labelText: "CNPJ",
                        enabled: true,
                        isPassword: false,
                        keyboardType: TextInputType.text,
                      ),
                      Editor(
                        controller: _emailCtrl,
                        labelText: "E-mail Oficial",
                        enabled: true,
                        isPassword: false,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      Editor(
                        controller: _telefoneCtrl,
                        labelText: "Telefone",
                        enabled: true,
                        isPassword: false,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_phoneMaskFormatter],
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // 3. DADOS DO PRESIDENTE
                  _buildCardWrapper(
                    title: "Dados do Representante Legal (Presidente)",
                    child: Column(
                      children: [
                        _buildResponsiveRow(isMobile, [
                          Editor(
                            controller: _presNomeCtrl,
                            labelText: "Nome Completo",
                            enabled: true,
                            isPassword: false,
                            keyboardType: TextInputType.text,
                          ),
                          Editor(
                            controller: _presEstadoCivilCtrl,
                            labelText: "Estado Civil",
                            enabled: true,
                            isPassword: false,
                            keyboardType: TextInputType.text,
                          ),
                        ]),
                        const SizedBox(height: 16),
                        _buildResponsiveRow(isMobile, [
                          Editor(
                            controller: _presCpfCtrl,
                            labelText: "CPF",
                            enabled: true,
                            isPassword: false,
                            keyboardType: TextInputType.number,
                          ),
                          Editor(
                            controller: _presRgCtrl,
                            labelText: "RG",
                            enabled: true,
                            isPassword: false,
                            keyboardType: TextInputType.number,
                          ),
                          Editor(
                            controller: _presOrgaoEmissorCtrl,
                            labelText: "Órgão Emissor",
                            enabled: true,
                            isPassword: false,
                            keyboardType: TextInputType.text,
                          ),
                        ]),
                        const SizedBox(height: 16),
                        _buildResponsiveRow(isMobile, [
                          Editor(
                            controller: _presEmailCtrl,
                            labelText: "E-mail",
                            enabled: true,
                            isPassword: false,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          Editor(
                            controller: _presTelefoneCtrl,
                            labelText: "Telefone",
                            enabled: true,
                            isPassword: false,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [_phoneMaskFormatter],
                          ),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. ENDEREÇO
                  _buildCardWrapper(
                    title: "Endereço Físico",
                    child: Column(
                      children: [
                        _buildResponsiveRow(isMobile, [
                          Editor(
                            controller: _endCepCtrl,
                            labelText: "CEP",
                            enabled: true,
                            isPassword: false,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_cepMaskFormatter],
                            onChanged: (value) {
                              if (value.length == 9) {
                                _buscarEnderecoPorCep(value);
                              }
                            },
                          ),
                          Editor(
                            controller: _endLogradouroCtrl,
                            labelText: "Logradouro (Rua, Av.)",
                            enabled: true,
                            isPassword: false,
                            keyboardType: TextInputType.text,
                          ),
                          Editor(
                            controller: _endNumeroCtrl,
                            labelText: "Número",
                            enabled: true,
                            isPassword: false,
                            keyboardType: TextInputType.text,
                          ),
                        ]),
                        const SizedBox(height: 16),
                        _buildResponsiveRow(isMobile, [
                          Editor(
                            controller: _endComplementoCtrl,
                            labelText: "Complemento",
                            enabled: true,
                            isPassword: false,
                            keyboardType: TextInputType.text,
                          ),
                          Editor(
                            controller: _endBairroCtrl,
                            labelText: "Bairro",
                            enabled: true,
                            isPassword: false,
                            keyboardType: TextInputType.text,
                          ),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. TESTEMUNHAS
                  _buildCardWrapper(
                    title: "Testemunhas Cadastradas (Assinatura de Contratos)",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_testemunhasAtuais.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              "Nenhuma testemunha cadastrada.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _testemunhasAtuais.length,
                            separatorBuilder: (_, __) =>
                                const Divider(color: Color(0xFFEAEAEA)),
                            itemBuilder: (context, index) {
                              final t = _testemunhasAtuais[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(
                                  t.nomeCompleto,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "CPF: ${t.cpf} | RG: ${t.rg} ${t.orgaoEmissor}",
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey.shade600,
                                      ),
                                      tooltip: "Editar",
                                      onPressed: () =>
                                          _abrirFormularioTestemunha(
                                            index: index,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      tooltip: "Remover",
                                      onPressed: () =>
                                          _removerTestemunha(index),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Adicionar Testemunha"),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFEAEAEA),
                              ), // Borda suave
                            ),
                            onPressed: () => _abrirFormularioTestemunha(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // BOTÃO DE SALVAR GERAL
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _salvarAlteracoes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2, // Leve destaque no botão principal
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Salvar Alterações",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildCardWrapper({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Sombra suave para gerar contraste com o fundo branco
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
          // Removido o Divider para um visual mais limpo
          const SizedBox(height: 8),
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
