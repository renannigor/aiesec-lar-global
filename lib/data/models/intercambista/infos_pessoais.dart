class InfosPessoais {
  InfosPessoais({
    required this.fumante,
    required this.alergias,
    required this.restricoes,
  });

  InfosPessoais.fromJson(Map<String, dynamic> json)
    : this(
        fumante: json['fumante']! as bool,
        alergias: json['alergias']! as String,
        restricoes: json['restricoes']! as String,
      );

  final bool fumante;
  final String alergias;
  final String restricoes;

  Map<String, dynamic> toJson() {
    return {'fumante': fumante, 'alergias': alergias, 'restricoes': restricoes};
  }
}
