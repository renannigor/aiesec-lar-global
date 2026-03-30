import 'package:aiesec_lar_global/data/models/endereco.dart';

class Oportunidade {
  // --- Dados vindos do Podio ---
  final String opId;
  final String organizacao;
  final String projeto;
  final String comite;
  final String area;
  final int duracaoTotal;
  final String financiamentoGv;

  // --- Dados manuais ou complementares ---
  final Endereco? endereco;

  Oportunidade({
    required this.opId,
    required this.organizacao,
    required this.projeto,
    required this.comite,
    required this.area,
    required this.duracaoTotal,
    required this.financiamentoGv,
    this.endereco,
  });

  // 1. Lendo do Firebase
  Oportunidade.fromJson(Map<String, dynamic> json)
    : this(
        opId: json['opId'] as String? ?? '',
        organizacao: json['organizacao'] as String? ?? '',
        projeto: json['projeto'] as String? ?? '',
        comite: json['comite'] as String? ?? '',
        area: json['area'] as String? ?? '',
        duracaoTotal: json['duracaoTotal'] as int? ?? 0,
        financiamentoGv: json['financiamentoGv'] as String? ?? '',
        endereco: json['endereco'] != null
            ? Endereco.fromJson(json['endereco'] as Map<String, dynamic>)
            : null,
      );

  // 2. Lendo direto da extração da API do Podio
  factory Oportunidade.fromPodio(Map<String, String> opData) {
    return Oportunidade(
      opId: opData['OP ID'] ?? '',
      organizacao: opData['Empresa/ONG'] ?? '',
      projeto: opData['Projeto/Vaga'] ?? '',
      comite: opData['Comitê'] ?? '',
      area: opData['Área'] ?? '',
      duracaoTotal: int.tryParse(opData['Duração Total'] ?? '') ?? 0,
      financiamentoGv: opData['Financiamento GV'] ?? '',
    );
  }

  // 3. Enviando para o Firebase
  Map<String, dynamic> toJson() {
    return {
      'opId': opId,
      'organizacao': organizacao,
      'projeto': projeto,
      'comite': comite,
      'area': area,
      'duracaoTotal': duracaoTotal,
      'financiamentoGv': financiamentoGv,
      if (endereco != null) 'endereco': endereco!.toJson(),
    };
  }
}
