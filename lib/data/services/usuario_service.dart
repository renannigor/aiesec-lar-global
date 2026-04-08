import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/usuario/usuario.dart';
import 'collection_references.dart';

class UsuarioService {
  UsuarioService._();
  static final instance = UsuarioService._();

  final _usuariosRef = FirebaseCollections.usuarios;

  Future<int> getTotalUsuarios() async {
    final countQuery = await _usuariosRef.count().get();
    return countQuery.count ?? 0;
  }

  /// Busca paginada com Filtro por EMAIL
  Future<List<QueryDocumentSnapshot<Usuario>>> getUsuariosPaginados({
    required int limit,
    DocumentSnapshot? startAfter,
    String? buscaEmail,
  }) async {
    Query<Usuario> query = _usuariosRef;

    // LÓGICA DE FILTRO POR EMAIL
    if (buscaEmail != null && buscaEmail.isNotEmpty) {
      // Importante: Firestore é case-sensitive.
      // O ideal é salvar emails sempre minúsculos no banco e buscar minúsculo aqui.
      final termo = buscaEmail.toLowerCase();

      query = query
          .orderBy('email') // Ordenação primária deve ser o campo do filtro
          .where('email', isGreaterThanOrEqualTo: termo)
          .where('email', isLessThan: '$termo\uf8ff');
    } else {
      // Ordenação padrão por nome se não houver busca
      query = query.orderBy('nome');
    }

    // Paginação
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.limit(limit).get();
    return querySnapshot.docs;
  }

  /// Retorna uma lista de TODOS os usuários para a tabela de gestão
  Stream<List<Usuario>> getTodosUsuariosStream() {
    return _usuariosRef
        .orderBy('nome') // Opcional: ordenar por nome
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  Stream<Usuario?> getUsuarioStream({required String uid}) {
    return _usuariosRef.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  Future<void> criarUsuario({required Usuario usuario}) async {
    print('Criando usuário no Firestore: ${usuario.email}');
    await _usuariosRef.doc(usuario.uid).set(usuario);
  }

  Future<Usuario?> getUsuario({required String uid}) async {
    final doc = await _usuariosRef.doc(uid).get();
    return doc.data();
  }

  // --- ATUALIZAR USUÁRIO COM PRINTS DE DEBUG ---
  Future<void> atualizarUsuario({required Usuario usuario}) async {
    try {
      print('[DEBUG SERVICE] Preparando para atualizar UID: ${usuario.uid}');

      final payload = usuario.toJson();
      print('[DEBUG SERVICE] Payload que será enviado ao Firestore: $payload');

      await _usuariosRef.doc(usuario.uid).update(payload);

      print('[DEBUG SERVICE] Documento atualizado no Firestore com sucesso!');
    } catch (e, stackTrace) {
      print('[DEBUG SERVICE] ERRO NO FIRESTORE AO ATUALIZAR: $e');
      print('[DEBUG SERVICE] StackTrace do Firestore: $stackTrace');
      rethrow;
    }
  }

  /// DELETAR: Remove o documento do usuário do Firestore.
  Future<void> deletarUsuario({required String uid}) async {
    await _usuariosRef.doc(uid).delete();
  }
}
