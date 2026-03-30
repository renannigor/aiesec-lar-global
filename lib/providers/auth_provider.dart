import 'package:aiesec_lar_global/core/utils/snackbar.dart';
import 'package:flutter/foundation.dart';
import '../data/services/auth_exception.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Método para Login
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true; // Sucesso
    } on AuthException catch (e) {
      // Em caso de erro, usamos o SnackbarUtils
      SnackbarUtils.showError(e.message);
      _isLoading = false;
      notifyListeners();
      return false; // Falha
    }
  }

  // Método para Cadastro
  Future<bool> signUp({
    required String nome,
    required String email,
    required String telefone,
    required String password,
    required String cep,
    required String logradouro,
    required String numero,
    required String bairro,
    required String estado,
    required String cidade,
    required String comiteLocal,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signUp(
        nome: nome,
        email: email,
        telefone: telefone,
        password: password,
        cep: cep,
        logradouro: logradouro,
        numero: numero,
        bairro: bairro,
        cidade: cidade,
        estado: estado,
        comiteLocal: comiteLocal,
      );
      SnackbarUtils.showSuccess('Cadastro realizado! Verifique seu e-mail.');
      _isLoading = false;
      notifyListeners();
      return true; // Sucesso
    } on AuthException catch (e) {
      SnackbarUtils.showError(e.message);
      _isLoading = false;
      print('Erro no cadastro: ${e.message}');
      notifyListeners();
      return false; // Falha
    } catch (e) {
      // CAPTURA DE ERRO GENÉRICO (Evita congelamento da tela)
      SnackbarUtils.showError('Erro inesperado ao cadastrar. Tente novamente.');
      _isLoading = false;
      print('Erro inesperado no cadastro: $e');
      notifyListeners();
      return false;
    }
  }

  /// Método para Login com Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return true; // Sucesso
    } on AuthException catch (e) {
      SnackbarUtils.showError(e.message);
      _isLoading = false;
      notifyListeners();
      return false; // Falha
    }
  }

  // Método para Logout
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      SnackbarUtils.showError('Ocorreu um erro ao tentar desconectar.');
    }
  }

  // Método para Resetar a Senha
  Future<bool> resetPassword({required String email}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.resetPassword(email: email);
      SnackbarUtils.showSuccess(
        'Link de redefinição enviado para o seu e-mail!',
      );
      _isLoading = false;
      notifyListeners();
      return true; // Sucesso
    } on AuthException catch (e) {
      SnackbarUtils.showError(e.message);
      _isLoading = false;
      notifyListeners();
      return false; // Falha
    }
  }
}
