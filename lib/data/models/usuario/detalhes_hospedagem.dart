class DetalhesHospedagem {
  DetalhesHospedagem({
    this.podeOferecerAcomodacao,
    this.localDormir,
    this.tipoQuarto,
    this.quartoCompartilhadoCom,
    this.acessoAreasComuns,
    this.acessoAguaEnergia,
    this.refeicoesOferecidas,
    this.maxIntercambistas,
    this.periodoHospedagem = const [],
    this.tempoHospedagem,
    this.temAnimais,
    this.detalhesAnimais,
    this.descricaoMoradores,
    this.comodidadesProximas = const [],
  });

  final String? podeOferecerAcomodacao;
  final String? localDormir;
  final String? tipoQuarto;
  final String? quartoCompartilhadoCom;
  final String? acessoAreasComuns;
  final String? acessoAguaEnergia;
  final String? refeicoesOferecidas;
  final String? maxIntercambistas;
  final List<String> periodoHospedagem;
  final String? tempoHospedagem;
  final String? temAnimais;
  final String? detalhesAnimais;
  final String? descricaoMoradores;
  final List<String> comodidadesProximas;

  DetalhesHospedagem.fromJson(Map<String, dynamic> json)
    : this(
        podeOferecerAcomodacao: json['podeOferecerAcomodacao'] as String?,
        localDormir: json['localDormir'] as String?,
        tipoQuarto: json['tipoQuarto'] as String?,
        quartoCompartilhadoCom: json['quartoCompartilhadoCom'] as String?,
        acessoAreasComuns: json['acessoAreasComuns'] as String?,
        acessoAguaEnergia: json['acessoAguaEnergia'] as String?,
        refeicoesOferecidas: json['refeicoesOferecidas'] as String?,
        maxIntercambistas: json['maxIntercambistas'] as String?,
        periodoHospedagem: List<String>.from(json['periodoHospedagem'] ?? []),
        tempoHospedagem: json['tempoHospedagem'] as String?,
        temAnimais: json['temAnimais'] as String?,
        descricaoMoradores: json['descricaoMoradores'] as String?,
        detalhesAnimais: json['detalhesAnimais'] as String?,
        comodidadesProximas: List<String>.from(
          json['comodidadesProximas'] ?? [],
        ),
      );

  Map<String, dynamic> toJson() => {
    'podeOferecerAcomodacao': podeOferecerAcomodacao,
    'localDormir': localDormir,
    'tipoQuarto': tipoQuarto,
    'quartoCompartilhadoCom': quartoCompartilhadoCom,
    'acessoAreasComuns': acessoAreasComuns,
    'acessoAguaEnergia': acessoAguaEnergia,
    'refeicoesOferecidas': refeicoesOferecidas,
    'maxIntercambistas': maxIntercambistas,
    'periodoHospedagem': periodoHospedagem,
    'tempoHospedagem': tempoHospedagem,
    'temAnimais': temAnimais,
    'detalhesAnimais': detalhesAnimais,
    'descricaoMoradores': descricaoMoradores,
    'comodidadesProximas': comodidadesProximas,
  };
}
