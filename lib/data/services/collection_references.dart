import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/usuario/usuario.dart';
import '../models/intercambista/intercambista.dart';
import '../models/comite_local/comite_local.dart';
import '../models/aplicacao.dart';

/// Uma classe central para armazenar todas as referências de coleções do Firestore.
/// O uso de .withConverter() garante 100% de segurança de tipo (type safety).
class FirebaseCollections {
  FirebaseCollections._(); // Construtor privado para evitar instanciação

  static final _db = FirebaseFirestore.instance;

  // --- Referências das Coleções ---

  /// Referência para a coleção 'usuarios', já convertida para o model [Usuario].
  static final CollectionReference<Usuario> usuarios = _db
      .collection('usuarios')
      .withConverter<Usuario>(
        fromFirestore: (snapshot, _) => Usuario.fromSnapshot(snapshot),
        toFirestore: (usuario, _) => usuario.toJson(),
      );

  /// Referência para a coleção 'intercambistas', já convertida para o model [Intercambista].
  static final CollectionReference<Intercambista> intercambistas = _db
      .collection('intercambistas')
      .withConverter<Intercambista>(
        fromFirestore: (snapshot, _) => Intercambista.fromSnapshot(snapshot),
        toFirestore: (intercambista, _) => intercambista.toJson(),
      );

  /// Referência para a coleção 'comitesLocais', já convertida para o model [ComiteLocal].
  static final CollectionReference<ComiteLocal> comitesLocais = _db
      .collection('comitesLocais')
      .withConverter<ComiteLocal>(
        fromFirestore: (snapshot, _) => ComiteLocal.fromSnapshot(snapshot),
        toFirestore: (comite, _) => comite.toJson(),
      );

  /// Referência para a coleção 'aplicacoes', já convertida para o model [Aplicacao].
  static final CollectionReference<Aplicacao> aplicacoes = _db
      .collection('aplicacoes')
      .withConverter<Aplicacao>(
        fromFirestore: (snapshot, _) => Aplicacao.fromSnapshot(snapshot),
        toFirestore: (aplicacao, _) => aplicacao.toJson(),
      );
}
