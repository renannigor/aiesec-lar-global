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
      final comiteNome =
          comites
              .where((c) => c.comiteId == usuario.comiteLocalId)
              .firstOrNull
              ?.nome ??
          "Não definido";

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
        value: usuario.comiteLocalId,
        // Passamos a lista de IDs dos comitês
        items: comites.map((c) => c.comiteId!).toList(),
        // Transformamos o ID no nome visual que vai aparecer na caixinha
        itemLabelBuilder: (id) {
          final c = comites.where((com) => com.comiteId == id).firstOrNull;
          return c?.nome ?? "Selecione...";
        },
        onChanged: (novoId) async {
          if (novoId == null) return;

          final atualizado = usuario.copyWith(comiteLocalId: novoId);

          await UsuarioService.instance.atualizarUsuario(usuario: atualizado);

          final papel = usuario.perfil.name.toLowerCase() == 'superadmin'
              ? PapelAcesso.superadmin
              : PapelAcesso.admin;

          final acessoAtualizado = AcessoUsuario(
            uid: usuario.uid,
            papel: papel,
            comiteGerenciado: novoId,
            concedidoEm: DateTime.now(),
          );

          await AcessoService.instance.definirAcesso(acesso: acessoAtualizado);

          onUpdate(atualizado);
        },
      ),
    );
  }
}
