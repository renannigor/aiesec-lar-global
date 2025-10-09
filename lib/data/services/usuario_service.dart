import '../models/usuario/usuario.dart';
import 'collection_references.dart';

class UsuarioService {
  UsuarioService._();
  static final instance = UsuarioService._();

  final _usuariosRef = FirebaseCollections.usuarios;

  Future<void> criarUsuario({required Usuario usuario}) async {
    await _usuariosRef.doc(usuario.uid).set(usuario);
  }

  Future<Usuario?> getUsuario({required String uid}) async {
    final doc = await _usuariosRef.doc(uid).get();
    return doc.data();
  }

  Future<void> atualizarUsuario({required Usuario usuario}) async {
    await _usuariosRef.doc(usuario.uid).update(usuario.toJson());
  }

  /// DELETAR: Remove o documento do usuário do Firestore.
  Future<void> deletarUsuario({required String uid}) async {
    await _usuariosRef.doc(uid).delete();
  }
}
