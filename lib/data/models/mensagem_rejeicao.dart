import 'package:cloud_firestore/cloud_firestore.dart';

class MensagemRejeicao {
  final String id;
  final String titulo;
  final String descricao;

  MensagemRejeicao({
    required this.id,
    required this.titulo,
    required this.descricao,
  });

  factory MensagemRejeicao.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MensagemRejeicao(
      id: doc.id,
      titulo: data['titulo'] as String? ?? '',
      descricao: data['descricao'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'titulo': titulo, 'descricao': descricao};
  }
}
