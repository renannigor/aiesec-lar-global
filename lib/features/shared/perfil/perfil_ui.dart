import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/features/shared/perfil/perfil_desktop_ui.dart';
import 'package:aiesec_lar_global/features/shared/perfil/perfil_mobile_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORTS MODELS/SERVICES ---
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/services/auth_service.dart';
import 'package:aiesec_lar_global/data/services/usuario_service.dart';
import 'package:aiesec_lar_global/providers/auth_provider.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';

import 'package:aiesec_lar_global/features/shared/perfil/components/custom_bottom_sheet.dart';

// --- IMPORTS FORMS ---
import 'forms/form_dados_pessoais.dart';
import 'forms/form_endereco.dart';
import 'forms/form_preferencias.dart';
import 'forms/form_detalhes_hospedagem.dart';

class PerfilUI extends StatefulWidget {
  const PerfilUI({super.key});

  @override
  State<PerfilUI> createState() => _PerfilUIState();
}

class _PerfilUIState extends State<PerfilUI> {
  // 1. Mudamos de Future para Stream!
  late Stream<Usuario?> _usuarioStream;
  String _secaoSelecionada = 'Pessoal';
  Usuario? _usuarioBuffer;

  @override
  void initState() {
    super.initState();
    // 2. Inicializa a escuta em tempo real direto do banco de dados
    _usuarioStream = UsuarioService.instance.getUsuarioStream(
      uid: AuthService.instance.currentUser!.uid,
    );
  }

  void _inicializarBuffer(Usuario usuarioOriginal) {
    if (_usuarioBuffer == null || _usuarioBuffer!.uid != usuarioOriginal.uid) {
      _usuarioBuffer = usuarioOriginal;
    }
  }

  // --- FUNÇÃO DE SALVAR COM PRINTS DE DEBUG ---
  Future<bool> _salvarAlteracoes() async {
    if (_usuarioBuffer == null) {
      print(
        "[DEBUG UI] _salvarAlteracoes: _usuarioBuffer é nulo. Cancelando salvamento.",
      );
      return false;
    }

    try {
      print("=========================================");
      print("[DEBUG UI] Iniciando salvamento...");
      print("[DEBUG UI] UID do usuário: ${_usuarioBuffer!.uid}");

      final jsonPayload = _usuarioBuffer!.toJson();
      print("[DEBUG UI] JSON gerado com sucesso: $jsonPayload");

      SnackbarUtils.showInfo("Salvando alterações...");

      await UsuarioService.instance.atualizarUsuario(usuario: _usuarioBuffer!);

      print("[DEBUG UI] Salvamento concluído com sucesso!");
      print("=========================================");

      if (mounted) SnackbarUtils.showSuccess("Perfil atualizado com sucesso!");
      return true;
    } catch (e, stackTrace) {
      print("=========================================");
      print("[DEBUG UI] ERRO CAPTURADO NA UI: $e");
      print("[DEBUG UI] StackTrace: $stackTrace");
      print("=========================================");
      if (mounted) SnackbarUtils.showError("Erro ao atualizar: $e");
      return false;
    }
  }

