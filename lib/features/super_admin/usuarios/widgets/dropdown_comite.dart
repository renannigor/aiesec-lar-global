import 'package:aiesec_lar_global/data/models/perfil_usuario.dart';
import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/widgets/selector.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/services/usuario_service.dart';
import 'package:aiesec_lar_global/data/models/acesso_usuario.dart';
import 'package:aiesec_lar_global/data/services/acesso_service.dart';

class DropdownComite extends StatelessWidget {
  final Usuario usuario;
  final List<ComiteLocal> comites;
  final bool isDisabled;

  const DropdownComite({
    super.key,
    required this.usuario,
    required this.comites,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Se não for Admin/Superadmin, exibe apenas um traço
    if (usuario.perfil != PerfilUsuario.admin) {
      return Text("-", style: TextStyle(color: Colors.grey[400]));
    }

    // 2. Busca o objeto ComiteLocal comparando o NOME salvo no usuário
    ComiteLocal? comiteAtual;
    try {
      comiteAtual = comites.firstWhere(
        (c) => c.nome == usuario.aiesecMaisProxima,
      );
    } catch (_) {
      comiteAtual = null; // Caso esteja vazio ou com nome incorreto
    }

    // 3. Estado bloqueado (somente leitura)
    if (isDisabled) {
      final comiteNomeDisplay =
          comiteAtual?.nome ?? usuario.aiesecMaisProxima ?? "Não definido";

      return Text(
        comiteNomeDisplay,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    // 4. Dropdown Dinâmico (Usa o objeto inteiro ComiteLocal)
    return SizedBox(
      width: 180,
      child: Selector<ComiteLocal>(
        isFilter: true,
        value: comiteAtual, // Passa o objeto como valor inicial
        items: comites, // Passa a lista de objetos
        itemLabelBuilder: (comite) =>
            comite.nome, // Diz pro Selector exibir o nome na tela
        onChanged: (ComiteLocal? comiteSelecionado) async {
          if (comiteSelecionado == null || comiteSelecionado.comiteId == null) {
            return;
          }

          // Separamos as variáveis!
          final String novoNomeComite = comiteSelecionado.nome;
          final String novoIdComite = comiteSelecionado.comiteId!;

          // SALVA O NOME no perfil do Usuário
          final atualizado = usuario.copyWith(
            aiesecMaisProxima: novoNomeComite,
          );
          await UsuarioService.instance.atualizarUsuario(usuario: atualizado);

          // SALVA O ID na tabela de Acessos
          final papel = usuario.perfil.name.toLowerCase() == 'superadmin'
              ? PapelAcesso.superadmin
              : PapelAcesso.admin;

          final acessoAtualizado = AcessoUsuario(
            uid: usuario.uid,
            papel: papel,
            comiteGerenciado: novoIdComite,
            concedidoEm: DateTime.now(),
          );

          await AcessoService.instance.definirAcesso(acesso: acessoAtualizado);
        },
      ),
    );
  }
}
