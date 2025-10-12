import 'package:aiesec_lar_global/data/models/perfil_usuario.dart';
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
    // 1. Ouve o estado de autenticação do Firebase Auth
    final firebaseUser = context.watch<User?>();

    // Se não há usuário logado, mostra a tela de autenticação
    if (firebaseUser == null) {
      return const AuthUI();
    }

    // 2. Se o usuário está logado, mas o e-mail não foi verificado, mostra a tela de verificação
    if (!firebaseUser.emailVerified) {
      return const VerifyEmailScreen();
    }

    // 3. Se o e-mail foi verificado, busca o perfil no Firestore e redireciona
    return StreamBuilder<Usuario?>(
      stream: UsuarioService.instance.getUsuarioStream(uid: firebaseUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const AuthUI(); // Se não encontrar o perfil, volta para o login
        }

        final usuario = snapshot.data!;
        switch (usuario.perfil) {
          case PerfilUsuario.host:
            return const HostUI();
          case PerfilUsuario.admin:
            return const AdminUI();
          case PerfilUsuario.superadmin:
            return const SuperAdminUI();
          default:
            return const AuthUI();
        }
      },
    );
  }
}
