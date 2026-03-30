import 'package:flutter/material.dart';
import 'components/auth_branding_panel.dart';
import 'components/sign_in_form.dart';
import 'components/sign_up_form.dart';
import 'components/forgot_password_form.dart';

// Enum para controlar o estado do formulário
enum AuthMode { signIn, signUp, forgotPassword }

class AuthDesktopUI extends StatefulWidget {
  const AuthDesktopUI({super.key});

  @override
  State<AuthDesktopUI> createState() => _AuthDesktopUIState();
}

class _AuthDesktopUIState extends State<AuthDesktopUI> {
  // O estado inicial é o formulário de login
  AuthMode _mode = AuthMode.signIn;

  void _switchTo(AuthMode mode) {
    setState(() {
      _mode = mode;
    });
  }

  // Função para decidir qual formulário mostrar
  Widget _buildForm() {
    switch (_mode) {
      case AuthMode.signIn:
        return SignInForm(
          onSwitchToSignUp: () => _switchTo(AuthMode.signUp),
          onForgotPassword: () => _switchTo(AuthMode.forgotPassword),
        );
      case AuthMode.signUp:
        return SignUpForm(onSwitchToSignIn: () => _switchTo(AuthMode.signIn));
      case AuthMode.forgotPassword:
        return ForgotPasswordForm(
          onSwitchToSignIn: () => _switchTo(AuthMode.signIn),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Painel da Esquerda (estático e sem rolagem)
          const Expanded(child: AuthBrandingPanel()),

          // Painel da Direita
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  // A MÁGICA ACONTECE AQUI:
                  // O Expanded faz a área de rolagem ocupar todo o espaço disponível
                  // empurrando as logos sempre para o rodapé.
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        // O padding garante que o formulário não cole nas bordas ao rolar
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: _buildForm(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Rodapé fixo com as Logos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/image/lar_global_logo.png',
                        height: 60,
                      ),
                      const SizedBox(width: 48),
                      Image.asset('assets/image/aiesec_logo.png', height: 45),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
