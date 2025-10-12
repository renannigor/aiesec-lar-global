import 'package:aiesec_lar_global/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/form_validators.dart';

class SignInForm extends StatefulWidget {
  final VoidCallback onSwitchToSignUp;
  final VoidCallback onForgotPassword;

  const SignInForm({
    super.key,
    required this.onSwitchToSignUp,
    required this.onForgotPassword,
  });

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Chama o método de login do provider
      context.read<AuthProvider>().signIn(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acesse sua conta',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: widget.onSwitchToSignUp,
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(text: 'Ainda não tem uma conta? '),
                    TextSpan(
                      text: 'Cadastre-se',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => context.read<AuthProvider>().signInWithGoogle(),
              icon: Image.asset('assets/image/google_logo.png', height: 20),
              label: const Text('Sign in with Google'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'OU',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),

            Editor(
              controller: _emailController,
              labelText: 'Email',
              isPassword: false,
              keyboardType: TextInputType.emailAddress,
              enabled: true,
              validator: FormValidators.email,
            ),
            const SizedBox(height: 16),
            Editor(
              controller: _senhaController,
              labelText: 'Senha',
              isPassword: true,
              keyboardType: TextInputType.text,
              enabled: true,
              validator: FormValidators.password,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onForgotPassword,
                child: const Text('Esqueceu sua senha?'),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Entrar',
                style: TextStyle(color: AppColors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
