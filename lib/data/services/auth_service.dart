import 'package:aiesec_lar_global/data/models/perfil_usuario.dart';
import 'package:aiesec_lar_global/data/models/endereco.dart';
import 'package:aiesec_lar_global/data/services/acesso_service.dart';
import 'package:aiesec_lar_global/data/services/aplicacao_service.dart';
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
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Stream<Usuario?> get usuarioLogado {
    return authStateChanges.asyncMap((user) async {
      if (user == null) {
        return null;
      }
      return await _usuarioService.getUsuario(uid: user.uid);
    });
  }

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
    } catch (e) {
      throw AuthException('Erro inesperado ao fazer login: $e');
    }
  }

  Future<UserCredential> signUp({
    required String nome,
    required String email,
    required String telefone,
    required String password,
    required String cep,
    required String logradouro,
    required String numero,
    required String bairro,
    required String cidade,
    required String estado,
    required String comiteLocal,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print(
        'Usuário criado na Autenticação com UID: ${userCredential.user?.uid}',
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
          telefone: telefone,
          nome: nome,
          fotoPerfilUrl: '',
          criadoEm: DateTime.now(),
          perfil: PerfilUsuario.host,
          endereco: endereco,
          aiesecMaisProxima: comiteLocal,
        );

        // 1. A MÁGICA: Força o Auth a baixar um token novo e sincronizar com o Firestore!
        await userCredential.user!.getIdToken(true);
        await Future.delayed(
          const Duration(milliseconds: 800),
        ); // Um respiro extra pro Web Socket

        // 2. TIMEOUT: Tenta salvar, se passar de 10 segundos, cancela e joga o erro!
        await _usuarioService
            .criarUsuario(usuario: novoUsuario)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception(
                  "O banco de dados demorou muito para responder.",
                );
              },
            );

        await sendEmailVerification();
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      throw AuthException('Erro não tratado');
    } catch (e) {
      print('Erro ao salvar no banco de dados: $e');
      throw AuthException('Falha ao gravar os dados. Tente novamente.');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        await _googleSignIn.signOut();
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          throw AuthException('O login com o Google foi cancelado.');
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

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

        // Força a sincronização do token para contas Google novas também
        await userCredential.user!.getIdToken(true);
        await Future.delayed(const Duration(milliseconds: 800));

        await _usuarioService
            .criarUsuario(usuario: novoUsuario)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw Exception("Timeout"),
            );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      throw AuthException('Erro não tratado no login com Google');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

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

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException('Erro ao resetar senha: ${e.message}');
    }
  }

  // --- EXCLUIR CONTA E DADOS ---
  Future<void> excluirConta() async {
    final user = _auth.currentUser;
    if (user == null) throw AuthException('Nenhum usuário autenticado.');

    final String uid = user.uid;

    try {
      // Passo 1: Buscar e deletar todas as aplicações associadas ao Host
      final aplicacoes = await AplicacaoService.instance.getAplicacoesDoHost(
        hostUid: uid,
      );
      for (var app in aplicacoes) {
        await AplicacaoService.instance.deletarAplicacao(
          aplicacaoId: app.aplicacaoId,
        );
      }

      // Passo 2: Remover privilégios de acesso (Admin/Superadmin) se existirem
      await AcessoService.instance.removerAcesso(uid: uid);

      // Passo 3: Deletar o perfil principal da coleção 'usuarios'
      await UsuarioService.instance.deletarUsuario(uid: uid);

      // Passo 4: Deletar a conta da Autenticação do Firebase
      await user.delete();

      // Passo 5: Fazer o logout local dos provedores
      await _googleSignIn.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw AuthException(
          'Por motivos de segurança, você precisa sair e fazer login novamente para excluir sua conta.',
        );
      }
      _handleAuthException(e);
      throw AuthException('Erro não tratado ao tentar excluir a conta.');
    } catch (e) {
      throw AuthException('Erro inesperado ao excluir os dados: $e');
    }
  }

  void _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        throw AuthException(
          'A senha é muito fraca. Use pelo menos 6 caracteres.',
        );
      case 'email-already-in-use':
        throw AuthException('Este e-mail já está em uso por outra conta.');
      case 'invalid-credential':
        throw AuthException('E-mail ou senha inválidos.');
      case 'wrong-password':
        throw AuthException('Senha incorreta. Por favor, tente novamente.');
      case 'user-disabled':
        throw AuthException('Esta conta foi desativada.');
      case 'invalid-email':
        throw AuthException('O e-mail fornecido não é válido.');
      default:
        throw AuthException('Ocorreu um erro inesperado. Tente novamente.');
    }
  }
}
