import 'package:aiesec_lar_global/data/models/perfil_usuario.dart';
import 'package:aiesec_lar_global/data/models/usuario/detalhes_hospedagem.dart';
import 'package:aiesec_lar_global/data/models/usuario/preferencias_hospedagem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../endereco.dart';

class Usuario {
  Usuario({
    required this.uid,
    required this.email,
    required this.nome,
    required this.fotoPerfilUrl,
    required this.criadoEm,
    required this.perfil,

    // --- Campos de Informação Básica / CRM ---
    this.aiesecMaisProxima,
    this.cpf,
    this.comoPrefereSerContactado,
    this.comoConheceuAiesec,
    this.dataNascimento,
    this.sexo,
    this.estadoCivil,
    this.profissao,
    this.telefone,
    this.restricaoAlimentarPropria,
    this.endereco,

    // --- Campos de Motivação / Expectativa ---
    this.porQueHospedar,
    this.expectativasIntercambista,
    // --- Objetos Aninhados ---
    this.detalhesHospedagem,
    this.preferenciasHospedagem,
  });

  Usuario.fromSnapshot(DocumentSnapshot doc)
    : this.fromJson(doc.data()! as Map<String, dynamic>, id: doc.id);

  Usuario.fromJson(Map<String, dynamic> json, {required String id})
    : this(
        uid: id,
        email: json['email'] as String? ?? 'E-mail não informado',
        nome: json['nome'] as String? ?? 'Usuário Desconhecido',
        fotoPerfilUrl: json['fotoPerfilUrl'] as String? ?? '',
        criadoEm: json['criadoEm'] != null
            ? (json['criadoEm'] as Timestamp).toDate()
            : DateTime.now(),
        perfil: _perfilFromString(json['perfil'] as String?),

        aiesecMaisProxima: json['aiesecMaisProxima'] as String?,
        cpf: json['cpf'] as String?,
        comoPrefereSerContactado: json['comoPrefereSerContactado'] as String?,
        comoConheceuAiesec: json['comoConheceuAiesec'] as String?,
        dataNascimento: json['dataNascimento'] == null
            ? null
            : (json['dataNascimento'] as Timestamp).toDate(),
        sexo: json['sexo'] as String?,
        estadoCivil: json['estadoCivil'] as String?,
        profissao: json['profissao'] as String?,
        telefone: json['telefone'] as String?,
        restricaoAlimentarPropria: json['restricaoAlimentarPropria'] as String?,
        porQueHospedar: json['porQueHospedar'] as String?,
        expectativasIntercambista: json['expectativasIntercambista'] as String?,

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
      );

  final String uid;
  final String email;
  final String nome;
  final String fotoPerfilUrl;
  final DateTime criadoEm;
  final PerfilUsuario perfil;

  final String? aiesecMaisProxima;
  final String? cpf;
  final String? comoPrefereSerContactado;
  final String? comoConheceuAiesec;
  final DateTime? dataNascimento;
  final String? sexo;
  final String? estadoCivil;
  final String? profissao;
  final String? telefone;
  final String? restricaoAlimentarPropria;
  final String? porQueHospedar;
  final String? expectativasIntercambista;

  final Endereco? endereco;
  final DetalhesHospedagem? detalhesHospedagem;
  final PreferenciasHospedagem? preferenciasHospedagem;

