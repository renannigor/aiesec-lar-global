import 'package:aiesec_lar_global/data/services/collection_references.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Imports do Projeto
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:aiesec_lar_global/core/widgets/responsive.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';
import 'package:aiesec_lar_global/data/services/usuario_service.dart';
import 'package:aiesec_lar_global/data/services/auth_service.dart';

// Imports dos Widgets Locais Refatorados
import 'widgets/usuarios_filter.dart';
import 'widgets/usuarios_table_desktop.dart';
import 'widgets/usuarios_list_mobile.dart';

class UsuariosUI extends StatefulWidget {
  const UsuariosUI({super.key});

  @override
  State<UsuariosUI> createState() => _UsuariosUIState();
}

class _UsuariosUIState extends State<UsuariosUI> {
  // --- Estados ---
  final List<Usuario> _usuarios = [];
  List<ComiteLocal> _comites = [];
  String? _currentUserId;
  final TextEditingController _searchController = TextEditingController();

  // Paginação
  final int _usersPerPage = 20;
  DocumentSnapshot? _lastDocument;
  int _totalUsers = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _searchTerm;

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    setState(() => _isLoading = true);
    
    // Captura o ID do usuário atual
    final user = AuthService.instance.currentUser;
    _currentUserId = user?.uid;

    try {
      // Usando FirebaseCollections para carregar os comitês
      final comitesSnapshot = await FirebaseCollections.comitesLocais.get();
      _comites = comitesSnapshot.docs.map((d) => d.data()).toList();

      _totalUsers = await UsuarioService.instance.getTotalUsuarios();

      await _buscarUsuarios(reset: true);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarUtils.showError("Erro ao carregar dados: $e");
      }
    }
  }

  Future<void> _buscarUsuarios({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _lastDocument = null;
        _usuarios.clear();
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final docs = await UsuarioService.instance.getUsuariosPaginados(
        limit: _usersPerPage,
        startAfter: _lastDocument,
        buscaEmail: _searchTerm,
      );

      setState(() {
        final novosUsuarios = docs.map((d) => d.data()).toList();
        _usuarios.addAll(novosUsuarios);
        if (docs.isNotEmpty) _lastDocument = docs.last;

        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      if (mounted) SnackbarUtils.showError("Erro ao buscar: $e");
    }
  }

  void _realizarBusca() {
    setState(() => _searchTerm = _searchController.text.trim());
    _buscarUsuarios(reset: true);
  }

  void _atualizarUsuarioNaLista(Usuario usuarioAtualizado) {
    setState(() {
      final index =
          _usuarios.indexWhere((u) => u.uid == usuarioAtualizado.uid);
      if (index != -1) _usuarios[index] = usuarioAtualizado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Responsive(
        mobile: _buildLayout(isMobile: true),
        tablet: _buildLayout(isMobile: false, padding: 16),
        desktop: _buildLayout(isMobile: false, padding: 32),
      ),
    );
  }

  Widget _buildLayout({required bool isMobile, double padding = 16}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),

          UsuariosFilter(
            controller: _searchController,
            onFilter: _realizarBusca,
            isMobile: isMobile,
          ),

          const SizedBox(height: 16),

          if (isMobile)
            UsuariosListMobile(
              usuarios: _usuarios,
              comites: _comites,
              currentUserId: _currentUserId,
              isLoading: _isLoading,
              onUpdateUser: _atualizarUsuarioNaLista,
              loadMoreButton: _buildLoadMoreButton(),
            )
          else
            UsuariosTableDesktop(
              usuarios: _usuarios,
              comites: _comites,
              currentUserId: _currentUserId,
              isLoading: _isLoading,
              onUpdateUser: _atualizarUsuarioNaLista,
              loadMoreButton: _buildLoadMoreButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          "Gerencie acessos, permissões e vínculos.",
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildLoadMoreButton() {
    if (_usuarios.isEmpty) return const SizedBox();

    if (_usuarios.length >= _totalUsers && _totalUsers > 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Text(
          "Todos os $_totalUsers usuários carregados.",
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        color: Colors.white,
      ),
      child: Center(
        child: _isLoadingMore
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton.icon(
                onPressed: () => _buscarUsuarios(reset: false),
                icon: const Icon(Icons.expand_more, color: AppColors.primary),
                label: const Text(
                  "Carregar mais usuários",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}