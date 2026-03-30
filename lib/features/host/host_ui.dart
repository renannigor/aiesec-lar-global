import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/custom_header.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/data/models/navigation_item.dart';
import 'package:aiesec_lar_global/features/host/inicio/inicio_ui.dart';
import 'package:aiesec_lar_global/features/host/interesses/interesses_ui.dart';
import 'package:aiesec_lar_global/features/shared/perfil/perfil_ui.dart';

import 'package:aiesec_lar_global/data/services/podio_service.dart';

class HostUI extends StatefulWidget {
  const HostUI({super.key});

  @override
  State<HostUI> createState() => _HostUIState();
}

class _HostUIState extends State<HostUI> {
  int _currentIndex = 0;

  final List<NavigationItem> _navItems = const [
    NavigationItem(title: 'Início', index: 0),
    NavigationItem(title: 'Meus Interesses', index: 1),
  ];

  @override
  void initState() {
    super.initState();
    _verificarESincronizarPodio();
  }

  void _verificarESincronizarPodio() {
    PodioService()
        .sincronizarTudo()
        .then((_) {
          debugPrint("Verificação de sync do Podio no HostUI finalizada.");
        })
        .catchError((e) {
          debugPrint("Erro ao verificar/sincronizar Podio no HostUI: $e");
        });
  }

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      // PASSAMOS A ROTA PARA A TELA DE INTERESSES (INDEX 1) AQUI
      InicioUI(
        onIrParaPerfil: () => _onNavigate(2),
        onIrParaInteresses: () => _onNavigate(1),
      ),
      const InteressesUI(),
      const PerfilUI(),
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
              currentIndex: _currentIndex,
              onTap: _onNavigate,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Interesses',
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
