import 'package:flutter/material.dart';

import '../models/intercambista/intercambista.dart';
import 'collection_references.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IntercambistaService {
  IntercambistaService._();
  static final instance = IntercambistaService._();

  final _intercambistasRef = FirebaseCollections.intercambistas;

  Stream<List<Intercambista>> getIntercambistasStream() {
    return _intercambistasRef
        .orderBy('nome')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Ajuste o status buscado caso no Podio seja diferente (ex: 'Approved', 'Realized')
  Future<List<Intercambista>> getIntercambistasDisponiveis() async {
    final snapshot = await _intercambistasRef
        .where('status', isEqualTo: 'Approved') // Exemplo de status do Podio
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Retorna apenas os EPs que precisam de Host Family em tempo real!
  Stream<List<Intercambista>> getEpsPrecisamHospedagemStream() {
    return _intercambistasRef
        .where('precisaHospedagem', isEqualTo: true)
        .where(
          'status',
          isEqualTo: 'Approved',
        ) // Filtre pelo status que fizer sentido (Approved, Realized, etc)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// BUSCAR POR ID: Retorna um Intercambista específico usando o epId
  Future<Intercambista?> getIntercambistaPorId(String epId) async {
    try {
      final doc = await _intercambistasRef.doc(epId).get();
      return doc.data(); // Retorna null se não existir
    } catch (e) {
      debugPrint("Erro ao buscar intercambista por ID: $e");
      return null;
    }
  }

  /// SALVAR / CRIAR: Usa o epId do Podio como ID do documento no Firebase.
  /// O SetOptions(merge: true) garante que se o EP já existir e tiver
  /// dados manuais (como idade, hobbies), eles não sejam apagados ao sincronizar.
  Future<void> salvarIntercambista({
    required Intercambista intercambista,
  }) async {
    // Se por algum motivo o EP não tiver ID (criado manualmente e não pelo Podio),
    // gera um ID aleatório do Firebase. Caso contrário, usa o do Podio.
    final docId = intercambista.epId.isNotEmpty
        ? intercambista.epId
        : _intercambistasRef.doc().id;

    await _intercambistasRef
        .doc(docId)
        .set(
          intercambista,
          SetOptions(merge: true), // Faz o "Upsert" sem destruir dados manuais
        );
  }

  /// ATUALIZAR: Mesma lógica de usar o epId
  Future<void> atualizarIntercambista({
    required Intercambista intercambista,
  }) async {
    // Como estamos usando withConverter, podemos usar o update passando o toJson()
    await _intercambistasRef
        .doc(intercambista.epId)
        .update(intercambista.toJson());
  }

  /// DELETAR: Remove o documento usando o epId.
  Future<void> deletarIntercambista({required String epId}) async {
    await _intercambistasRef.doc(epId).delete();
  }
}
