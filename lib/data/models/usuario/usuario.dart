import 'package:cloud_firestore/cloud_firestore.dart';
import 'endereco.dart';
import 'detalhes_hospedagem.dart';
import 'preferencias_hospedagem.dart';

class Usuario {
  Usuario({
    required this.uid,
    required this.email,
    required this.nome,
    required this.fotoPerfilUrl,
    required this.criadoEm,
    required this.perfil,
    // Campos opcionais
    this.comiteLocalId,
    this.dataNascimento,
    this.sexo,
    this.estadoCivil,
    this.profissao,
    this.telefone,
    this.restricaoAlimentarPropria,
    this.endereco,
    this.detalhesHospedagem,
    this.preferenciasHospedagem,
    this.descricaoMoradores,
    this.expectativasIntercambista,
  });

  Usuario.fromSnapshot(DocumentSnapshot doc)
    : this.fromJson(doc.data()! as Map<String, dynamic>, id: doc.id);

  Usuario.fromJson(Map<String, dynamic> json, {required String id})
    : this(
        uid: id,
        email: json['email']! as String,
        nome: json['nome']! as String,
        fotoPerfilUrl: json['fotoPerfilUrl']! as String,
        criadoEm: (json['criadoEm']! as Timestamp).toDate(),
        perfil: json['perfil']! as String,
        // Campos que podem ser nulos
        comiteLocalId: json['comiteLocalId'] as String?,
        dataNascimento: json['dataNascimento'] == null
            ? null
            : (json['dataNascimento'] as Timestamp).toDate(),
        sexo: json['sexo'] as String?,
        estadoCivil: json['estadoCivil'] as String?,
        profissao: json['profissao'] as String?,
        telefone: json['telefone'] as String?,
        restricaoAlimentarPropria: json['restricaoAlimentarPropria'] as String?,
        endereco: json['endereco'] == null
            ? null
            : Endereco.fromJson(json['endereco'] as Map<String, dynamic>),
        detalhesHospedagem: json['detalhesHospedagem'] == null
            ? null
            : DetalhesHospedagem.fromJson(
                json['detalhesHospedagem'] as Map<String, dynamic>,
              ),
        preferenciasHospedagem: json['preferenciasHospedagem'] == null
            ? null
            : PreferenciasHospedagem.fromJson(
                json['preferenciasHospedagem'] as Map<String, dynamic>,
              ),
        descricaoMoradores: json['descricaoMoradores'] as String?,
        expectativasIntercambista: json['expectativasIntercambista'] as String?,
      );

  // Campos obrigatórios
  final String uid;
  final String email;
  final String nome;
  final String fotoPerfilUrl;
  final DateTime criadoEm;
  final String perfil;

  // Campos opcionais (nullable)
  final String? comiteLocalId;
  final DateTime? dataNascimento;
  final String? sexo;
  final String? estadoCivil;
  final String? profissao;
  final String? telefone;
  final String? restricaoAlimentarPropria;
  final Endereco? endereco;
  final DetalhesHospedagem? detalhesHospedagem;
  final PreferenciasHospedagem? preferenciasHospedagem;
  final String? descricaoMoradores;
  final String? expectativasIntercambista;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nome': nome,
      'fotoPerfilUrl': fotoPerfilUrl,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'perfil': perfil,
      // Campos opcionais
      'comiteLocalId': comiteLocalId,
      'dataNascimento': dataNascimento == null
          ? null
          : Timestamp.fromDate(dataNascimento!),
      'sexo': sexo,
      'estadoCivil': estadoCivil,
      'profissao': profissao,
      'telefone': telefone,
      'restricaoAlimentarPropria': restricaoAlimentarPropria,
      'endereco': endereco?.toJson(),
      'detalhesHospedagem': detalhesHospedagem?.toJson(),
      'preferenciasHospedagem': preferenciasHospedagem?.toJson(),
      'descricaoMoradores': descricaoMoradores,
      'expectativasIntercambista': expectativasIntercambista,
    };
  }
}
