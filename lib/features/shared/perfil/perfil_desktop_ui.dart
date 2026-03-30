import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';

class PerfilDesktopUI extends StatelessWidget {
  final Usuario usuario;
  final String secaoSelecionada;
  final Function(String) onSecaoChanged;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  final VoidCallback onSave;
  final Widget formChild;
  final String tituloSecao;
  final String subtituloSecao;

  const PerfilDesktopUI({
    super.key,
    required this.usuario,
    required this.secaoSelecionada,
    required this.onSecaoChanged,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.onSave,
    required this.formChild,
    required this.tituloSecao,
    required this.subtituloSecao,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 280,
                child: Column(
                  children: [
                    _buildSidebarUserInfo(),
                    const SizedBox(height: 24),
                    _buildSidebarMenu(),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(child: _buildContentCard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarUserInfo() {
    final double progresso = usuario.progressoPreenchimento;
    final int percentual = (progresso * 100).round();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: usuario.fotoPerfilUrl.isNotEmpty
                ? NetworkImage(usuario.fotoPerfilUrl)
                : null,
            child: usuario.fotoPerfilUrl.isEmpty
                ? Icon(Icons.person, size: 40, color: Colors.grey.shade400)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            usuario.nome,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            usuario.email,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),
          // BARRA DE PROGRESSO NO DESKTOP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Preenchimento",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                "$percentual%",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarMenu() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebarItem("Perfil", Icons.person_outline, "Pessoal"),
          _buildSidebarItem("Endereço", Icons.location_on_outlined, "Endereço"),
          _buildSidebarItem("Preferências", Icons.tune, "Preferencias"),
          _buildSidebarItem(
            "Detalhes da Casa",
            Icons.home_outlined,
            "Detalhes",
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              "CONTA",
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          _buildSidebarItem(
            "Sair",
            Icons.logout,
            "Sair",
            isDestructive: false,
            onTap: onLogout,
          ),
          _buildSidebarItem(
            "Excluir",
            Icons.delete_outline,
            "Excluir",
            isDestructive: true,
            onTap: onDeleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    String title,
    IconData icon,
    String key, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final isSelected = secaoSelecionada == key;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => onSecaoChanged(key),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: isSelected
                ? Border(left: BorderSide(color: AppColors.primary, width: 4))
                : null,
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.05)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? Colors.red
                    : (isSelected ? AppColors.primary : Colors.grey.shade600),
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isDestructive
                      ? Colors.red
                      : (isSelected ? AppColors.primary : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tituloSecao,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtituloSecao,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save, size: 18),
                label: const Text("Salvar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 32),
          Expanded(child: SingleChildScrollView(child: formChild)),
        ],
      ),
    );
  }
}
