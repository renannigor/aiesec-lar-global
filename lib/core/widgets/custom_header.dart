import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/data/models/navigation_item.dart';
import 'package:aiesec_lar_global/providers/auth_provider.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final List<NavigationItem> navItems;
  final int selectedIndex;
  final Function(int) onNavigate;

  const CustomHeader({
    super.key,
    required this.navItems,
    required this.selectedIndex,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.grey[200], height: 1),
      ),
      title: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. ÁREA DAS LOGOS (Esquerda)
                _buildLogos(isMobile),

                // 2. BOTÃO DE MENU TIPO "PÍLULA" (Direita)
                _buildUserMenu(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogos(bool isMobile) {
    return Row(
      children: [
        Image.asset(
          'assets/image/aiesec_logo.png',
          height: isMobile ? 30 : 40,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 16),
        // Linha divisória combinando com o tom cinza claro do resto do cabeçalho
        Container(
          width: 1,
          height: isMobile ? 24 : 35,
          color: Colors.grey[200],
        ),
        const SizedBox(width: 16),
        Image.asset(
          'assets/image/lar_global_logo.png',
          height: isMobile ? 35 : 45,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      tooltip: 'Menu do usuário',
      elevation: 4,
      onSelected: (value) async {
        if (value == 'inicio') onNavigate(0);
        if (value == 'interesses') onNavigate(1);
        if (value == 'perfil') onNavigate(2);
        if (value == 'logout') {
          final sair = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text(
                "Sair da conta",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text("Deseja realmente sair do sistema?"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    "Sair",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );

          if (sair == true && context.mounted) {
            await context.read<AuthProvider>().signOut();
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          // Borda fina (width: 1) e exatamente na mesma cor da linha debaixo do cabeçalho
          border: Border.all(color: Colors.grey.shade200, width: 1),
          borderRadius: BorderRadius.circular(30),
          // Sombra removida para o visual flat!
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu, color: Colors.grey.shade700, size: 20),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 18, color: AppColors.primary),
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => [
        _buildMenuItem(
          'inicio',
          Icons.home_outlined,
          'Início',
          selectedIndex == 0,
        ),
        _buildMenuItem(
          'interesses',
          Icons.favorite_border,
          'Meus Interesses',
          selectedIndex == 1,
        ),
        _buildMenuItem(
          'perfil',
          Icons.person_outline,
          'Meu Perfil',
          selectedIndex == 2,
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          'logout',
          Icons.logout,
          'Sair',
          false,
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text,
    bool isSelected, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive
                ? Colors.red
                : (isSelected ? AppColors.primary : Colors.grey.shade700),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isDestructive
                  ? Colors.red
                  : (isSelected ? AppColors.primary : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
