import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/widgets/selector.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/models/perfil_usuario.dart';
import 'package:aiesec_lar_global/data/services/usuario_service.dart';
import 'package:aiesec_lar_global/data/models/acesso_usuario.dart';
import 'package:aiesec_lar_global/data/services/acesso_service.dart';

class DropdownPerfil extends StatelessWidget {
  final Usuario usuario;
  final bool isDisabled;

  const DropdownPerfil({
    super.key,
    required this.usuario,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDisabled) {
      return Text(
        usuario.perfil.name.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return SizedBox(
      width: 140,
      child: Selector<PerfilUsuario>(
        isFilter: true,
        value: usuario.perfil,
        items: PerfilUsuario.values,
        itemLabelBuilder: (p) => p.name.toUpperCase(),
        onChanged: (novoPerfil) async {
          if (novoPerfil != null) {
            String? novoComiteNome = usuario.aiesecMaisProxima;
            String? comiteIdParaAcesso;

            if (novoPerfil != PerfilUsuario.admin) {
              novoComiteNome = null;
              comiteIdParaAcesso = null;
            } else {
              // Ao ser promovido para Admin, mantemos o Nome no perfil dele,
              // mas forçamos o ID do Acesso a nascer nulo para que o SuperAdmin
              // seja obrigado a escolher no segundo dropdown e gravar o ID correto.
              comiteIdParaAcesso = null;
            }

            final atualizado = usuario.copyWith(
              perfil: novoPerfil,
              aiesecMaisProxima: novoComiteNome,
            );

            await UsuarioService.instance.atualizarUsuario(usuario: atualizado);

            final isEspecial =
                novoPerfil == PerfilUsuario.admin ||
                novoPerfil.name.toLowerCase() == 'superadmin';

            if (isEspecial) {
              final papel = novoPerfil.name.toLowerCase() == 'superadmin'
                  ? PapelAcesso.superadmin
                  : PapelAcesso.admin;

              final novoAcesso = AcessoUsuario(
                uid: usuario.uid,
                papel: papel,
                comiteGerenciado: comiteIdParaAcesso,
                concedidoEm: DateTime.now(),
              );
              await AcessoService.instance.definirAcesso(acesso: novoAcesso);
            } else {
              await AcessoService.instance.removerAcesso(uid: usuario.uid);
            }
          }
        },
      ),
    );
  }
}
