import 'package:aiesec_lar_global/data/models/acesso_usuario.dart';
import 'package:aiesec_lar_global/data/services/acesso_service.dart';
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

    return StreamBuilder<AcessoUsuario?>(
      stream: AcessoService.instance.getAcessoStream(uid: firebaseUser.uid),
      builder: (context, acessoSnapshot) {
        if (acessoSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (acessoSnapshot.hasError) {
          print('🚨 ERRO NO STREAM DE ACESSO: ${acessoSnapshot.error}');
        }

        // Se NÃO existir um documento na coleção 'acessos', ele é obrigatoriamente um HOST
        if (!acessoSnapshot.hasData || acessoSnapshot.data == null) {
          print(
            'Nenhum acesso encontrado para ${firebaseUser.uid}, abrindo HostUI',
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
  }
}
