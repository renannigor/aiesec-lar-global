import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comite_local/comite_local.dart';
import '../models/comite_local/testemunha.dart';
import 'collection_references.dart';

class ComiteLocalService {
  ComiteLocalService._();
  static final instance = ComiteLocalService._();

  final _comitesRef = FirebaseCollections.comitesLocais;

  /// READ (Stream): Retorna a lista de comitês em tempo real para o Grid
  Stream<List<ComiteLocal>> getComitesStream() {
    return _comitesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
  
  Future<void> adicionarComiteLocal({required ComiteLocal comite}) async {
    await _comitesRef.add(comite);
  }

  Future<ComiteLocal?> getComiteLocal({required String comiteId}) async {
    final doc = await _comitesRef.doc(comiteId).get();
    return doc.data();
  }

  Future<void> atualizarComiteLocal({required ComiteLocal comite}) async {
    await _comitesRef.doc(comite.comiteId).update(comite.toJson());
  }

  Future<void> adicionarTestemunha({
    required String comiteId,
    required Testemunha novaTestemunha,
  }) async {
    await _comitesRef.doc(comiteId).update({
      'testemunhas': FieldValue.arrayUnion([novaTestemunha.toJson()]),
    });
  }

  Future<void> removerTestemunha({
    required String comiteId,
    required Testemunha testemunhaParaRemover,
  }) async {
    await _comitesRef.doc(comiteId).update({
      'testemunhas': FieldValue.arrayRemove([testemunhaParaRemover.toJson()]),
    });
  }

  /// DELETAR: Remove o documento do comitê local.
  Future<void> deletarComiteLocal({required String comiteId}) async {
    await _comitesRef.doc(comiteId).delete();
  }
}
