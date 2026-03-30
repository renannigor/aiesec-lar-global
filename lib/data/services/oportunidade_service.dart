import 'package:aiesec_lar_global/data/models/oportunidade.dart';
import 'package:flutter/material.dart';

import 'collection_references.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OportunidadeService {
  OportunidadeService._();
  static final instance = OportunidadeService._();

  final _oportunidadesRef = FirebaseCollections.oportunidades;

  Stream<List<Oportunidade>> getOportunidadesStream() {
    return _oportunidadesRef
        .orderBy('organizacao') // Ordena alfabeticamente pela empresa/ONG
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// BUSCAR POR ID: Retorna uma Oportunidade específica usando o opId
  Future<Oportunidade?> getOportunidadePorId(String opId) async {
    try {
      final doc = await _oportunidadesRef.doc(opId).get();
      return doc.data(); // Retorna null se não existir
    } catch (e) {
      debugPrint("Erro ao buscar oportunidade por ID: $e");
      return null;
    }
  }

  /// SALVAR / CRIAR: Usa o opId do Podio como ID do documento no Firebase.
  Future<void> salvarOportunidade({required Oportunidade oportunidade}) async {
    final docId = oportunidade.opId.isNotEmpty
        ? oportunidade.opId
        : _oportunidadesRef.doc().id;

    await _oportunidadesRef
        .doc(docId)
        .set(oportunidade, SetOptions(merge: true));
  }

  /// ATUALIZAR:
  Future<void> atualizarOportunidade({
    required Oportunidade oportunidade,
  }) async {
    await _oportunidadesRef
        .doc(oportunidade.opId)
        .update(oportunidade.toJson());
  }

  /// DELETAR:
  Future<void> deletarOportunidade({required String opId}) async {
    await _oportunidadesRef.doc(opId).delete();
  }
}
