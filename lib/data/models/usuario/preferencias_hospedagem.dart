class PreferenciasHospedagem {
  PreferenciasHospedagem({
    required this.restricaoFumantes,
    required this.aceitaRestricaoAlimentar,
    required this.preferenciaSexo,
    required this.preferenciaMeses,
    required this.preferenciaIdiomas,
  });

  PreferenciasHospedagem.fromJson(Map<String, dynamic> json)
    : this(
        restricaoFumantes: json['restricaoFumantes']! as bool,
        aceitaRestricaoAlimentar: List<String>.from(
          json['aceitaRestricaoAlimentar']! as List,
        ),
        preferenciaSexo: json['preferenciaSexo']! as String,
        preferenciaMeses: List<String>.from(json['preferenciaMeses']! as List),
        preferenciaIdiomas: List<String>.from(
          json['preferenciaIdiomas']! as List,
        ),
      );

  final bool restricaoFumantes;
  final List<String> aceitaRestricaoAlimentar;
  final String preferenciaSexo;
  final List<String> preferenciaMeses;
  final List<String> preferenciaIdiomas;

  Map<String, dynamic> toJson() {
    return {
      'restricaoFumantes': restricaoFumantes,
      'aceitaRestricaoAlimentar': aceitaRestricaoAlimentar,
      'preferenciaSexo': preferenciaSexo,
      'preferenciaMeses': preferenciaMeses,
      'preferenciaIdiomas': preferenciaIdiomas,
    };
  }
}
