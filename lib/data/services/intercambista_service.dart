import '../models/intercambista/intercambista.dart';
import 'collection_references.dart';

class IntercambistaService {
  IntercambistaService._();
  static final instance = IntercambistaService._();

  final _intercambistasRef = FirebaseCollections.intercambistas;

  Future<List<Intercambista>> getIntercambistasDisponiveis() async {
    final snapshot = await _intercambistasRef
        .where('status', isEqualTo: 'disponivel')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> criarIntercambista({
    required Intercambista intercambista,
  }) async {
    await _intercambistasRef.add(intercambista);
  }

  Future<void> atualizarIntercambista({
    required Intercambista intercambista,
  }) async {
    await _intercambistasRef
        .doc(intercambista.intercambistaId)
        .update(intercambista.toJson());
  }

  /// DELETAR: Remove o documento do intercambista.
  Future<void> deletarIntercambista({required String intercambistaId}) async {
    await _intercambistasRef.doc(intercambistaId).delete();
  }
}
