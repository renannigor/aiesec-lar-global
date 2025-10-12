import 'dart:async';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/services/auth_service.dart';
import 'package:provider/provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _canResendEmail = false;
  int _cooldownTime = 60;
  Timer? _verificationTimer;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    // Atualiza os dados do usuário a partir do servidor
    await user.reload();

    // Pega a instância mais recente após o reload
    final freshUser = AuthService.instance.currentUser;

    // Se a instância atualizada estiver com o e-mail verificado
    if (freshUser != null && freshUser.emailVerified) {
      _verificationTimer?.cancel(); // Para o timer de verificação

      // Mostra uma mensagem de sucesso
      SnackbarUtils.showSuccess(
        'E-mail verificado com sucesso! Por favor, faça o login.',
      );

      // Faz o logout para forçar o usuário a logar novamente
      if (mounted) {
        await context.read<AuthProvider>().signOut();
      }
    }
  }

  void _startCooldownTimer() {
    setState(() => _canResendEmail = false);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_cooldownTime == 0) {
        _cooldownTimer?.cancel();
        _cooldownTime = 60;
        if (mounted) setState(() => _canResendEmail = true);
      } else {
        if (mounted) setState(() => _cooldownTime--);
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    try {
      await AuthService.instance.sendEmailVerification();
      SnackbarUtils.showSuccess('Um novo e-mail de verificação foi enviado.');
      _startCooldownTimer();
    } catch (e) {
      SnackbarUtils.showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService.instance.currentUser?.email ?? 'seu e--mail';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Card central
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(40.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícone
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primary.withAlpha(25),
                      child: const Icon(
                        Icons.mail_outline_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Título
                    const Text(
                      'Verifique seu endereço de e-mail',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Texto descritivo
                    Text(
                      'Para começar a usar sua conta Lar Global, você precisa confirmar seu endereço de e-mail. Enviamos um link de confirmação para:\n$userEmail',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botão principal
                    ElevatedButton(
                      onPressed: _canResendEmail
                          ? _resendVerificationEmail
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _canResendEmail
                            ? 'Reenviar E-mail de Verificação'
                            : 'Aguarde ($_cooldownTime s)',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Divider(),
                    const SizedBox(height: 24),

                    // Botão secundário
                    OutlinedButton(
                      onPressed: () => AuthService.instance.signOut(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text('Cancelar e Sair'),
                    ),
                  ],
                ),
              ),

              // Logos
              Padding(
                padding: const EdgeInsets.only(top: 48.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/image/lar_global_logo.png', height: 60),
                    const SizedBox(width: 48),
                    Image.asset('assets/image/aiesec_logo.png', height: 45),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
