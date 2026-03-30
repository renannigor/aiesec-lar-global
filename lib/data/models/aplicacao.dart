import 'package:cloud_firestore/cloud_firestore.dart';

// Enum para espelhar exatamente os passos do seu Funil (Stepper)
enum StatusAplicacao {
  pendente('Inscrição recebida'),
  entrevistaAiesec('Encontro com a AIESEC'),
  aprovada('Candidatura aprovada'),
  encontroEp('Encontro com o intercambista'),
  confirmada('Confirmação da hospedagem'),
  assinaturaTermo('Assinatura do termo'),
  hospedando('Intercambista hospedado'),
  concluida('Experiência concluída'),
  cancelada('Cancelada pelo Host'),
  rejeitada('Não aprovada pela AIESEC');

  final String descricao;
  const StatusAplicacao(this.descricao);

  static StatusAplicacao fromString(String status) {
    return StatusAplicacao.values.firstWhere(
      (e) => e.name == status,
      orElse: () => StatusAplicacao.pendente,
    );
  }
}

class Aplicacao {
  final String aplicacaoId;
  final String hostUid;
  final String intercambistaId;
  final String comiteLocal;
  final StatusAplicacao status; // Agora usa o Enum de forma segura
  final DateTime dataAplicacao;
  final DateTime dataUltimaAtualizacao;
  final String? mensagemHost;

  // --- DADOS ESPELHO (Para a UI da lista carregar rápido) ---
  final String epNome;
  final String epPais;
  final String? ongNome;
  final String? dataChegada;
  final String? dataPartida;

  Aplicacao({
    required this.aplicacaoId,
    required this.hostUid,
    required this.intercambistaId,
    required this.comiteLocal,
    required this.status,
    required this.dataAplicacao,
    required this.dataUltimaAtualizacao,
    required this.epNome,
    required this.epPais,
    this.ongNome,
    this.dataChegada,
    this.dataPartida,
    this.mensagemHost,
  });

  Aplicacao.fromSnapshot(DocumentSnapshot doc)
    : this.fromJson(doc.data()! as Map<String, dynamic>, id: doc.id);

  Aplicacao.fromJson(Map<String, dynamic> json, {required String id})
    : this(
        aplicacaoId: id,
        hostUid: json['hostUid']! as String,
        intercambistaId: json['intercambistaId']! as String,
        comiteLocal: json['comiteLocal']! as String,
        status: StatusAplicacao.fromString(json['status']! as String),
        dataAplicacao: (json['dataAplicacao']! as Timestamp).toDate(),
        dataUltimaAtualizacao: (json['dataUltimaAtualizacao']! as Timestamp)
            .toDate(),
        epNome: json['epNome'] as String? ?? 'EP Desconhecido',
        epPais: json['epPais'] as String? ?? '',
        ongNome: json['ongNome'] as String?,
        dataChegada: json['dataChegada'] as String?,
        dataPartida: json['dataPartida'] as String?,
        mensagemHost: json['mensagemHost'] as String?,
      );

  Map<String, dynamic> toJson() {
    return {
      'hostUid': hostUid,
      'intercambistaId': intercambistaId,
      'comiteLocal': comiteLocal,
      'status': status.name, // Salva a string do Enum no Firebase
      'dataAplicacao': Timestamp.fromDate(dataAplicacao),
      'dataUltimaAtualizacao': Timestamp.fromDate(dataUltimaAtualizacao),
      'epNome': epNome,
      'epPais': epPais,
      if (ongNome != null) 'ongNome': ongNome,
      if (dataChegada != null) 'dataChegada': dataChegada,
      if (dataPartida != null) 'dataPartida': dataPartida,
      if (mensagemHost != null) 'mensagemHost': mensagemHost,
    };
  }
}
