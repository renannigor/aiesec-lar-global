class PreferenciasHospedagem {
  PreferenciasHospedagem({
    this.restricaoFumantes,
    this.aceitaRestricaoAlimentar = const [],
    this.preferenciaSexo,
    this.preferenciaIdiomas = const [],
    this.outrosIdiomas,
  });

  final String? restricaoFumantes;
  final List<String> aceitaRestricaoAlimentar;
  final String? preferenciaSexo;
  final List<String> preferenciaIdiomas;
  final String? outrosIdiomas;

  PreferenciasHospedagem.fromJson(Map<String, dynamic> json)
    : this(
        restricaoFumantes: json['restricaoFumantes'] as String?,
        aceitaRestricaoAlimentar: List<String>.from(
          json['aceitaRestricaoAlimentar'] ?? [],
        ),
        preferenciaSexo: json['preferenciaSexo'] as String?,
        preferenciaIdiomas: List<String>.from(json['preferenciaIdiomas'] ?? []),
        outrosIdiomas: json['outrosIdiomas'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'restricaoFumantes': restricaoFumantes,
    'aceitaRestricaoAlimentar': aceitaRestricaoAlimentar,
    'preferenciaSexo': preferenciaSexo,
    'preferenciaIdiomas': preferenciaIdiomas,
    'outrosIdiomas': outrosIdiomas,
  };
}
