import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aiesec_lar_global/core/constants/nps_constantes.dart';
import 'package:aiesec_lar_global/core/constants/form_constants.dart';

class NpsHost {
  NpsHost({
    required this.id,
    required this.hostUid,
    this.podioItemId,
    required this.criadoEm,

    // Sessão 1: Identificação
    required this.nomeHost,
    required this.comiteLocal,
    required this.nomeIntercambista,
    required this.primeiraVezHost,

    // Sessão 2: Suporte
    required this.termoFirmado,
    required this.avaliacaoAcompanhamento,
    required this.comunicacaoClara,

    // Sessão 3: Experiência
    required this.objetivosAlcancados,
    required this.oQueAprendeu,
    required this.oQueMelhorar,

    // Sessão 4: NPS e Promotores
    required this.notaNps,
    required this.serHostNovamente,
    this.motivoNaoTalvez,
    this.indicacaoAmigo,

    // Sessão 5: Memórias (ID interno do Podio em vez de Firebase URL)
    this.fotoPodioId,
  });

  final String id;
  final String hostUid;
  final String? podioItemId;
  final DateTime criadoEm;

  final String nomeHost;
  final String comiteLocal;
  final String nomeIntercambista;
  final String primeiraVezHost;

  final String termoFirmado;
  final String avaliacaoAcompanhamento;
  final String comunicacaoClara;

  final String objetivosAlcancados;
  final String oQueAprendeu;
  final String oQueMelhorar;

  final int notaNps;
  final String serHostNovamente;
  final String? motivoNaoTalvez;
  final String? indicacaoAmigo;

  final int? fotoPodioId; // NOVO: Armazena o ID do arquivo gerado pelo Podio

  NpsHost.fromSnapshot(DocumentSnapshot doc)
    : this.fromJson(doc.data()! as Map<String, dynamic>, id: doc.id);

  NpsHost.fromJson(Map<String, dynamic> json, {required String id})
    : this(
        id: id,
        hostUid: json['hostUid'] as String,
        podioItemId: json['podioItemId'] as String?,
        criadoEm: (json['criadoEm'] as Timestamp).toDate(),
        nomeHost: json['nomeHost'] as String,
        comiteLocal: json['comiteLocal'] as String,
        nomeIntercambista: json['nomeIntercambista'] as String,
        primeiraVezHost: json['primeiraVezHost'] as String,
        termoFirmado: json['termoFirmado'] as String,
        avaliacaoAcompanhamento: json['avaliacaoAcompanhamento'] as String,
        comunicacaoClara: json['comunicacaoClara'] as String,
        objetivosAlcancados: json['objetivosAlcancados'] as String,
        oQueAprendeu: json['oQueAprendeu'] as String,
        oQueMelhorar: json['oQueMelhorar'] as String,
        notaNps: json['notaNps'] as int,
        serHostNovamente: json['serHostNovamente'] as String,
        motivoNaoTalvez: json['motivoNaoTalvez'] as String?,
        indicacaoAmigo: json['indicacaoAmigo'] as String?,
        fotoPodioId: json['fotoPodioId'] as int?,
      );

  Map<String, dynamic> toJson() {
    return {
      'hostUid': hostUid,
      if (podioItemId != null) 'podioItemId': podioItemId,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'nomeHost': nomeHost,
      'comiteLocal': comiteLocal,
      'nomeIntercambista': nomeIntercambista,
      'primeiraVezHost': primeiraVezHost,
      'termoFirmado': termoFirmado,
      'avaliacaoAcompanhamento': avaliacaoAcompanhamento,
      'comunicacaoClara': comunicacaoClara,
      'objetivosAlcancados': objetivosAlcancados,
      'oQueAprendeu': oQueAprendeu,
      'oQueMelhorar': oQueMelhorar,
      'notaNps': notaNps,
      'serHostNovamente': serHostNovamente,
      'motivoNaoTalvez': motivoNaoTalvez,
      'indicacaoAmigo': indicacaoAmigo,
      'fotoPodioId': fotoPodioId,
    };
  }

  // ===========================================================================
  // INTEGRAÇÃO PODIO: Payload JSON Atualizado
  // ===========================================================================
  Map<String, dynamic> toPodioPayload() {
    return {
      "fields":
          {
            // Sessão 1
            "nome-do-host": nomeHost.trim(),
            "qual-comite-aiesec-cuidou-da-sua-experiencia": _mapCat(
              comiteLocal,
              FormConstants.comites,
            ),
            "foi-host-de-qual-intercambista": nomeIntercambista.trim(),
            "foi-sua-primeira-vez-sendo-host-com-a-aiesec": _mapCat(
              primeiraVezHost,
              NpsConstantes.simNao,
            ),

            // Sessão 2
            "a-aiesec-firmou-o-termo-de-compromisso-de-hospedagem-co": _mapCat(
              termoFirmado,
              NpsConstantes.simNao,
            ),
            "como-voce-avalia-a-frequencia-de-acompanhamento-contato": _mapCat(
              avaliacaoAcompanhamento,
              NpsConstantes.acompanhamento,
            ),
            "houve-uma-comunicacao-clara-e-alinhamento-sobre-as-regr": _mapCat(
              comunicacaoClara,
              NpsConstantes.simNaoParcialmente,
            ),

            // Sessão 3
            "seus-objetivos-iniciais-com-essa-experiencia-foram-alca": _mapCat(
              objetivosAlcancados,
              NpsConstantes.simParcialmenteNao,
            ),
            "o-que-voce-mais-gostou-ou-aprendeu-sendo-host": oQueAprendeu
                .trim(),
            "em-sua-opiniao-o-que-a-aiesec-deve-melhorar-no-programa-2":
                oQueMelhorar.trim(),

            // Sessão 4
            "em-uma-escala-de-1-a-10-o-quanto-voce-recomendaria-a-ex": _mapCat(
              notaNps.toString(),
              NpsConstantes.npsNotas,
            ),
            "voce-gostaria-de-ser-host-novamente-no-futuro": _mapCat(
              serHostNovamente,
              NpsConstantes.simNaoTalvez,
            ),
            "se-voce-respondeu-nao-ou-talvez-na-pergunta-anterior-po":
                motivoNaoTalvez?.trim(),
            "tem-algum-amigo-ou-parente-para-indicar-ao-programa-dei":
                indicacaoAmigo?.trim(),

            // Sessão 5 (NOVO: Passa o ID da foto dentro de uma Lista)
            "deixe-uma-foto-da-sua-experiencia-sendo-host": fotoPodioId != null
                ? [fotoPodioId]
                : null,
          }..removeWhere(
            (key, value) =>
                value == null || (value is String && value.trim().isEmpty),
          ),
    };
  }

  int? _mapCat(String? val, List<String> list) {
    if (val == null) return null;
    int idx = list.indexOf(val);
    return idx != -1 ? idx + 1 : null;
  }
}
