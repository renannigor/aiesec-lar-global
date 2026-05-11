import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // NOVO IMPORT PARA LER O AUTH

import '../models/aplicacao.dart';
import 'collection_references.dart';

class AplicacaoService {
  AplicacaoService._();
  static final instance = AplicacaoService._();

  final _aplicacoesRef = FirebaseCollections.aplicacoes;

  /// CRIAÇÃO
  Future<void> criarAplicacao({required Aplicacao aplicacao}) async {
    await _aplicacoesRef.add(aplicacao);
  }

  /// Verifica se o Host já se aplicou para esse EP (Evita duplicidade)
  Future<bool> jaDemonstrouInteresse({
    required String hostUid,
    required String intercambistaId,
  }) async {
    final snapshot = await _aplicacoesRef
        .where('hostUid', isEqualTo: hostUid)
        .where('intercambistaId', isEqualTo: intercambistaId)
        .where('status', isNotEqualTo: StatusAplicacao.cancelada.name)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Stream para atualizar a tela do Host em tempo real!
  Stream<List<Aplicacao>> getAplicacoesDoHostStream({required String hostUid}) {
    return _aplicacoesRef
        .where('hostUid', isEqualTo: hostUid)
        .orderBy('dataUltimaAtualizacao', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// BUSCA (Future normal, caso precise apenas de uma leitura única)
  Future<List<Aplicacao>> getAplicacoesDoHost({required String hostUid}) async {
    final snapshot = await _aplicacoesRef
        .where('hostUid', isEqualTo: hostUid)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// BUSCA (Future normal, caso precise apenas de uma leitura única)
  Future<List<Aplicacao>> getAplicacaoDoHost({
    required String hostUid,
    required String intercambistaId,
  }) async {
    final snapshot = await _aplicacoesRef
        .where('hostUid', isEqualTo: hostUid)
        .where('intercambistaId', isEqualTo: intercambistaId)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Retorna a quantidade de aplicações ativas para um intercambista específico
  Future<int> getQuantidadeAplicacoesAtivas(String intercambistaId) async {
    try {
      // PROTEÇÃO DE LOGOUT: Se não há usuário, não acessamos o Firestore!
      if (FirebaseAuth.instance.currentUser == null) return 0;

      final snapshot = await _aplicacoesRef
          .where('intercambistaId', isEqualTo: intercambistaId)
          .get();

      final ativas = snapshot.docs.where((doc) {
        final aplicacao = doc.data();
        return aplicacao.status != StatusAplicacao.cancelada;
      }).toList();

      return ativas.length;
    } catch (e) {
      debugPrint("Erro ao contar interessados: $e");
      return 0;
    }
  }

  /// ATUALIZAÇÃO
  Future<void> atualizarStatusAplicacao({
    required String aplicacaoId,
    required StatusAplicacao novoStatus,
  }) async {
    await _aplicacoesRef.doc(aplicacaoId).update({
      'status': novoStatus.name,
      'dataUltimaAtualizacao': Timestamp.now(),
    });
  }

  /// ATUALIZAÇÃO DE STATUS E MOTIVO (MENSAGEM)
  Future<void> atualizarRetornoAplicacao({
    required String aplicacaoId,
    required StatusAplicacao novoStatus,
    String? motivo,
  }) async {
    await _aplicacoesRef.doc(aplicacaoId).update({
      'status': novoStatus.name,
      'dataUltimaAtualizacao': Timestamp.now(),
      if (motivo != null) 'mensagemHost': motivo,
    });
  }

  /// DELETAR
  Future<void> deletarAplicacao({required String aplicacaoId}) async {
    await _aplicacoesRef.doc(aplicacaoId).delete();
  }
}
