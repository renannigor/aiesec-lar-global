import 'package:cloud_firestore/cloud_firestore.dart';

class ComiteLocal {
  ComiteLocal({
    required this.comiteId,
    required this.nome,
    required this.cidade,
    required this.estado,
    this.status = 'Ativo',
    required this.nomePodio,
    this.telefone,
    this.email,
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
        nomePodio: json['nome_podio'] as String,
        telefone: json['telefone'] as String?,
        email: json['email'] as String?,
      );

  final String? comiteId;
  final String nome;
  final String cidade;
  final String estado;
  final String status;
  final String nomePodio;

  // Campos Opcionais
  final String? telefone;
  final String? email;

  Map<String, dynamic> toJson() {
    // Cria o mapa base com os obrigatórios
    final Map<String, dynamic> data = {
      'nome': nome,
      'cidade': cidade,
      'estado': estado,
      'status': status,
      'nome_podio': nomePodio,
    };

    // Só adiciona os opcionais se eles existirem
    if (telefone != null) data['telefone'] = telefone;
    if (email != null) data['email'] = email;

    return data;
  }
}
