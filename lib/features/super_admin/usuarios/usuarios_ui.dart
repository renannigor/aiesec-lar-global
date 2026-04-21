import 'dart:math';
import 'package:aiesec_lar_global/data/services/collection_references.dart';
import 'package:flutter/material.dart';

// Imports do Projeto
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/services/usuario_service.dart';
import 'package:aiesec_lar_global/data/services/auth_service.dart';

// Imports dos Widgets Locais
import 'components/usuarios_filter.dart';
import 'components/usuarios_table_desktop.dart';
import 'components/usuarios_list_mobile.dart';

class UsuariosUI extends StatefulWidget {
  const UsuariosUI({super.key});

  @override
  State<UsuariosUI> createState() => _UsuariosUIState();
}

class _UsuariosUIState extends State<UsuariosUI> {
  List<ComiteLocal> _comites = [];
  String? _currentUserId;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  // --- Lógica de Paginação Local ---
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _isLoadingComites = true;

  @override
  void initState() {
    super.initState();
    _carregarComites();
  }

  Future<void> _carregarComites() async {
    final user = AuthService.instance.currentUser;
    _currentUserId = user?.uid;

    try {
      final comitesSnapshot = await FirebaseCollections.comitesLocais.get();
      if (mounted) {
        setState(() {
          _comites = comitesSnapshot.docs.map((d) => d.data()).toList();
          _isLoadingComites = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingComites = false);
        SnackbarUtils.showError("Erro ao carregar comitês: $e");
      }
    }
  }

  void _realizarBusca() {
    setState(() {
      _searchTerm = _searchController.text.trim().toLowerCase();
      _currentPage = 1; // Volta para a página 1 ao pesquisar
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Usuario>>(
        stream: UsuarioService.instance.getTodosUsuariosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final todosUsuarios = snapshot.data ?? [];

          // 1. Filtro Local por E-mail ou Nome
          final listaExibida = todosUsuarios.where((u) {
            if (_searchTerm.isEmpty) return true;
            return u.email.toLowerCase().contains(_searchTerm) ||
                u.nome.toLowerCase().contains(_searchTerm);
          }).toList();

          // 2. Cálculos de Paginação
          final totalItems = listaExibida.length;
          final totalPages = (totalItems / _itemsPerPage).ceil();
          final startIndex = (_currentPage - 1) * _itemsPerPage;
          final endIndex = min(startIndex + _itemsPerPage, totalItems);
          final paginatedList = totalItems > 0
              ? listaExibida.sublist(startIndex, endIndex)
              : <Usuario>[];

          return Responsive(
            mobile: _buildLayout(
              isMobile: true,
              paginatedList: paginatedList,
              totalItems: totalItems,
              totalPages: totalPages,
              startIndex: startIndex,
              endIndex: endIndex,
            ),
            tablet: _buildLayout(
              isMobile: false,
              padding: 16,
              paginatedList: paginatedList,
              totalItems: totalItems,
              totalPages: totalPages,
              startIndex: startIndex,
              endIndex: endIndex,
            ),
            desktop: _buildLayout(
              isMobile: false,
              padding: 32,
              paginatedList: paginatedList,
              totalItems: totalItems,
              totalPages: totalPages,
              startIndex: startIndex,
              endIndex: endIndex,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLayout({
    required bool isMobile,
    double padding = 16,
    required List<Usuario> paginatedList,
    required int totalItems,
    required int totalPages,
    required int startIndex,
    required int endIndex,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(totalItems),
          const SizedBox(height: 32),

          UsuariosFilter(
            controller: _searchController,
            onFilter: _realizarBusca,
            isMobile: isMobile,
          ),

          const SizedBox(height: 16),

          if (isMobile)
            UsuariosListMobile(
              usuarios: paginatedList,
              comites: _comites,
              currentUserId: _currentUserId,
              isLoading: _isLoadingComites,
              totalItems: totalItems,
              totalPages: totalPages,
              currentPage: _currentPage,
              startIndex: startIndex,
              endIndex: endIndex,
              onPageChanged: (page) => setState(() => _currentPage = page),
            )
          else
            UsuariosTableDesktop(
              usuarios: paginatedList,
              comites: _comites,
              currentUserId: _currentUserId,
              isLoading: _isLoadingComites,
              totalItems: totalItems,
              totalPages: totalPages,
              currentPage: _currentPage,
              startIndex: startIndex,
              endIndex: endIndex,
              onPageChanged: (page) => setState(() => _currentPage = page),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(int totalItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Usuários do Sistema",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Gerencie acessos e permissões. Total: $totalItems usuários.",
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    );
  }
}