  // --- MÉTODO COPYWITH ---
  Usuario copyWith({
    String? uid,
    String? email,
    String? nome,
    String? fotoPerfilUrl,
    DateTime? criadoEm,
    PerfilUsuario? perfil,
    String? aiesecMaisProxima,
    String? cpf,
    String? comoPrefereSerContactado,
    String? comoConheceuAiesec,
    DateTime? dataNascimento,
    String? sexo,
    String? estadoCivil,
    String? profissao,
    String? telefone,
    String? restricaoAlimentarPropria,
    String? porQueHospedar,
    String? expectativasIntercambista,
    Endereco? endereco,
    DetalhesHospedagem? detalhesHospedagem,
    PreferenciasHospedagem? preferenciasHospedagem,
  }) {
    return Usuario(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      fotoPerfilUrl: fotoPerfilUrl ?? this.fotoPerfilUrl,
      criadoEm: criadoEm ?? this.criadoEm,
      perfil: perfil ?? this.perfil,
      aiesecMaisProxima: aiesecMaisProxima ?? this.aiesecMaisProxima,
      cpf: cpf ?? this.cpf,
      comoPrefereSerContactado:
          comoPrefereSerContactado ?? this.comoPrefereSerContactado,
      comoConheceuAiesec: comoConheceuAiesec ?? this.comoConheceuAiesec,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      sexo: sexo ?? this.sexo,
      estadoCivil: estadoCivil ?? this.estadoCivil,
      profissao: profissao ?? this.profissao,
      telefone: telefone ?? this.telefone,
      restricaoAlimentarPropria:
          restricaoAlimentarPropria ?? this.restricaoAlimentarPropria,
      porQueHospedar: porQueHospedar ?? this.porQueHospedar,
      expectativasIntercambista:
          expectativasIntercambista ?? this.expectativasIntercambista,
      endereco: endereco ?? this.endereco,
      detalhesHospedagem: detalhesHospedagem ?? this.detalhesHospedagem,
      preferenciasHospedagem:
          preferenciasHospedagem ?? this.preferenciasHospedagem,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nome': nome,
      'fotoPerfilUrl': fotoPerfilUrl,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'perfil': perfil.name,
      'aiesecMaisProxima': aiesecMaisProxima,
      'cpf': cpf,
      'comoPrefereSerContactado': comoPrefereSerContactado,
      'comoConheceuAiesec': comoConheceuAiesec,
      'dataNascimento': dataNascimento == null
          ? null
          : Timestamp.fromDate(dataNascimento!),
      'sexo': sexo,
      'estadoCivil': estadoCivil,
      'profissao': profissao,
      'telefone': telefone,
      'restricaoAlimentarPropria': restricaoAlimentarPropria,
      'porQueHospedar': porQueHospedar,
      'expectativasIntercambista': expectativasIntercambista,
      'endereco': endereco?.toJson(),
      'detalhesHospedagem': detalhesHospedagem?.toJson(),
      'preferenciasHospedagem': preferenciasHospedagem?.toJson(),
    };
  }

  // --- LÓGICA DE PROGRESSO DO PERFIL ---

