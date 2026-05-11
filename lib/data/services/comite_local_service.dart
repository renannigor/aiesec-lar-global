import '../models/comite_local.dart';
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

  Future<ComiteLocal?> getComitePorNomePodio(String nomePodio) async {
    final query = await _comitesRef
        .where('nome_podio', isEqualTo: nomePodio)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first.data();
  }

  Future<void> atualizarComiteLocal({required ComiteLocal comite}) async {
    await _comitesRef.doc(comite.comiteId).update(comite.toJson());
  }

  /// DELETAR: Remove o documento do comitê local.
  Future<void> deletarComiteLocal({required String comiteId}) async {
    await _comitesRef.doc(comiteId).delete();
  }
}
