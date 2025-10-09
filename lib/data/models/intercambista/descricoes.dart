class Descricoes {
  Descricoes({
    required this.sobreMim,
    required this.hobbies,
    required this.motivacao,
  });

  Descricoes.fromJson(Map<String, dynamic> json)
    : this(
        sobreMim: json['sobreMim']! as String,
        hobbies: json['hobbies']! as String,
        motivacao: json['motivacao']! as String,
      );

  final String sobreMim;
  final String hobbies;
  final String motivacao;

  Map<String, dynamic> toJson() {
    return {'sobreMim': sobreMim, 'hobbies': hobbies, 'motivacao': motivacao};
  }
}