  /// Retorna um valor de 0.0 a 1.0 representando o % de preenchimento
  double get progressoPreenchimento {
    int totalCampos = 0;
    int camposPreenchidos = 0;

    // Função auxiliar com DEBUG para identificar o campo faltante
    void checarCampo(String nomeCampo, Object? valor) {
      totalCampos++;
      bool isPreenchido = false;

      if (valor != null) {
        if (valor is String) {
          if (valor.trim().isNotEmpty) isPreenchido = true;
        } else if (valor is List) {
          if (valor.isNotEmpty) isPreenchido = true;
        } else {
          // Booleanos, Inteiros, DateTime, Objetos (Endereco)
          isPreenchido = true;
        }
      }

      if (isPreenchido) {
        camposPreenchidos++;
      } else {
        // VAI PRINTAR EXATAMENTE O CAMPO QUE FALTA
        print('⚠️ ATENÇÃO: O campo "$nomeCampo" está vazio ou nulo!');
      }
    }

    // 1. Dados Básicos / CRM
    checarCampo('cpf', cpf);
    checarCampo('telefone', telefone);
    checarCampo('aiesecMaisProxima', aiesecMaisProxima);
    checarCampo('comoPrefereSerContactado', comoPrefereSerContactado);
    checarCampo('comoConheceuAiesec', comoConheceuAiesec);
    checarCampo('dataNascimento', dataNascimento);
    checarCampo('sexo', sexo);
    checarCampo('estadoCivil', estadoCivil);
    checarCampo('profissao', profissao);
    checarCampo('restricaoAlimentarPropria', restricaoAlimentarPropria);
    checarCampo('porQueHospedar', porQueHospedar);
    checarCampo('expectativasIntercambista', expectativasIntercambista);

    // Checagem profunda do Endereço
    if (endereco != null) {
      checarCampo('endereco.cep', endereco!.cep);
      checarCampo('endereco.logradouro', endereco!.logradouro);
      checarCampo('endereco.numero', endereco!.numero);
      checarCampo('endereco.bairro', endereco!.bairro);
      checarCampo('endereco.cidade', endereco!.cidade);
      checarCampo('endereco.estado', endereco!.estado);
    } else {
      totalCampos += 6;
      print('⚠️ ATENÇÃO: O bloco inteiro de "Endereco" está nulo!');
    }

    // 2. Detalhes da Hospedagem
    if (detalhesHospedagem != null) {
      checarCampo(
        'podeOferecerAcomodacao',
        detalhesHospedagem!.podeOferecerAcomodacao,
      );
      checarCampo('localDormir', detalhesHospedagem!.localDormir);
      checarCampo('tipoQuarto', detalhesHospedagem!.tipoQuarto);

      if (detalhesHospedagem!.tipoQuarto == 'Compartilhado') {
        checarCampo(
          'quartoCompartilhadoCom',
          detalhesHospedagem!.quartoCompartilhadoCom,
        );
      }

      checarCampo('acessoAreasComuns', detalhesHospedagem!.acessoAreasComuns);
      checarCampo('acessoAguaEnergia', detalhesHospedagem!.acessoAguaEnergia);
      checarCampo(
        'refeicoesOferecidas',
        detalhesHospedagem!.refeicoesOferecidas,
      );
      checarCampo('maxIntercambistas', detalhesHospedagem!.maxIntercambistas);
      checarCampo('periodoHospedagem', detalhesHospedagem!.periodoHospedagem);
      checarCampo('temAnimais', detalhesHospedagem!.temAnimais);
      checarCampo('descricaoMoradores', detalhesHospedagem!.descricaoMoradores);

      if (detalhesHospedagem!.temAnimais == true) {
        checarCampo('detalhesAnimais', detalhesHospedagem!.detalhesAnimais);
      }

      checarCampo(
        'comodidadesProximas',
        detalhesHospedagem!.comodidadesProximas,
      );
    } else {
      totalCampos += 11;
      print('⚠️ ATENÇÃO: O bloco inteiro de "DetalhesHospedagem" está nulo!');
    }

    // 3. Preferências de Hospedagem
    if (preferenciasHospedagem != null) {
      checarCampo(
        'restricaoFumantes',
        preferenciasHospedagem!.restricaoFumantes,
      );
      checarCampo(
        'aceitaRestricaoAlimentar',
        preferenciasHospedagem!.aceitaRestricaoAlimentar,
      );
      checarCampo('preferenciaSexo', preferenciasHospedagem!.preferenciaSexo);
      checarCampo('preferenciaMeses', preferenciasHospedagem!.preferenciaMeses);
      checarCampo(
        'preferenciaIdiomas',
        preferenciasHospedagem!.preferenciaIdiomas,
      );

      if (preferenciasHospedagem!.preferenciaIdiomas.contains('Outros')) {
        checarCampo('outrosIdiomas', preferenciasHospedagem!.outrosIdiomas);
      }
    } else {
      totalCampos += 5;
      print(
        '⚠️ ATENÇÃO: O bloco inteiro de "PreferenciasHospedagem" está nulo!',
      );
    }

    if (totalCampos == 0) return 0.0;

    print('Campos preenchidos: $camposPreenchidos / $totalCampos');

    return camposPreenchidos / totalCampos;
  }

  /// Retorna se o perfil está 100% completo
  bool get isPerfilCompleto => progressoPreenchimento >= 1.0;
}

PerfilUsuario _perfilFromString(String? perfilString) {
  if (perfilString == null) return PerfilUsuario.indefinido;
  for (final perfil in PerfilUsuario.values) {
    if (perfil.name == perfilString) return perfil;
  }
  return PerfilUsuario.indefinido;
}
