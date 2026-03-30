class Descricoes {
  final String? sobreMim;
  final String? hobbies;
  final String? motivacao;

  Descricoes({this.sobreMim, this.hobbies, this.motivacao});

  Descricoes.fromJson(Map<String, dynamic> json)
    : this(
        sobreMim: json['sobreMim'] as String?,
        hobbies: json['hobbies'] as String?,
        motivacao: json['motivacao'] as String?,
      );

  Map<String, dynamic> toJson() {
    return {
      if (sobreMim != null) 'sobreMim': sobreMim,
      if (hobbies != null) 'hobbies': hobbies,
      if (motivacao != null) 'motivacao': motivacao,
    };
  }
}