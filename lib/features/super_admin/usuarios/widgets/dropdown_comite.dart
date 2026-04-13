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
  final Function(Usuario) onUpdate;
  final bool isDisabled;

  const DropdownComite({
    super.key,
    required this.usuario,
    required this.comites,
    required this.onUpdate,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (usuario.perfil != PerfilUsuario.admin) {
      return Text("-", style: TextStyle(color: Colors.grey[400]));
    }

    if (isDisabled) {
      // Como aiesecMaisProxima já é o nome único, não precisamos mais fazer o filtro (.where)
      final comiteNome = usuario.aiesecMaisProxima ?? "Não definido";

      return Text(
        comiteNome,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    return SizedBox(
      width: 180, // Controla a largura dentro da tabela
      child: Selector<String>(
        isFilter: true, // Usa o estilo de borda fina
        value: usuario.aiesecMaisProxima, // Lê do campo correto
        // Extrai apenas a lista de NOMES dos comitês para o menu
        items: comites.map((c) => c.nome).toList(),

        // Como 'items' já são Strings (nomes), apenas retornamos o próprio valor
        itemLabelBuilder: (nome) => nome,

        onChanged: (novoNome) async {
          if (novoNome == null) return;

          // Atualiza o nome do comitê no model
          final atualizado = usuario.copyWith(aiesecMaisProxima: novoNome);

          await UsuarioService.instance.atualizarUsuario(usuario: atualizado);

          final papel = usuario.perfil.name.toLowerCase() == 'superadmin'
              ? PapelAcesso.superadmin
              : PapelAcesso.admin;

          final acessoAtualizado = AcessoUsuario(
            uid: usuario.uid,
            papel: papel,
            comiteGerenciado:
                novoNome, // Atualiza a permissão de Acesso com o nome
            concedidoEm: DateTime.now(),
          );

          await AcessoService.instance.definirAcesso(acesso: acessoAtualizado);

          onUpdate(atualizado);
        },
      ),
    );
  }
}
