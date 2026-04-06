import 'package:aiesec_lar_global/data/models/acesso_usuario.dart';
import 'package:aiesec_lar_global/data/models/mensagem_rejeicao.dart';
import 'package:aiesec_lar_global/data/models/oportunidade.dart';
import 'package:aiesec_lar_global/data/models/podio_credentials_model.dart';
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

  /// Referência para a coleção 'credenciaisApiPodio', já convertida para o model [PodioCredentialsModel].
  static final CollectionReference<PodioCredentialsModel> credenciaisApiPodio =
      _db
          .collection('credenciaisApiPodio')
          .withConverter<PodioCredentialsModel>(
            fromFirestore: (snapshot, _) =>
                PodioCredentialsModel.fromFirestore(snapshot.data()!),
            toFirestore: (credencial, _) => credencial.toJson(),
          );

  /// Referência para a coleção 'acessos', já convertida para o model [AcessoUsuario].
  static final CollectionReference<AcessoUsuario> acessos = _db
      .collection('acessos')
      .withConverter<AcessoUsuario>(
        fromFirestore: (snapshot, _) => AcessoUsuario.fromSnapshot(snapshot),
        toFirestore: (acesso, _) => acesso.toJson(),
      );

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
        // Pegamos o data() garantindo que é um Map e passamos para o fromJson
        fromFirestore: (snapshot, _) =>
            Intercambista.fromJson(snapshot.data()!),
        toFirestore: (intercambista, _) => intercambista.toJson(),
      );

  /// Referência para a coleção 'oportunidades', convertida para o model [Oportunidade].
  static final CollectionReference<Oportunidade> oportunidades = _db
      .collection('oportunidades')
      .withConverter<Oportunidade>(
        fromFirestore: (snapshot, _) => Oportunidade.fromJson(snapshot.data()!),
        toFirestore: (oportunidade, _) => oportunidade.toJson(),
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

  /// Referência para a coleção 'mensagensRejeicao', convertida para o model [MensagemRejeicao].
  static final CollectionReference<MensagemRejeicao> mensagensRejeicao = _db
      .collection('mensagensRejeicao')
      .withConverter<MensagemRejeicao>(
        fromFirestore: (snapshot, _) => MensagemRejeicao.fromSnapshot(snapshot),
        toFirestore: (mensagem, _) => mensagem.toJson(),
      );
}
