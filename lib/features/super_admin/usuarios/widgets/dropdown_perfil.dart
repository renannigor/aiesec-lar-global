import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/models/perfil_usuario.dart';
import 'package:aiesec_lar_global/data/services/usuario_service.dart';

// --- NOVOS IMPORTS DE ACESSO ---
import 'package:aiesec_lar_global/data/models/acesso_usuario.dart';
import 'package:aiesec_lar_global/data/services/acesso_service.dart';

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

            // REGRA DE NEGÓCIO: Se não for ADMIN, limpa o comitê.
            // (SuperAdmin também não tem comitê fixo, pois gerencia todos)
            if (novoPerfil != PerfilUsuario.admin) {
              novoComiteId = null;
            }

            final atualizado = usuario.copyWith(
              perfil: novoPerfil,
              comiteLocalId: novoComiteId,
            );

            // 1. Atualiza os dados visuais na coleção de 'usuarios'
            await UsuarioService.instance.atualizarUsuario(usuario: atualizado);

            // 2. Sincroniza as PERMISSÕES na coleção de 'acessos'
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
                comiteGerenciado: novoComiteId,
                concedidoEm: DateTime.now(),
              );
              // Cria/Sobrescreve a permissão
              await AcessoService.instance.definirAcesso(acesso: novoAcesso);
            } else {
              // Se foi rebaixado para Host comum, remove a permissão de acesso
              await AcessoService.instance.removerAcesso(uid: usuario.uid);
            }

            // 3. Atualiza na tela
            onUpdate(atualizado);
          }
        },
      ),
    );
  }
}
