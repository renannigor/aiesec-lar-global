import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/features/super_admin/comite_local/comites_ui.dart';
import 'package:aiesec_lar_global/features/shared/usuarios/usuarios_ui.dart';
import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/widgets/custom_header.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/data/models/navigation_item.dart';
import 'package:aiesec_lar_global/features/shared/perfil/perfil_ui.dart';

class SuperAdminUI extends StatefulWidget {
  const SuperAdminUI({super.key});

  @override
  State<SuperAdminUI> createState() => _SuperAdminUIState();
}

class _SuperAdminUIState extends State<SuperAdminUI> {
  int _currentIndex = 0;

  // Itens de navegação do Header (Desktop)
  final List<NavigationItem> _navItems = const [
    NavigationItem(title: 'Usuários', index: 0),
    NavigationItem(title: 'Comitês Locais', index: 1),
  ];

  // Função para atualizar a tela exibida
  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lista das telas que serão exibidas
    final List<Widget> screens = [
      const UsuariosUI(), // Index 0: Gestão de Usuários
      const ComitesUI(), // Index 1: Gestão de Comitês
      const PerfilUI(), // Index 2: Perfil (Reutilizando a tela existente)
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      // HEADER (Desktop e Mobile Top Bar)
      appBar: CustomHeader(
        navItems: _navItems,
        selectedIndex: _currentIndex,
        onNavigate: _onNavigate,
      ),

      // CORPO
      body: IndexedStack(index: _currentIndex, children: screens),

      // BOTTOM NAVIGATION (Apenas Mobile)
      bottomNavigationBar: Responsive.isMobile(context)
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onNavigate,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Usuários',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.location_city_outlined),
                  activeIcon: Icon(Icons.location_city),
                  label: 'Comitês',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
            )
          : null,
    );
  }
}
