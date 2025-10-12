import 'package:flutter/material.dart';
import 'components/auth_branding_panel.dart';
import 'components/sign_in_form.dart';
import 'components/sign_up_form.dart';
import 'components/forgot_password_form.dart';

// O Enum e a lógica de estado são os mesmos da versão Desktop
enum AuthMode { signIn, signUp, forgotPassword }

class AuthMobileUI extends StatefulWidget {
  const AuthMobileUI({super.key});

  @override
  State<AuthMobileUI> createState() => _AuthMobileUIState();
}

class _AuthMobileUIState extends State<AuthMobileUI> {
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Painel de Branding no topo, já adaptado para mobile
            const AuthBrandingPanel(),

            // Área do formulário
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  _buildForm(),

                  const SizedBox(height: 48),

                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 48,
                    runSpacing: 24,
                    children: [
                      Image.asset(
                        'assets/image/lar_global_logo.png',
                        height: 60,
                      ),
                      Image.asset('assets/image/aiesec_logo.png', height: 45),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
