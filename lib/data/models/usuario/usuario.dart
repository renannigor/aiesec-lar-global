import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:aiesec_lar_global/data/models/perfil_usuario.dart';
import 'package:aiesec_lar_global/core/constants/form_constants.dart';
import '../endereco.dart';
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
    this.podioItemId, // ID gerado pelo Podio
    // --- Sessão 1: Informações Básicas / CRM ---
    this.cpf,
    this.rg,
    this.telefone,
    this.comoPrefereSerContactado,
    this.dataNascimento,
    this.sexo,
    this.estadoCivil,
    this.profissao,
    this.aiesecMaisProxima,
    this.comoConheceuAiesec,

    // --- Sessão 2: Endereço ---
    this.endereco,

    // --- Sessão 3: Motivações e Pessoal ---
    this.restricaoAlimentarPropria,
    this.porQueHospedar,
    this.expectativasIntercambista,

    // --- Objetos Aninhados ---
    this.detalhesHospedagem,
    this.preferenciasHospedagem,
  });

  final String uid;
  final String? podioItemId;
  final String email;
  final String nome;
  final String fotoPerfilUrl;
  final DateTime criadoEm;
  final PerfilUsuario perfil;

  final String? cpf;
  final String? rg;
  final String? telefone;
  final String? comoPrefereSerContactado;
  final DateTime? dataNascimento;
  final String? sexo;
  final String? estadoCivil;
  final String? profissao;
  final String? aiesecMaisProxima;
  final String? comoConheceuAiesec;

  final Endereco? endereco;

  final String? restricaoAlimentarPropria;
  final String? porQueHospedar;
  final String? expectativasIntercambista;

  final DetalhesHospedagem? detalhesHospedagem;
  final PreferenciasHospedagem? preferenciasHospedagem;

  // --- MÉTODO COPYWITH ---
  Usuario copyWith({
    String? uid,
    String? podioItemId,
    String? email,
    String? nome,
    String? fotoPerfilUrl,
    DateTime? criadoEm,
    PerfilUsuario? perfil,
    String? cpf,
    String? rg,
    String? telefone,
    String? comoPrefereSerContactado,
    DateTime? dataNascimento,
    String? sexo,
    String? estadoCivil,
    String? profissao,
    String? aiesecMaisProxima,
    String? comoConheceuAiesec,
    Endereco? endereco,
    String? restricaoAlimentarPropria,
    String? porQueHospedar,
    String? expectativasIntercambista,
    DetalhesHospedagem? detalhesHospedagem,
    PreferenciasHospedagem? preferenciasHospedagem,
  }) {
    return Usuario(
      uid: uid ?? this.uid,
      podioItemId: podioItemId ?? this.podioItemId,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      fotoPerfilUrl: fotoPerfilUrl ?? this.fotoPerfilUrl,
      criadoEm: criadoEm ?? this.criadoEm,
      perfil: perfil ?? this.perfil,
      cpf: cpf ?? this.cpf,
      rg: rg ?? this.rg,
      telefone: telefone ?? this.telefone,
      comoPrefereSerContactado:
          comoPrefereSerContactado ?? this.comoPrefereSerContactado,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      sexo: sexo ?? this.sexo,
      estadoCivil: estadoCivil ?? this.estadoCivil,
      profissao: profissao ?? this.profissao,
      aiesecMaisProxima: aiesecMaisProxima ?? this.aiesecMaisProxima,
      comoConheceuAiesec: comoConheceuAiesec ?? this.comoConheceuAiesec,
      endereco: endereco ?? this.endereco,
      restricaoAlimentarPropria:
          restricaoAlimentarPropria ?? this.restricaoAlimentarPropria,
      porQueHospedar: porQueHospedar ?? this.porQueHospedar,
      expectativasIntercambista:
          expectativasIntercambista ?? this.expectativasIntercambista,
      detalhesHospedagem: detalhesHospedagem ?? this.detalhesHospedagem,
      preferenciasHospedagem:
          preferenciasHospedagem ?? this.preferenciasHospedagem,
    );
  }

  Usuario.fromSnapshot(DocumentSnapshot doc)
    : this.fromJson(doc.data()! as Map<String, dynamic>, id: doc.id);

  Usuario.fromJson(Map<String, dynamic> json, {required String id})
    : this(
        uid: id,
        podioItemId: json['podioItemId'] as String?,
        email: json['email'] as String? ?? 'E-mail não informado',
        nome: json['nome'] as String? ?? 'Usuário Desconhecido',
        fotoPerfilUrl: json['fotoPerfilUrl'] as String? ?? '',
        criadoEm: json['criadoEm'] != null
            ? (json['criadoEm'] as Timestamp).toDate()
            : DateTime.now(),
        perfil: _perfilFromString(json['perfil'] as String?),
        cpf: json['cpf'] as String?,
        rg: json['rg'] as String?,
        telefone: json['telefone'] as String?,
        comoPrefereSerContactado: json['comoPrefereSerContactado'] as String?,
        dataNascimento: json['dataNascimento'] == null
            ? null
            : (json['dataNascimento'] as Timestamp).toDate(),
        sexo: json['sexo'] as String?,
        estadoCivil: json['estadoCivil'] as String?,
        profissao: json['profissao'] as String?,
        aiesecMaisProxima: json['aiesecMaisProxima'] as String?,
        comoConheceuAiesec: json['comoConheceuAiesec'] as String?,
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

  Map<String, dynamic> toJson() {
    return {
      if (podioItemId != null) 'podioItemId': podioItemId,
      'email': email,
      'nome': nome,
      'fotoPerfilUrl': fotoPerfilUrl,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'perfil': perfil.name,
      'cpf': cpf,
      'rg': rg,
      'telefone': telefone,
      'comoPrefereSerContactado': comoPrefereSerContactado,
      'dataNascimento': dataNascimento == null
          ? null
          : Timestamp.fromDate(dataNascimento!),
      'sexo': sexo,
      'estadoCivil': estadoCivil,
      'profissao': profissao,
      'aiesecMaisProxima': aiesecMaisProxima,
      'comoConheceuAiesec': comoConheceuAiesec,
      'restricaoAlimentarPropria': restricaoAlimentarPropria,
      'porQueHospedar': porQueHospedar,
      'expectativasIntercambista': expectativasIntercambista,
      'endereco': endereco?.toJson(),
      'detalhesHospedagem': detalhesHospedagem?.toJson(),
      'preferenciasHospedagem': preferenciasHospedagem?.toJson(),
    };
  }

  // LÓGICA DE PROGRESSO DO PERFIL
  double get progressoPreenchimento {
    int totalCampos = 0;
    int camposPreenchidos = 0;

    void checarCampo(String nomeCampo, Object? valor) {
      totalCampos++;
      bool isPreenchido = false;

      if (valor != null) {
        if (valor is String) {
          if (valor.trim().isNotEmpty) isPreenchido = true;
        } else if (valor is List) {
          if (valor.isNotEmpty) isPreenchido = true;
        } else {
          isPreenchido = true;
        }
      }

      if (isPreenchido) {
        camposPreenchidos++;
      } else {
        print('⚠️ O campo "$nomeCampo" está vazio!');
      }
    }

    // 1. Dados Básicos
    checarCampo('cpf', cpf);
    checarCampo('rg', rg);
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

    // Endereço
    if (endereco != null) {
      checarCampo('endereco.cep', endereco!.cep);
      checarCampo('endereco.logradouro', endereco!.logradouro);
      checarCampo('endereco.numero', endereco!.numero);
      checarCampo('endereco.bairro', endereco!.bairro);
      checarCampo('endereco.cidade', endereco!.cidade);
      checarCampo('endereco.estado', endereco!.estado);
    } else {
      totalCampos += 6;
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
      checarCampo('tempoHospedagem', detalhesHospedagem!.tempoHospedagem);
      checarCampo('temAnimais', detalhesHospedagem!.temAnimais);
      checarCampo('descricaoMoradores', detalhesHospedagem!.descricaoMoradores);

      if (detalhesHospedagem!.temAnimais == 'Sim') {
        checarCampo('detalhesAnimais', detalhesHospedagem!.detalhesAnimais);
      }

      checarCampo(
        'comodidadesProximas',
        detalhesHospedagem!.comodidadesProximas,
      );
    } else {
      totalCampos += 12; // Base de campos
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
      checarCampo(
        'preferenciaIdiomas',
        preferenciasHospedagem!.preferenciaIdiomas,
      );

      if (preferenciasHospedagem!.preferenciaIdiomas.contains('Outros')) {
        checarCampo('outrosIdiomas', preferenciasHospedagem!.outrosIdiomas);
      }
    } else {
      totalCampos += 4;
    }

    if (totalCampos == 0) return 0.0;
    return camposPreenchidos / totalCampos;
  }

  bool get isPerfilCompleto => progressoPreenchimento >= 1.0;

  // ===========================================================================
  // INTEGRAÇÃO PODIO: Converte o modelo Dart para Payload BLINDADO
  // ===========================================================================
  Map<String, dynamic> toPodioPayload() {
    return {
      "fields":
          {
            "title": nome
                .trim(), // Nunca enviaremos nome vazio, mas garantimos o trim()
            // Assegurando que contatos vazios "" não sejam enviados
            "email": email.trim().isNotEmpty
                ? [
                    {"type": "other", "value": email.trim()},
                  ]
                : null,
            "telefone": (telefone != null && telefone!.trim().isNotEmpty)
                ? [
                    {"type": "mobile", "value": telefone!.trim()},
                  ]
                : null,

            "cpf": cpf?.trim(),
            "email-address": rg?.trim(),

            "como-prefere-ser-contactado": _mapCat(
              comoPrefereSerContactado,
              FormConstants.contato,
            ),

            "data-de-nascimento": dataNascimento != null
                ? {
                    "start": DateFormat(
                      'yyyy-MM-dd HH:mm:ss',
                    ).format(dataNascimento!),
                  }
                : null,

            "sexo": _mapCat(sexo, FormConstants.sexo),
            "estado-civil": _mapCat(estadoCivil, FormConstants.estadoCivil),
            "profissao": profissao?.trim(),
            "aiesec-mais-proxima": _mapCat(
              _limparNomeComite(aiesecMaisProxima),
              FormConstants.comites,
            ),
            "como-conheceu-a-aiesec": _mapCat(
              comoConheceuAiesec,
              FormConstants.conheceuAiesec,
            ),

            "localizacao":
                endereco != null && endereco!.logradouro.trim().isNotEmpty
                ? "${endereco!.logradouro}, ${endereco!.numero} - ${endereco!.bairro}, ${endereco!.cidade} - ${endereco!.estado}"
                : null,
            "complemento": endereco?.complemento?.trim(),

            "restricao-alimentar-propria": _mapCat(
              restricaoAlimentarPropria,
              FormConstants.restricaoPropria,
            ),
            "por-que-quer-hospedar": porQueHospedar?.trim(),
            "expectativas-com-o-intercambista": expectativasIntercambista
                ?.trim(),

            "pode-oferecer-acomodacao": _mapCat(
              detalhesHospedagem?.podeOferecerAcomodacao,
              FormConstants.simNao,
            ),
            "local-de-dormir": _mapCat(
              detalhesHospedagem?.localDormir,
              FormConstants.localDormir,
            ),
            "tipo-de-quarto": _mapCat(
              detalhesHospedagem?.tipoQuarto,
              FormConstants.tipoQuarto,
            ),
            "quarto-compartilhado-com-quem": detalhesHospedagem
                ?.quartoCompartilhadoCom
                ?.trim(),
            "acesso-a-areas-comuns": _mapCat(
              detalhesHospedagem?.acessoAreasComuns,
              FormConstants.simNao,
            ),
            "acesso-a-agua-e-energia-livre": _mapCat(
              detalhesHospedagem?.acessoAguaEnergia,
              FormConstants.simNao,
            ),
            "refeicoes-oferecidas": _mapCat(
              detalhesHospedagem?.refeicoesOferecidas,
              FormConstants.refeicoes,
            ),
            "maximo-de-intercambistas": _mapCat(
              detalhesHospedagem?.maxIntercambistas,
              FormConstants.maxEps,
            ),
            "periodo-de-hospedagem-disponivel": _mapMultiCat(
              detalhesHospedagem?.periodoHospedagem,
              FormConstants.meses,
            ),
            "quanto-tempo-voce-pode-hospedar": _mapCat(
              detalhesHospedagem?.tempoHospedagem,
              FormConstants.tempoHospedagem,
            ),
            "tem-animais-em-casa": _mapCat(
              detalhesHospedagem?.temAnimais,
              FormConstants.simNao,
            ),
            "detalhes-dos-animais": detalhesHospedagem?.detalhesAnimais?.trim(),
            "descricao-dos-moradores-da-casa": detalhesHospedagem
                ?.descricaoMoradores
                ?.trim(),
            "comodidades-proximas": _mapMultiCat(
              detalhesHospedagem?.comodidadesProximas,
              FormConstants.comodidades,
            ),

            "restricao-a-fumantes-aceita-fumantes": _mapCat(
              preferenciasHospedagem?.restricaoFumantes,
              FormConstants.aceitaFumantes,
            ),
            "aceita-intercambista-com-restricao-alimentar": _mapMultiCat(
              preferenciasHospedagem?.aceitaRestricaoAlimentar,
              FormConstants.aceitaRestricaoAlimentar,
            ),
            "preferencia-de-sexo-do-intercambista": _mapCat(
              preferenciasHospedagem?.preferenciaSexo,
              FormConstants.prefSexo,
            ),
            "preferencia-de-idiomas": _mapMultiCat(
              preferenciasHospedagem?.preferenciaIdiomas,
              FormConstants.idiomas,
            ),
            "quais-outros-idiomas": preferenciasHospedagem?.outrosIdiomas
                ?.trim(),
          }..removeWhere(
            (key, value) =>
                value == null ||
                (value is String && value.trim().isEmpty) ||
                (value is List && value.isEmpty),
          ),
    };
  }
}

// ===========================================================================
// HELPERS (Privados do arquivo)
// ===========================================================================

String? _limparNomeComite(String? nomeCompleto) {
  if (nomeCompleto == null) return null;
  // Apaga o "AIESEC " + "em", "no", "na" ou "in" do começo da frase
  return nomeCompleto
      .replaceAll(
        RegExp(r'^AIESEC\s+(em|no|na|in)\s+', caseSensitive: false),
        '',
      )
      .trim()
      .toUpperCase();
}

PerfilUsuario _perfilFromString(String? p) =>
    PerfilUsuario.values.firstWhere((e) => e.name == p);

int? _mapCat(String? val, List<String> list) {
  if (val == null) return null;
  int idx = list.indexOf(val);
  return idx != -1 ? idx + 1 : null;
}

List<int> _mapMultiCat(List<String>? vals, List<String> list) {
  if (vals == null || vals.isEmpty) return [];
  return vals.map((v) => list.indexOf(v) + 1).where((id) => id > 0).toList();
}
