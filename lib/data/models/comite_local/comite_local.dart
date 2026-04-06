import 'package:cloud_firestore/cloud_firestore.dart';
import 'dados_presidente.dart';
import '../endereco.dart';
import 'testemunha.dart';

class ComiteLocal {
  ComiteLocal({
    required this.comiteId,
    required this.nome,
    required this.cidade,
    required this.estado,
    this.status = 'Ativo',
    this.cnpj,
    this.telefone,
    this.email,
    this.dadosPresidente,
    this.endereco,
    this.testemunhas = const [],
  });

  ComiteLocal.fromSnapshot(DocumentSnapshot doc)
    : this.fromJson(doc.data()! as Map<String, dynamic>, id: doc.id);

  ComiteLocal.fromJson(Map<String, dynamic> json, {required String id})
    : this(
        comiteId: id,
        nome: json['nome'] as String,
        cidade: json['cidade'] as String,
        estado: json['estado'] as String,
        status: json['status'] as String? ?? 'Ativo',
        cnpj: json['cnpj'] as String?,
        telefone: json['telefone'] as String?,
        email: json['email'] as String?,
        dadosPresidente: json['dadosPresidente'] != null
            ? DadosPresidente.fromJson(
                json['dadosPresidente'] as Map<String, dynamic>,
              )
            : null,

        endereco: json['endereco'] != null
            ? Endereco.fromJson(json['endereco'] as Map<String, dynamic>)
            : null,

        testemunhas:
            (json['testemunhas'] as List?)
                ?.map((t) => Testemunha.fromJson(t as Map<String, dynamic>))
                .toList() ??
            [],
      );

  final String? comiteId;
  final String nome;
  final String cidade;
  final String estado;
  final String status;

  // Campos Opcionais
  final String? cnpj;
  final String? telefone;
  final String? email;
  final DadosPresidente? dadosPresidente;
  final Endereco? endereco;
  final List<Testemunha> testemunhas;

  Map<String, dynamic> toJson() {
    // Cria o mapa base com os obrigatórios
    final Map<String, dynamic> data = {
      'nome': nome,
      'cidade': cidade,
      'estado': estado,
      'status': status,
      'testemunhas': testemunhas.map((t) => t.toJson()).toList(),
    };

    // Só adiciona os opcionais se eles existirem
    if (cnpj != null) data['cnpj'] = cnpj;
    if (telefone != null) data['telefone'] = telefone;
    if (email != null) data['email'] = email;
    if (dadosPresidente != null) {
      data['dadosPresidente'] = dadosPresidente!.toJson();
    }
    if (endereco != null) data['endereco'] = endereco!.toJson();

    return data;
  }
}
