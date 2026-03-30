class InfosPessoais {
  final bool? fumante;
  final String? alergias;
  final String? restricoes;

  InfosPessoais({this.fumante, this.alergias, this.restricoes});

  InfosPessoais.fromJson(Map<String, dynamic> json)
    : this(
        fumante: json['fumante'] as bool?,
        alergias: json['alergias'] as String?,
        restricoes: json['restricoes'] as String?,
      );

  Map<String, dynamic> toJson() {
    return {
      if (fumante != null) 'fumante': fumante,
      if (alergias != null) 'alergias': alergias,
      if (restricoes != null) 'restricoes': restricoes,
    };
  }
}