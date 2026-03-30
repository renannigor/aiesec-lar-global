import 'package:flutter/material.dart';

// Imports Core/Shared
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/custom_header.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/data/models/navigation_item.dart';
import 'package:aiesec_lar_global/features/shared/perfil/perfil_ui.dart';

// Imports das Telas do Admin
// (Certifique-se de criar esses arquivos ou ajustar os caminhos)
import 'package:aiesec_lar_global/features/admin/comite_local/comite_ui.dart';
import 'package:aiesec_lar_global/features/admin/intercambistas/intercambistas_ui.dart';

class AdminUI extends StatefulWidget {
  const AdminUI({super.key});

  @override
  State<AdminUI> createState() => _AdminUIState();
}

class _AdminUIState extends State<AdminUI> {
  int _currentIndex = 0;

  // Itens de navegação do Header (Desktop)
  // O Perfil geralmente fica no menu do avatar, não nas abas principais do desktop
  final List<NavigationItem> _navItems = const [
    NavigationItem(title: 'Meu Comitê', index: 0),
    NavigationItem(title: 'Intercambistas', index: 1),
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
      const ComiteUI(), // Index 0: Gestão do Comitê Local
      const IntercambistasUI(), // Index 1: Gestão de Intercambistas
      const PerfilUI(), // Index 2: Perfil (Compartilhado)
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      // HEADER (Desktop e Mobile Top Bar)
      appBar: CustomHeader(
        navItems: _navItems,
        selectedIndex: _currentIndex,
        onNavigate: _onNavigate,
      ),

      // CORPO (Mantém o estado das telas)
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
                  icon: Icon(Icons.business_outlined),
                  activeIcon: Icon(Icons.business),
                  label: 'Comitê',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.public_outlined), // ou flight_takeoff
                  activeIcon: Icon(Icons.public),
                  label: 'Intercambistas',
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
