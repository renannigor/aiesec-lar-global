import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/aplicacao.dart';
import 'collection_references.dart';

class AplicacaoService {
  AplicacaoService._();
  static final instance = AplicacaoService._();

  final _aplicacoesRef = FirebaseCollections.aplicacoes;

  Future<void> criarAplicacao({required Aplicacao aplicacao}) async {
    await _aplicacoesRef.add(aplicacao);
  }

  Future<List<Aplicacao>> getAplicacoesDoHost({required String hostUid}) async {
    final snapshot = await _aplicacoesRef
        .where('hostUid', isEqualTo: hostUid)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> atualizarStatusAplicacao({
    required String aplicacaoId,
    required String novoStatus,
  }) async {
    await _aplicacoesRef.doc(aplicacaoId).update({
      'status': novoStatus,
      'dataUltimaAtualizacao': Timestamp.now(),
    });
  }

  /// DELETAR: Remove o documento da aplicação.
  Future<void> deletarAplicacao({required String aplicacaoId}) async {
    await _aplicacoesRef.doc(aplicacaoId).delete();
  }
}
