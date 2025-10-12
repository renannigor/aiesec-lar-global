import 'package:aiesec_lar_global/data/models/perfil_usuario.dart';
import 'package:aiesec_lar_global/data/models/usuario/endereco.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  /// Stream que emite nosso próprio model `Usuario` quando o auth muda.
  Stream<Usuario?> get usuarioLogado {
    return authStateChanges.asyncMap((user) async {
      if (user == null) {
        return null; // Se não há usuário no Auth, emitimos null.
      }
      // Se há usuário no Auth, buscamos nosso perfil no Firestore.
      return await _usuarioService.getUsuario(uid: user.uid);
    });
  }

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
    required String cep,
    required String logradouro,
    required String numero,
    required String bairro,
    required String cidade,
    required String estado,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final endereco = Endereco(
          logradouro: logradouro,
          numero: numero,
          bairro: bairro,
          cep: cep,
          cidade: cidade,
          estado: estado,
        );

        final novoUsuario = Usuario(
          uid: userCredential.user!.uid,
          email: email,
          nome: nome,
          fotoPerfilUrl: '',
          criadoEm: DateTime.now(),
          perfil: PerfilUsuario.host,
          endereco: endereco,
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

  /// Função para fazer login com o Google.
  Future<UserCredential> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // A lógica para a Web continua a mesma.
        final googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Lógica simplificada para a versão 6.x do pacote

        final GoogleSignIn googleSignIn = GoogleSignIn();

        // Desloga qualquer usuário do Google que possa estar em cache no app.
        await googleSignIn.signOut();

        // Inicia o fluxo de login do Google.
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          throw AuthException('O login com o Google foi cancelado.');
        }

        // Obtém os tokens de autenticação.
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Cria a credencial do Firebase com os tokens.
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Faz o login no Firebase com a credencial.
        userCredential = await _auth.signInWithCredential(credential);
      }

      // Após o login, verifica se é um usuário novo
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        final user = userCredential.user!;
        final novoUsuario = Usuario(
          uid: user.uid,
          email: user.email!,
          nome: user.displayName ?? 'Usuário',
          fotoPerfilUrl: user.photoURL ?? '',
          criadoEm: DateTime.now(),
          perfil: PerfilUsuario.host,
        );
        await _usuarioService.criarUsuario(usuario: novoUsuario);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      throw AuthException('Erro não tratado no login com Google');
    } catch (e) {
      throw AuthException(e.toString());
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
    // Primeiro, faz o logout da conta Google para limpar o cache
    await GoogleSignIn().signOut();

    // Depois, faz o logout do Firebase, o que vai disparar a atualização da UI
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
      case 'invalid-credential':
        throw AuthException('E-mail ou senha inválidos.');
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
