import 'package:aiesec_lar_global/data/models/acesso_usuario.dart';
import 'collection_references.dart';

class AcessoService {
  AcessoService._();
  static final instance = AcessoService._();

  // Usa a referência tipada que você criou no FirebaseCollections
  final _acessosRef = FirebaseCollections.acessos;

  /// Retorna o nível de acesso do usuário em tempo real.
  /// É usado no AuthGate para redirecionar para a tela correta.
  Stream<AcessoUsuario?> getAcessoStream({required String uid}) {
    return _acessosRef.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null; // Se não tem documento, significa que é um Host comum.
    });
  }

  /// Busca o acesso do usuário apenas uma vez (sem ficar escutando).
  Future<AcessoUsuario?> getAcesso({required String uid}) async {
    final doc = await _acessosRef.doc(uid).get();
    return doc.data();
  }

  /// Usado pelo SuperAdmin para conceder acesso de Admin a alguém.
  Future<void> definirAcesso({required AcessoUsuario acesso}) async {
    await _acessosRef.doc(acesso.uid).set(acesso);
  }

  /// Usado pelo SuperAdmin para rebaixar um Admin de volta para Host.
  Future<void> removerAcesso({required String uid}) async {
    await _acessosRef.doc(uid).delete();
  }
}
