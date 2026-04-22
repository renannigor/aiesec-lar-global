import 'package:cloud_firestore/cloud_firestore.dart';

// Os papéis que têm acessos especiais (Host não precisa estar aqui, se não tem doc = é Host)
enum PapelAcesso { admin, superadmin }

class AcessoUsuario {
  AcessoUsuario({
    required this.uid,
    required this.papel,
    this.comiteGerenciado,
    required this.concedidoEm,
  });

  final String uid;
  final PapelAcesso papel;
  final String?
  comiteGerenciado; // Guarda o ID do único comitê que ele acessa
  final DateTime concedidoEm;

  factory AcessoUsuario.fromSnapshot(DocumentSnapshot doc) {
    return AcessoUsuario.fromJson(
      doc.data()! as Map<String, dynamic>,
      id: doc.id,
    );
  }

  factory AcessoUsuario.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) {
    return AcessoUsuario(
      uid: id,
      papel: _papelFromString(json['papel'] as String?),
      comiteGerenciado: json['comiteGerenciado'] as String?,
      concedidoEm: (json['concedidoEm'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'papel': papel.name,
      if (comiteGerenciado != null) 'comiteGerenciado': comiteGerenciado,
      'concedidoEm': Timestamp.fromDate(concedidoEm),
      'uid': uid,
    };
  }

  // Verifica se o usuário tem permissão sobre um comitê específico
  bool podeGerenciarComite(String comiteId) {
    if (papel == PapelAcesso.superadmin) {
      return true; // Superadmin gerencia tudo
    }
    return comiteGerenciado == comiteId; // Admin só gerencia o dele
  }
}

PapelAcesso _papelFromString(String? papelString) {
  if (papelString == 'superadmin') return PapelAcesso.superadmin;
  return PapelAcesso.admin; // Default para quem tem documento aqui
}
