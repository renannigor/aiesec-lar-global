import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';

class PerfilMobileUI extends StatelessWidget {
  final Usuario usuario;
  final Function(String) onMenuOptionTap;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  const PerfilMobileUI({
    super.key,
    required this.usuario,
    required this.onMenuOptionTap,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // CARD 1: Perfil e Barra de Progresso!
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: usuario.fotoPerfilUrl.isNotEmpty
                        ? Image.network(
                            usuario.fotoPerfilUrl,
                            fit: BoxFit.cover,
                            // Captura falhas (ex: Erro 429) e exibe o ícone
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 45,
                                color: Colors.grey.shade400,
                              );
                            },
                          )
                        : Icon(
                            Icons.person,
                            size: 45,
                            color: Colors.grey.shade400,
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  usuario.nome,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  usuario.email,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 24),

                // BARRA DE PROGRESSO
                _buildProgressBar(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // CARD 2: Menu de Opções (Igual ao seu original)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 16),
                  child: Text(
                    "Informações da Conta",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                _buildMobileMenuOption(
                  "Informações Pessoais",
                  Icons.person_outline,
                  () => onMenuOptionTap("Pessoal"),
                ),
                const SizedBox(height: 12),
                _buildMobileMenuOption(
                  "Endereço",
                  Icons.location_on_outlined,
                  () => onMenuOptionTap("Endereço"),
                ),
                const SizedBox(height: 12),
                _buildMobileMenuOption(
                  "Preferências",
                  Icons.tune,
                  () => onMenuOptionTap("Preferencias"),
                ),
                const SizedBox(height: 12),
                _buildMobileMenuOption(
                  "Detalhes da Casa",
                  Icons.home_outlined,
                  () => onMenuOptionTap("Detalhes"),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 16),
                  child: Text(
                    "CONTA",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                _buildMobileMenuOption(
                  "Sair da Conta",
                  Icons.logout,
                  onLogout,
                  isDestructive: false,
                ),
                const SizedBox(height: 12),
                _buildMobileMenuOption(
                  "Excluir Conta",
                  Icons.delete_outline,
                  onDeleteAccount,
                  isDestructive: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final double progresso = usuario.progressoPreenchimento;
    final int percentual = (progresso * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Seu Perfil",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Text(
              "$percentual%",
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progresso,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        if (progresso < 1.0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Complete 100% para receber contatos!",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileMenuOption(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDestructive ? Colors.red : Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
