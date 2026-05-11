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
        Widget screenToDisplay = const Scaffold(body: SizedBox.shrink());

        if (acessoSnapshot.connectionState == ConnectionState.waiting) {
          screenToDisplay = const Scaffold(
            key: ValueKey('loading'),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (acessoSnapshot.hasError) {
          print('🚨 ERRO NO STREAM DE ACESSO: ${acessoSnapshot.error}');
          screenToDisplay = Scaffold(
            key: const ValueKey('error'),
            body: Center(child: Text("Erro: ${acessoSnapshot.error}")),
          );
        } else if (!acessoSnapshot.hasData || acessoSnapshot.data == null) {
          screenToDisplay = const HostUI(key: ValueKey('host'));
        } else {
          final acesso = acessoSnapshot.data!;
          // Geramos chaves com os IDs reais do usuário para torná-las absolutas e únicas,
          // evitando assim o erro de DuplicateKeys.
          switch (acesso.papel) {
            case PapelAcesso.admin:
              screenToDisplay = AdminUI(
                key: ValueKey('admin_${firebaseUser.uid}'),
              );
              break;
            case PapelAcesso.superadmin:
              screenToDisplay = SuperAdminUI(
                key: ValueKey('superadmin_${firebaseUser.uid}'),
              );
              break;
          }
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: screenToDisplay,
        );
      },
    );
  }
}
