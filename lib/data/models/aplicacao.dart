import 'package:cloud_firestore/cloud_firestore.dart';

class Aplicacao {
  Aplicacao({
    required this.aplicacaoId,
    required this.hostUid,
    required this.intercambistaId,
    required this.comiteLocalId,
    required this.status,
    required this.dataAplicacao,
    required this.dataUltimaAtualizacao,
    this.mensagemHost,
  });

  Aplicacao.fromSnapshot(DocumentSnapshot doc)
    : this.fromJson(doc.data()! as Map<String, dynamic>, id: doc.id);

  Aplicacao.fromJson(Map<String, dynamic> json, {required String id})
    : this(
        aplicacaoId: id,
        hostUid: json['hostUid']! as String,
        intercambistaId: json['intercambistaId']! as String,
        comiteLocalId: json['comiteLocalId']! as String,
        status: json['status']! as String,
        dataAplicacao: (json['dataAplicacao']! as Timestamp).toDate(),
        dataUltimaAtualizacao: (json['dataUltimaAtualizacao']! as Timestamp)
            .toDate(),
        mensagemHost: json['mensagemHost'] as String?,
      );

  final String aplicacaoId;
  final String hostUid;
  final String intercambistaId;
  final String comiteLocalId;
  final String status;
  final DateTime dataAplicacao;
  final DateTime dataUltimaAtualizacao;
  final String? mensagemHost;

  Map<String, dynamic> toJson() {
    return {
      'hostUid': hostUid,
      'intercambistaId': intercambistaId,
      'comiteLocalId': comiteLocalId,
      'status': status,
      'dataAplicacao': Timestamp.fromDate(dataAplicacao),
      'dataUltimaAtualizacao': Timestamp.fromDate(dataUltimaAtualizacao),
      'mensagemHost': mensagemHost,
    };
  }
}
