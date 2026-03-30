import 'infos_pessoais.dart';
import 'descricoes.dart';

class Intercambista {
  // --- Dados vindos do Podio ---
  final String nome;
  final String epId;
  final String comite;
  final String opId;
  final String area;
  final String status;
  final String dataRePresencial;
  final String dataFinPresencial;
  final String entidadeAbroad;

  // --- Dados de Controle ---
  final bool precisaHospedagem;

  // --- Dados de preenchimento manual ---
  final String? dataChegada;
  final String? dataPartida;
  final String? pais;
  final String? nacionalidade;
  final int? idade;
  final String? formacao;
  final List<String>? idiomas;
  final List<String>? interesses;
  final InfosPessoais? infosPessoais;
  final Descricoes? descricoes;

  Intercambista({
    required this.nome,
    required this.epId,
    required this.comite,
    required this.opId,
    required this.area,
    required this.status,
    required this.dataRePresencial,
    required this.dataFinPresencial,
    required this.entidadeAbroad,
    this.precisaHospedagem = true, // Padrão: true
    this.dataChegada,
    this.dataPartida,
    this.pais,
    this.nacionalidade,
    this.idade,
    this.formacao,
    this.idiomas,
    this.interesses,
    this.infosPessoais,
    this.descricoes,
  });

  // 1. Construtor para ler do Firebase
  Intercambista.fromJson(Map<String, dynamic> json)
    : this(
        nome: json['nome'] as String? ?? '',
        epId: json['epId'] as String? ?? '',
        comite: json['comite'] as String? ?? '',
        opId: json['opId'] as String? ?? '',
        area: json['area'] as String? ?? '',
        status: json['status'] as String? ?? '',
        dataRePresencial: json['dataRePresencial'] as String? ?? '',
        dataFinPresencial: json['dataFinPresencial'] as String? ?? '',
        entidadeAbroad: json['entidadeAbroad'] as String? ?? '',
        precisaHospedagem:
            json['precisaHospedagem'] as bool? ??
            true, // Lê do banco ou assume true
        dataChegada: json['dataChegada'] as String?,
        dataPartida: json['dataPartida'] as String?,
        pais: json['pais'] as String?,
        nacionalidade: json['nacionalidade'] as String?,
        idade: json['idade'] as int?,
        formacao: json['formacao'] as String?,
        idiomas: json['idiomas'] != null
            ? List<String>.from(json['idiomas'])
            : null,
        interesses: json['interesses'] != null
            ? List<String>.from(json['interesses'])
            : null,
        infosPessoais: json['infosPessoais'] != null
            ? InfosPessoais.fromJson(
                json['infosPessoais'] as Map<String, dynamic>,
              )
            : null,
        descricoes: json['descricoes'] != null
            ? Descricoes.fromJson(json['descricoes'] as Map<String, dynamic>)
            : null,
      );

  // 2. Construtor para instanciar a partir dos dados do Podio
  factory Intercambista.fromPodio(
    Map<String, String> epData, {
    bool precisaHospedagem = true,
  }) {
    return Intercambista(
      nome: epData['Nome do EP'] ?? 'Sem Nome',
      epId: epData['EP ID'] ?? '',
      comite: epData['Comitê'] ?? '',
      opId: epData['OP ID'] ?? '',
      area: epData['Área'] ?? '',
      status: epData['Status'] ?? '',
      dataRePresencial: epData['Data RE Presencial'] ?? '',
      dataFinPresencial: epData['Data FIN Presencial'] ?? '',
      entidadeAbroad: epData['Entidade Abroad'] ?? '',
      precisaHospedagem:
          precisaHospedagem, // Associa o cálculo feito antes de instanciar
    );
  }

  // 3. Construtor para enviar para o Firebase
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'epId': epId,
      'comite': comite,
      'opId': opId,
      'area': area,
      'status': status,
      'dataRePresencial': dataRePresencial,
      'dataFinPresencial': dataFinPresencial,
      'entidadeAbroad': entidadeAbroad,
      'precisaHospedagem':
          precisaHospedagem, // Salva o status do filtro no banco
      if (dataChegada != null) 'dataChegada': dataChegada,
      if (dataPartida != null) 'dataPartida': dataPartida,
      if (pais != null) 'pais': pais,
      if (nacionalidade != null) 'nacionalidade': nacionalidade,
      if (idade != null) 'idade': idade,
      if (formacao != null) 'formacao': formacao,
      if (idiomas != null) 'idiomas': idiomas,
      if (interesses != null) 'interesses': interesses,
      if (infosPessoais != null) 'infosPessoais': infosPessoais!.toJson(),
      if (descricoes != null) 'descricoes': descricoes!.toJson(),
    };
  }
}
