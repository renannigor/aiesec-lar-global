import 'package:cloud_firestore/cloud_firestore.dart';
import 'infos_pessoais.dart';
import 'descricoes.dart';

class Intercambista {
  Intercambista({
    required this.intercambistaId,
    required this.nome,
    required this.pais,
    required this.idade,
    required this.fotoPerfilUrl,
    required this.status,
    required this.comiteLocalId,
    required this.dataInicio,
    required this.dataTermino,
    required this.formacao,
    required this.idiomas,
    required this.interesses,
    required this.localTrabalho,
    required this.infosPessoais,
    required this.descricoes,
  });

  Intercambista.fromSnapshot(DocumentSnapshot doc)
    : this.fromJson(doc.data()! as Map<String, dynamic>, id: doc.id);

  Intercambista.fromJson(Map<String, dynamic> json, {required String id})
    : this(
        intercambistaId: id,
        nome: json['nome']! as String,
        pais: json['pais']! as String,
        idade: json['idade']! as int,
        fotoPerfilUrl: json['fotoPerfilUrl']! as String,
        status: json['status']! as String,
        comiteLocalId: json['comiteLocalId']! as String,
        dataInicio: (json['dataInicio']! as Timestamp).toDate(),
        dataTermino: (json['dataTermino']! as Timestamp).toDate(),
        formacao: json['formacao']! as String,
        idiomas: List<String>.from(json['idiomas']! as List),
        interesses: List<String>.from(json['interesses']! as List),
        localTrabalho: json['localTrabalho']! as String,
        infosPessoais: InfosPessoais.fromJson(
          json['infosPessoais']! as Map<String, dynamic>,
        ),
        descricoes: Descricoes.fromJson(
          json['descricoes']! as Map<String, dynamic>,
        ),
      );

  final String intercambistaId;
  final String nome;
  final String pais;
  final int idade;
  final String fotoPerfilUrl;
  final String status;
  final String comiteLocalId;
  final DateTime dataInicio;
  final DateTime dataTermino;
  final String formacao;
  final List<String> idiomas;
  final List<String> interesses;
  final String localTrabalho;
  final InfosPessoais infosPessoais;
  final Descricoes descricoes;

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'pais': pais,
      'idade': idade,
      'fotoPerfilUrl': fotoPerfilUrl,
      'status': status,
      'comiteLocalId': comiteLocalId,
      'dataInicio': Timestamp.fromDate(dataInicio),
      'dataTermino': Timestamp.fromDate(dataTermino),
      'formacao': formacao,
      'idiomas': idiomas,
      'interesses': interesses,
      'localTrabalho': localTrabalho,
      'infosPessoais': infosPessoais.toJson(),
      'descricoes': descricoes.toJson(),
    };
  }
}
