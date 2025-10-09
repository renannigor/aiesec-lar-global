class DetalhesHospedagem {
  DetalhesHospedagem({
    required this.podeOferecerAcomodacao,
    required this.tipoQuarto,
    this.quartoCompartilhadoCom,
    required this.acessoAreasComuns,
    required this.refeicoesOferecidas,
    required this.maxIntercambistas,
    required this.periodoHospedagem,
    required this.temAnimais,
    this.detalhesAnimais,
    required this.comodidadesProximas,
    required this.fotosUrl,
  });

  DetalhesHospedagem.fromJson(Map<String, dynamic> json)
    : this(
        podeOferecerAcomodacao: json['podeOferecerAcomodacao']! as bool,
        tipoQuarto: json['tipoQuarto']! as String,
        quartoCompartilhadoCom: json['quartoCompartilhadoCom'] as String?,
        acessoAreasComuns: json['acessoAreasComuns']! as bool,
        refeicoesOferecidas: json['refeicoesOferecidas']! as int,
        maxIntercambistas: json['maxIntercambistas']! as int,
        periodoHospedagem: List<String>.from(
          json['periodoHospedagem']! as List,
        ),
        temAnimais: json['temAnimais']! as bool,
        detalhesAnimais: json['detalhesAnimais'] as String?,
        comodidadesProximas: List<String>.from(
          json['comodidadesProximas']! as List,
        ),
        fotosUrl: List<String>.from(json['fotosUrl']! as List),
      );

  final bool podeOferecerAcomodacao;
  final String tipoQuarto;
  final String? quartoCompartilhadoCom;
  final bool acessoAreasComuns;
  final int refeicoesOferecidas;
  final int maxIntercambistas;
  final List<String> periodoHospedagem;
  final bool temAnimais;
  final String? detalhesAnimais;
  final List<String> comodidadesProximas;
  final List<String> fotosUrl;

  Map<String, dynamic> toJson() {
    return {
      'podeOferecerAcomodacao': podeOferecerAcomodacao,
      'tipoQuarto': tipoQuarto,
      'quartoCompartilhadoCom': quartoCompartilhadoCom,
      'acessoAreasComuns': acessoAreasComuns,
      'refeicoesOferecidas': refeicoesOferecidas,
      'maxIntercambistas': maxIntercambistas,
      'periodoHospedagem': periodoHospedagem,
      'temAnimais': temAnimais,
      'detalhesAnimais': detalhesAnimais,
      'comodidadesProximas': comodidadesProximas,
      'fotosUrl': fotosUrl,
    };
  }
}