  Future<void> _realizarLogout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sair da conta"),
        content: const Text("Tem certeza que deseja sair?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sair", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      await context.read<AuthProvider>().signOut();
    }
  }

  Future<void> _confirmarExclusaoConta() async {
    final TextEditingController confirmacaoCtrl = TextEditingController();
    const String fraseSeguranca = "EXCLUIR MINHA CONTA";

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final isBotaoHabilitado = confirmacaoCtrl.text == fraseSeguranca;

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Excluir Conta", style: TextStyle(color: Colors.red)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Essa ação é permanente e apagará todos os seus dados e interesses. Você não poderá desfazer isso.",
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Para confirmar, digite a frase abaixo:",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fraseSeguranca,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmacaoCtrl,
                    onChanged: (value) => setStateDialog(() {}),
                    decoration: InputDecoration(
                      hintText: fraseSeguranca,
                      hintStyle: TextStyle(color: Colors.grey.shade300),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: isBotaoHabilitado
                      ? () => Navigator.pop(context, true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.red.shade200,
                  ),
                  child: const Text(
                    "Sim, excluir conta",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmar == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await AuthService.instance.excluirConta();
        if (mounted) Navigator.pop(context);

        if (mounted) {
          await context.read<AuthProvider>().signOut();
          SnackbarUtils.showSuccess("Sua conta foi excluída permanentemente.");
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        SnackbarUtils.showError(e.toString());
      }
    }
  }

  void _abrirBottomSheetMobile(String secao) {
    setState(() => _secaoSelecionada = secao);
    showCustomFormSheet(
      context: context,
      title: _getTituloSecao(),
      child: _buildFormularioAtual(),
      onSave: () async => await _salvarAlteracoes(),
    );
  }

  String _getTituloSecao() {
    switch (_secaoSelecionada) {
      case 'Pessoal':
        return "Informações Pessoais";
      case 'Endereço':
        return "Endereço da Hospedagem";
      case 'Preferencias':
        return "Preferências de Intercambista";
      case 'Detalhes':
        return "Detalhes da Casa";
      default:
        return "";
    }
  }

  String _getSubtituloSecao() {
    switch (_secaoSelecionada) {
      case 'Pessoal':
        return "Dados de contato.";
      case 'Endereço':
        return "Mantenha o endereço atualizado.";
      case 'Preferencias':
        return "Defina o perfil ideal que você deseja.";
      case 'Detalhes':
        return "Estrutura e regras da sua casa.";
      default:
        return "";
    }
  }

  Widget _buildFormularioAtual() {
    if (_usuarioBuffer == null) return const SizedBox();
    switch (_secaoSelecionada) {
      case 'Pessoal':
        return FormDadosPessoais(
          usuario: _usuarioBuffer!,
          onChanged: (novoUsuario) => _usuarioBuffer = novoUsuario,
        );
      case 'Endereço':
        return FormEndereco(
          enderecoAtual: _usuarioBuffer!.endereco,
          onChanged: (end) =>
              _usuarioBuffer = _usuarioBuffer!.copyWith(endereco: end),
        );
      case 'Preferencias':
        return FormPreferencias(
          prefsAtual: _usuarioBuffer!.preferenciasHospedagem,
          expectativasAtual: _usuarioBuffer!.expectativasIntercambista,
          onChanged: (prefs, exp) => _usuarioBuffer = _usuarioBuffer!.copyWith(
            preferenciasHospedagem: prefs,
            expectativasIntercambista: exp,
          ),
        );
      case 'Detalhes':
        return FormDetalhesHospedagem(
          detalhesAtual: _usuarioBuffer!.detalhesHospedagem,
          onChanged: (d) =>
              _usuarioBuffer = _usuarioBuffer!.copyWith(detalhesHospedagem: d),
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 4. Mudamos o Builder para usar o Stream
      body: StreamBuilder<Usuario?>(
        stream: _usuarioStream,
        builder: (context, snapshot) {
          // O CircularProgressIndicator só aparece na PRIMEIRA vez que abre a tela.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Erro ao carregar perfil"));
          }

          final usuarioOriginal = snapshot.data!;

          _inicializarBuffer(usuarioOriginal);

          return Responsive(
            mobile: PerfilMobileUI(
              usuario: _usuarioBuffer!,
              onMenuOptionTap: _abrirBottomSheetMobile,
              onLogout: _realizarLogout,
              onDeleteAccount: _confirmarExclusaoConta,
            ),
            tablet: PerfilMobileUI(
              usuario: _usuarioBuffer!,
              onMenuOptionTap: _abrirBottomSheetMobile,
              onLogout: _realizarLogout,
              onDeleteAccount: _confirmarExclusaoConta,
            ),
            desktop: PerfilDesktopUI(
              usuario: _usuarioBuffer!,
              secaoSelecionada: _secaoSelecionada,
              onSecaoChanged: (key) => setState(() => _secaoSelecionada = key),
              onLogout: _realizarLogout,
              onDeleteAccount: _confirmarExclusaoConta,
              onSave: _salvarAlteracoes,
              tituloSecao: _getTituloSecao(),
              subtituloSecao: _getSubtituloSecao(),
              formChild: _buildFormularioAtual(),
            ),
          );
        },
      ),
    );
  }
}
