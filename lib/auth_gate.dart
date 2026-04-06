import 'package:aiesec_lar_global/data/models/acesso_usuario.dart';
import 'package:aiesec_lar_global/data/services/acesso_service.dart'; // Crie esse service ou use o Firestore direto
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/services/usuario_service.dart';
import 'package:aiesec_lar_global/features/admin/admin_ui.dart';
import 'package:aiesec_lar_global/features/auth/auth_ui.dart';
import 'package:aiesec_lar_global/features/auth/verify_email_screen.dart';
import 'package:aiesec_lar_global/features/host/host_ui.dart';
import 'package:aiesec_lar_global/features/super_admin/super_admin_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser == null) return const AuthUI();
    if (!firebaseUser.emailVerified) return const VerifyEmailScreen();

    // Vamos usar um StreamBuilder aninhado ou combinar os dados
    return StreamBuilder<Usuario?>(
      stream: UsuarioService.instance.getUsuarioStream(uid: firebaseUser.uid),
      builder: (context, usuarioSnapshot) {
        if (usuarioSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!usuarioSnapshot.hasData) return const AuthUI();

        // Agora buscamos o acesso na coleção protegida que o usuário NÃO edita
        return StreamBuilder<AcessoUsuario?>(
          stream: AcessoService.instance.getAcessoStream(uid: firebaseUser.uid),
          builder: (context, acessoSnapshot) {
            // Enquanto verifica o acesso, pode mostrar um loading rápido
            if (acessoSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (acessoSnapshot.hasError) {
              print(
                '🚨 ERRO FATAL NO STREAM DE ACESSO: ${acessoSnapshot.error}',
              );
            }

            print('Dados do usuário: ${usuarioSnapshot.data?.nome}');
            print('Dados de acesso: ${acessoSnapshot.hasData}');

            // Se NÃO existir um documento na coleção 'acessos', ele é obrigatoriamente um HOST
            if (!acessoSnapshot.hasData || acessoSnapshot.data == null) {
              print(
                'Nenhum acesso encontrado para o usuário ${firebaseUser.uid}, assumindo papel HOST',
              );
              return const HostUI();
            }

            // Se existir, verificamos o papel real definido pelo Superadmin
            final acesso = acessoSnapshot.data!;
            switch (acesso.papel) {
              case PapelAcesso.admin:
                return const AdminUI();
              case PapelAcesso.superadmin:
                return const SuperAdminUI();
            }
          },
        );
      },
    );
  }
}
