import 'package:aiesec_lar_global/data/models/perfil_usuario.dart';
import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/services/usuario_service.dart';

// --- NOVOS IMPORTS DE ACESSO ---
import 'package:aiesec_lar_global/data/models/acesso_usuario.dart';
import 'package:aiesec_lar_global/data/services/acesso_service.dart';

class DropdownComite extends StatelessWidget {
  final Usuario usuario;
  final List<ComiteLocal> comites;
  final Function(Usuario) onUpdate;

  const DropdownComite({
    super.key,
    required this.usuario,
    required this.comites,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (usuario.perfil != PerfilUsuario.admin) {
      return Text("-", style: TextStyle(color: Colors.grey[400]));
    }

    return Container(
      width: 180,
      alignment: Alignment.centerLeft,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: usuario.comiteLocalId,
          hint: Text(
            "Selecione...",
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
          icon: Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey[400]),
          style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
          isExpanded: true,
          isDense: true,

          // Builder para o item selecionado (na tabela)
          selectedItemBuilder: (BuildContext context) {
            return comites.map<Widget>((ComiteLocal item) {
              return Text(
                item.nome,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              );
            }).toList();
          },

          // Builder para o menu flutuante - Texto completo
          items: comites.map((c) {
            return DropdownMenuItem(value: c.comiteId, child: Text(c.nome));
          }).toList(),

          onChanged: (novoId) async {
            final atualizado = usuario.copyWith(comiteLocalId: novoId);

            // 1. Atualiza na tabela visual de usuários
            await UsuarioService.instance.atualizarUsuario(usuario: atualizado);

            // 2. Atualiza imediatamente o Comitê na tabela de Acessos
            final papel = usuario.perfil.name.toLowerCase() == 'superadmin'
                ? PapelAcesso.superadmin
                : PapelAcesso.admin;

            final acessoAtualizado = AcessoUsuario(
              uid: usuario.uid,
              papel: papel,
              comiteGerenciado: novoId,
              concedidoEm:
                  DateTime.now(), // Atualiza a data da concessão do acesso
            );
            await AcessoService.instance.definirAcesso(
              acesso: acessoAtualizado,
            );

            // 3. Atualiza na tela
            onUpdate(atualizado);
          },
        ),
      ),
    );
  }
}
