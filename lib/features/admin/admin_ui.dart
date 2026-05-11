import 'package:aiesec_lar_global/features/admin/dashboard/dashboard_ui.dart';
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
    NavigationItem(title: 'Dashboard', index: 0),
    NavigationItem(title: 'Nossos Intercambistas', index: 1),
    NavigationItem(title: 'Meu Escritório', index: 2),
  ];

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const DashboardUI(), // 0
      const IntercambistasUI(), // 1
      const ComiteUI(), // 2
      const PerfilUI(), // 3
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
              currentIndex: _currentIndex > 3 ? 0 : _currentIndex,
              onTap: _onNavigate,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
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
