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
        Widget
        screenToDisplay; // Variável para segurar a tela que será mostrada

        if (acessoSnapshot.connectionState == ConnectionState.waiting) {
          screenToDisplay = const Scaffold(
            key: ValueKey('loading'), // Chave de identificação
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (acessoSnapshot.hasError) {
          print('🚨 ERRO NO STREAM DE ACESSO: ${acessoSnapshot.error}');
          screenToDisplay = Scaffold(
            key: const ValueKey('error'),
            body: Center(child: Text("Erro: ${acessoSnapshot.error}")),
          );
        }
        // Se NÃO existir um documento na coleção 'acessos', ele é obrigatoriamente um HOST
        else if (!acessoSnapshot.hasData || acessoSnapshot.data == null) {
          screenToDisplay = const HostUI(key: ValueKey('host'));
        }
        // Se existir, verificamos o papel real definido pelo Superadmin
        else {
          final acesso = acessoSnapshot.data!;
          switch (acesso.papel) {
            case PapelAcesso.admin:
              screenToDisplay = const AdminUI(key: ValueKey('admin'));
              break;
            case PapelAcesso.superadmin:
              screenToDisplay = const SuperAdminUI(key: ValueKey('superadmin'));
              break;
          }
        }

        // O AnimatedSwitcher resolve o bug "!isDisposed" da web
        // Ele força a árvore de widgets a ser desmontada com cuidado.
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: screenToDisplay,
        );
      },
    );
  }
}
