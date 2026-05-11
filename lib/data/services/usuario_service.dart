import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/usuario/usuario.dart';
import 'collection_references.dart';
import 'podio_service.dart';

class UsuarioService {
  UsuarioService._();
  static final instance = UsuarioService._();

  final _usuariosRef = FirebaseCollections.usuarios;

  // Instância do Podio Service para ser usada nas operações
  final _podioService = PodioService();

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

    if (buscaEmail != null && buscaEmail.isNotEmpty) {
      final termo = buscaEmail.toLowerCase();

      query = query
          .orderBy('email')
          .where('email', isGreaterThanOrEqualTo: termo)
          .where('email', isLessThan: '$termo\uf8ff');
    } else {
      query = query.orderBy('nome');
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.limit(limit).get();
    return querySnapshot.docs;
  }

  /// Retorna uma lista de TODOS os usuários para a tabela de gestão
  Stream<List<Usuario>> getTodosUsuariosStream() {
    return _usuariosRef.orderBy('nome').snapshots().map((snapshot) {
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

  Future<Usuario?> getUsuario({required String uid}) async {
    final doc = await _usuariosRef.doc(uid).get();
    return doc.data();
  }

  // ===========================================================================
  // INTEGRAÇÃO COM PODIO NAS AÇÕES DE ESCRITA
  // ===========================================================================

  /// CRIA O USUÁRIO: Salva no Firebase, joga pro Podio e salva o ID retornado.
  Future<void> criarUsuario({required Usuario usuario}) async {
    print('Criando usuário no Firestore: ${usuario.email}');

    // 1. Salva no Firebase primeiro para garantir o acesso rápido do usuário
    await _usuariosRef.doc(usuario.uid).set(usuario);

    // 2. Tenta sincronizar com o Podio em Background
    try {
      final podioId = await _podioService.syncHostNoPodio(usuario);

      // 3. Se o Podio respondeu com sucesso, atualizamos o documento com o ID
      if (podioId != null && podioId.isNotEmpty) {
        await _usuariosRef.doc(usuario.uid).update({'podioItemId': podioId});
        print(
          '[DEBUG SERVICE] Usuário sincronizado no Podio com sucesso. ID: $podioId',
        );
      }
    } catch (e) {
      // Capturamos o erro, mas não damos 'rethrow' para não travar o app do usuário
      // caso o Podio ou a internet do momento falhem.
      print(
        '[DEBUG SERVICE] Aviso: Falha ao enviar usuário para o Podio na criação: $e',
      );
    }
  }

  /// ATUALIZA O USUÁRIO: Modifica no Firebase e, APENAS SE ESTIVER NO PODIO, edita lá também.
  Future<void> atualizarUsuario({required Usuario usuario}) async {
    try {
      print('[DEBUG SERVICE] Preparando para atualizar UID: ${usuario.uid}');

      // 1. Atualiza os dados no Firestore
      final payload = usuario.toJson();
      print('[DEBUG SERVICE] Payload que será enviado ao Firestore: $payload');
      await _usuariosRef.doc(usuario.uid).update(payload);
      print('[DEBUG SERVICE] Documento atualizado no Firestore com sucesso!');

      // 2. Sincroniza com o Podio SOMENTE SE o usuário já possuir um vínculo (ID)
      if (usuario.podioItemId != null && usuario.podioItemId!.isNotEmpty) {
        print(
          '[DEBUG SERVICE] Usuário já está no Podio. Sincronizando alterações...',
        );
        final podioId = await _podioService.syncHostNoPodio(usuario);

        // RECUPERAÇÃO DE FALHAS: Se por algum motivo a API retornar um ID diferente, atualizamos
        if (podioId != null && podioId != usuario.podioItemId) {
          await _usuariosRef.doc(usuario.uid).update({'podioItemId': podioId});
          print(
            '[DEBUG SERVICE] Novo ID do Podio salvo no Firestore durante a atualização: $podioId',
          );
        }
      } else {
        print(
          '[DEBUG SERVICE] Usuário "Fora do CRM". Alterações salvas apenas no Firestore.',
        );
      }
    } catch (e, stackTrace) {
      print('[DEBUG SERVICE] ERRO NO FIRESTORE AO ATUALIZAR: $e');
      print('[DEBUG SERVICE] StackTrace do Firestore: $stackTrace');
      rethrow;
    }
  }

  /// DELETA O USUÁRIO: Apaga do Podio e depois do Firebase.
  Future<void> deletarUsuario({required String uid}) async {
    try {
      // 1. Puxa o usuário para descobrir se ele tem um ID do Podio atrelado
      final user = await getUsuario(uid: uid);

      if (user != null &&
          user.podioItemId != null &&
          user.podioItemId!.isNotEmpty) {
        // 2. Deleta lá no Podio
        await _podioService.deletarHostNoPodio(user.podioItemId!);
        print('[DEBUG SERVICE] Host deletado do Podio com sucesso!');
      }
    } catch (e) {
      print(
        '[DEBUG SERVICE] Aviso: Falha ao deletar o Host no Podio (Talvez ele já tenha sido apagado ou falha na API): $e',
      );
    }

    // 3. Deleta o documento do Firestore permanentemente
    await _usuariosRef.doc(uid).delete();
    print('[DEBUG SERVICE] Host deletado do Firestore!');
  }

  Future<void> deletarUsuarioApenasDoPodio({required String uid}) async {
    try {
      final user = await getUsuario(uid: uid);

      if (user != null &&
          user.podioItemId != null &&
          user.podioItemId!.isNotEmpty) {
        await _podioService.deletarHostNoPodio(user.podioItemId!);

        // Remove o ID do Firestore para o app saber que ele não está mais no CRM
        await _usuariosRef.doc(uid).update({
          'podioItemId': FieldValue.delete(),
        });
        print(
          '[DEBUG SERVICE] Host deletado APENAS do Podio e ID desvinculado.',
        );
      } else {
        throw Exception(
          "Este usuário não possui um ID do Podio vinculado no momento.",
        );
      }
    } catch (e) {
      print('[DEBUG SERVICE] Erro ao tentar deletar apenas do Podio: $e');
      rethrow;
    }
  }
}
