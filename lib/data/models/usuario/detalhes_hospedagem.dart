class DetalhesHospedagem {
  DetalhesHospedagem({
    required this.podeOferecerAcomodacao,
    this.localDormir,
    required this.tipoQuarto,
    this.quartoCompartilhadoCom,
    required this.acessoAreasComuns,
    required this.acessoAguaEnergia,
    required this.refeicoesOferecidas,
    required this.maxIntercambistas,
    required this.periodoHospedagem,
    required this.temAnimais,
    this.detalhesAnimais,
    this.descricaoMoradores,
    required this.comodidadesProximas,
  });

  DetalhesHospedagem.fromJson(Map<String, dynamic> json)
    : this(
        podeOferecerAcomodacao:
            json['podeOferecerAcomodacao'] as bool? ??
            true, // Fallback de segurança
        localDormir: json['localDormir'] as String?,
        tipoQuarto: json['tipoQuarto']! as String,
        quartoCompartilhadoCom: json['quartoCompartilhadoCom'] as String?,
        acessoAreasComuns: json['acessoAreasComuns'] as bool? ?? true,
        acessoAguaEnergia: json['acessoAguaEnergia'] as bool? ?? true,
        refeicoesOferecidas: json['refeicoesOferecidas'].toString(),
        maxIntercambistas: json['maxIntercambistas'].toString(),
        periodoHospedagem: List<String>.from(
          json['periodoHospedagem']! as List,
        ),
        temAnimais: json['temAnimais']! as bool,
        descricaoMoradores: json['descricaoMoradores'] as String?,
        detalhesAnimais: json['detalhesAnimais'] as String?,
        comodidadesProximas: List<String>.from(
          json['comodidadesProximas']! as List,
        ),
      );

  final bool podeOferecerAcomodacao; 
  final String? localDormir;
  final String tipoQuarto;
  final String? quartoCompartilhadoCom;
  final bool acessoAreasComuns;
  final bool acessoAguaEnergia;
  final String refeicoesOferecidas;
  final String maxIntercambistas;
  final List<String> periodoHospedagem;
  final bool temAnimais;
  final String? detalhesAnimais;
  final String? descricaoMoradores;
  final List<String> comodidadesProximas;

  Map<String, dynamic> toJson() {
    return {
      'podeOferecerAcomodacao': podeOferecerAcomodacao, // CORRIGIDO
      if (localDormir != null) 'localDormir': localDormir,
      'tipoQuarto': tipoQuarto,
      'quartoCompartilhadoCom': quartoCompartilhadoCom,
      'acessoAreasComuns': acessoAreasComuns,
      'acessoAguaEnergia': acessoAguaEnergia,
      'refeicoesOferecidas': refeicoesOferecidas,
      'maxIntercambistas': maxIntercambistas,
      'periodoHospedagem': periodoHospedagem,
      'temAnimais': temAnimais,
      'detalhesAnimais': detalhesAnimais,
      'descricaoMoradores': descricaoMoradores,
      'comodidadesProximas': comodidadesProximas,
    };
  }
}
