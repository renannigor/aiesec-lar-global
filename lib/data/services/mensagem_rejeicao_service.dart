import 'package:aiesec_lar_global/data/services/collection_references.dart';
import 'package:aiesec_lar_global/data/models/mensagem_rejeicao.dart';

class MensagemRejeicaoService {
  MensagemRejeicaoService._();
  static final instance = MensagemRejeicaoService._();

  final _mensagensRef = FirebaseCollections.mensagensRejeicao;

  Future<List<MensagemRejeicao>> getMensagens() async {
    final snapshot = await _mensagensRef.get();

    // Como usamos o .withConverter no FirebaseCollections,
    // doc.data() já é automaticamente um objeto MensagemRejeicao!
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
