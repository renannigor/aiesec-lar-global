import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/models/perfil_usuario.dart';
import 'package:aiesec_lar_global/data/services/usuario_service.dart';

class DropdownPerfil extends StatelessWidget {
  final Usuario usuario;
  final Function(Usuario) onUpdate;

  const DropdownPerfil({
    super.key,
    required this.usuario,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<PerfilUsuario>(
        value: usuario.perfil,
        icon: Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey[400]),
        style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
        isDense: true,
        items: PerfilUsuario.values.map((p) {
          return DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()));
        }).toList(),
        onChanged: (novoPerfil) async {
          if (novoPerfil != null) {
            String? novoComiteId = usuario.comiteLocalId;

            // REGRA DE NEGÓCIO: Se não for ADMIN, limpa o comitê
            if (novoPerfil != PerfilUsuario.admin) {
              novoComiteId = null;
            }

            final atualizado = usuario.copyWith(
              perfil: novoPerfil,
              comiteLocalId: novoComiteId,
            );

            // Atualiza no banco
            await UsuarioService.instance.atualizarUsuario(usuario: atualizado);
            // Atualiza na tela
            onUpdate(atualizado);
          }
        },
      ),
    );
  }
}
