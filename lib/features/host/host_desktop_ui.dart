import 'package:aiesec_lar_global/core/widgets/custom_header.dart';
import 'package:aiesec_lar_global/data/models/navigation_item.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/services/auth_service.dart';
import 'package:aiesec_lar_global/data/services/usuario_service.dart';
import 'package:aiesec_lar_global/features/host/components/minhas_hospedagens.dart';
import 'package:aiesec_lar_global/features/host/components/perfil.dart';
import 'package:aiesec_lar_global/features/host/components/sobre.dart';
import 'package:flutter/material.dart';

// Importe as telas que serão navegadas

class HostDesktopUI extends StatefulWidget {
  const HostDesktopUI({super.key});

  @override
  State<HostDesktopUI> createState() => _HostDesktopUIState();
}

class _HostDesktopUIState extends State<HostDesktopUI> {
  int _currentIndex = 0;

  // 1. Define os links que aparecerão no cabeçalho
  final List<NavigationItem> _navItems = const [
    NavigationItem(title: 'Hospedagem', index: 0),
    NavigationItem(title: 'Ajuda', index: 1),
  ];

  // 2. Define a lista de telas correspondentes a cada link
  //    (O índice da tela de perfil será navItems.length)
  final List<Widget> _screens = const [
    MinhasHospedagens(), // index 0
    Sobre(), // index 1
    Perfil(), // index 2 (para o botão de perfil)
  ];

  // 3. Função para atualizar a tela exibida
  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Usuario?>(
      // Busca os dados do usuário para obter o nome
      future: UsuarioService.instance.getUsuario(
        uid: AuthService.instance.currentUser!.uid,
      ),
      builder: (context, snapshot) {
        // Enquanto os dados do usuário carregam, mostra um cabeçalho simples
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.white, elevation: 1),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final usuario = snapshot.data!;

        return Scaffold(
          // 4. Usa o cabeçalho customizado, passando os dados e a função de callback
          appBar: CustomHeader(
            navItems: _navItems,
            selectedIndex: _currentIndex,
            onNavigate: _onNavigate,
            userName: usuario.nome,
          ),
          // 5. Exibe a tela correspondente ao índice atual
          body: IndexedStack(index: _currentIndex, children: _screens),
        );
      },
    );
  }
}
