import 'package:cloud_firestore/cloud_firestore.dart';
import 'dados_presidente.dart';
import '../usuario/endereco.dart';
import 'testemunha.dart';

class ComiteLocal {
  ComiteLocal({
    required this.comiteId,
    required this.nome,
    required this.cnpj,
    required this.cidade,
    required this.estado,
    required this.dadosPresidente,
    required this.endereco,
    required this.testemunhas,
  });

  ComiteLocal.fromSnapshot(DocumentSnapshot doc)
    : this.fromJson(doc.data()! as Map<String, dynamic>, id: doc.id);

  ComiteLocal.fromJson(Map<String, dynamic> json, {required String id})
    : this(
        comiteId: id,
        nome: json['nome']! as String,
        cnpj: json['cnpj']! as String,
        cidade: json['cidade']! as String,
        estado: json['estado']! as String,
        dadosPresidente: DadosPresidente.fromJson(
          json['dadosPresidente']! as Map<String, dynamic>,
        ),
        endereco: Endereco.fromJson(json['endereco']! as Map<String, dynamic>),
        testemunhas: (json['testemunhas']! as List)
            .map(
              (testemunhaJson) =>
                  Testemunha.fromJson(testemunhaJson as Map<String, dynamic>),
            )
            .toList(),
      );

  final String comiteId;
  final String nome;
  final String cnpj;
  final String cidade;
  final String estado;
  final DadosPresidente dadosPresidente;
  final Endereco endereco;
  final List<Testemunha> testemunhas;

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cnpj': cnpj,
      'cidade': cidade,
      'estado': estado,
      'dadosPresidente': dadosPresidente.toJson(),
      'endereco': endereco.toJson(),
      'testemunhas': testemunhas
          .map((testemunha) => testemunha.toJson())
          .toList(),
    };
  }
}
