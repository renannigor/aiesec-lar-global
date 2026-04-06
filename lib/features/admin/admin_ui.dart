import 'package:flutter/material.dart';

import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/custom_header.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/data/models/navigation_item.dart';
import 'package:aiesec_lar_global/features/shared/perfil/perfil_ui.dart';

import 'package:aiesec_lar_global/features/admin/comite_local/comite_ui.dart';
import 'package:aiesec_lar_global/features/admin/intercambistas/intercambistas_ui.dart';

class AdminUI extends StatefulWidget {
  const AdminUI({super.key});

  @override
  State<AdminUI> createState() => _AdminUIState();
}

class _AdminUIState extends State<AdminUI> {
  int _currentIndex = 0;

  final List<NavigationItem> _navItems = const [
    NavigationItem(title: 'Nossos Intercambistas', index: 0),
    NavigationItem(title: 'Meu Escritório', index: 1),
  ];

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const IntercambistasUI(), // 0
      const ComiteUI(), // 1
      const PerfilUI(), // 2
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomHeader(
        navItems: _navItems,
        selectedIndex: _currentIndex,
        onNavigate: _onNavigate,
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Responsive.isMobile(context)
          ? BottomNavigationBar(
              currentIndex: _currentIndex > 2 ? 0 : _currentIndex,
              onTap: _onNavigate,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.public_outlined),
                  activeIcon: Icon(Icons.public),
                  label: 'EPs',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business_outlined),
                  activeIcon: Icon(Icons.business),
                  label: 'Escritório',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Usuários',
                ),
              ],
            )
          : null,
    );
  }
}
