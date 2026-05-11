import 'package:aiesec_lar_global/data/models/nps_host.dart';
import 'package:aiesec_lar_global/data/services/podio_service.dart';
import 'package:aiesec_lar_global/data/services/collection_references.dart';

class NpsService {
  NpsService._();
  static final instance = NpsService._();

  // Agora utilizamos a referência centralizada e tipada
  final _npsRef = FirebaseCollections.avaliacoesNps;
  final _podioService = PodioService();

  /// Salva o NPS no Firestore e sincroniza com o Podio
  Future<void> enviarNps({required NpsHost avaliacao}) async {
    try {
      // 1. Grava no Firebase (mais simples pois _npsRef já entende o tipo NpsHost)
      await _npsRef.doc(avaliacao.id).set(avaliacao);

      // 2. Envia para o CRM (Podio)
      final podioId = await _podioService.syncNpsNoPodio(avaliacao);

      // 3. Se sucesso, atualiza o documento com o ID do Podio
      if (podioId != null && podioId.isNotEmpty) {
        await _npsRef.doc(avaliacao.id).update({'podioItemId': podioId});
      }
    } catch (e) {
      print('[DEBUG NPS SERVICE] Erro ao sincronizar NPS com o Podio: $e');
      // O erro não é relançado para garantir que a experiência do usuário no app
      // não seja interrompida se a API do Podio falhar.
    }
  }

  /// Busca todas as avaliações feitas por um Host específico em tempo real
  Stream<List<NpsHost>> getNpsPorHost(String hostUid) {
    return _npsRef
        .where('hostUid', isEqualTo: hostUid)
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Busca todas as avaliações NPS vinculadas a um Comitê específico
  Stream<List<NpsHost>> getNpsPorComite(String comiteNome) {
    return _npsRef
        .where('comiteLocal', isEqualTo: comiteNome)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Busca TODAS as avaliações NPS cadastradas na base de dados (Visão SuperAdmin)
  Stream<List<NpsHost>> getTodasAvaliacoesNps() {
    return _npsRef
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
