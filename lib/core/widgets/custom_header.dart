import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/navigation_item.dart';
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final List<NavigationItem> navItems;
  final int selectedIndex;
  final Function(int) onNavigate;
  final String userName;

  const CustomHeader({
    super.key,
    required this.navItems,
    required this.selectedIndex,
    required this.onNavigate,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        // <<< ALTERAÇÃO: Logo aumentada para dar mais destaque
        child: Image.asset('assets/image/lar_global_logo.png', height: 45),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              // Cria os botões de navegação a partir da lista
              ...navItems.map(
                (item) => _buildNavButton(text: item.title, index: item.index),
              ),
              const SizedBox(width: 24),
              // Botão de perfil separado
              _buildProfileButton(index: navItems.length),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton({required String text, required int index}) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextButton(
        onPressed: () => onNavigate(index),
        child: Text(
          text,
          style: TextStyle(
            // <<< ALTERAÇÃO: Cor não selecionada agora é a primária de texto
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton({required int index}) {
    final isSelected = selectedIndex == index;
    return TextButton(
      onPressed: () => onNavigate(index),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: const StadiumBorder(),
        backgroundColor: isSelected ? AppColors.primary.withAlpha(25) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Text(
              userName.split(' ').first,
              style: const TextStyle(
                // <<< ALTERAÇÃO: Cor do nome para a primária de texto
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

