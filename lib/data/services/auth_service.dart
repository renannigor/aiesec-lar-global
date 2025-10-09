import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario/usuario.dart';
import 'usuario_service.dart';
import 'auth_exception.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _usuarioService = UsuarioService.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Função para fazer login com email e senha
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      throw AuthException('Erro não tratado');
    }
  }

  /// Função para cadastrar um novo usuário
  Future<UserCredential> signUp({
    required String nome,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final novoUsuario = Usuario(
          uid: userCredential.user!.uid,
          email: email,
          nome: nome,
          fotoPerfilUrl: '',
          criadoEm: DateTime.now(),
          perfil: 'host',
        );
        await _usuarioService.criarUsuario(usuario: novoUsuario);
        await sendEmailVerification();
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      throw AuthException('Erro não tratado');
    }
  }

  /// Função para enviar (ou reenviar) o e-mail de verificação
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
      } on FirebaseAuthException catch (e) {
        throw AuthException(
          'Erro ao enviar e-mail de verificação: ${e.message}',
        );
      }
    }
  }

  /// Função para fazer logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Função para resetar a senha
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException('Erro ao resetar senha: ${e.message}');
    }
  }

  // Função auxiliar privada para tratar os erros
  void _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      // Casos de SignUp
      case 'weak-password':
        throw AuthException(
          'A senha é muito fraca. Use pelo menos 6 caracteres.',
        );
      case 'email-already-in-use':
        throw AuthException('Este e-mail já está em uso por outra conta.');

      // Casos de SignIn
      case 'user-not-found':
        throw AuthException('Nenhuma conta encontrada com este e-mail.');
      case 'wrong-password':
        throw AuthException('Senha incorreta. Por favor, tente novamente.');
      case 'user-disabled':
        throw AuthException('Esta conta foi desativada.');

      // Caso Comum
      case 'invalid-email':
        throw AuthException('O e-mail fornecido não é válido.');

      // Caso Padrão
      default:
        throw AuthException('Ocorreu um erro inesperado. Tente novamente.');
    }
  }
}
