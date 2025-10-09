class Testemunha {
  Testemunha({
    required this.nomeCompleto,
    required this.rg,
    required this.orgaoEmissor,
    required this.cpf,
  });

  Testemunha.fromJson(Map<String, dynamic> json)
    : this(
        nomeCompleto: json['nomeCompleto']! as String,
        rg: json['rg']! as String,
        orgaoEmissor: json['orgaoEmissor']! as String,
        cpf: json['cpf']! as String,
      );

  final String nomeCompleto;
  final String rg;
  final String orgaoEmissor;
  final String cpf;

  Map<String, dynamic> toJson() {
    return {
      'nomeCompleto': nomeCompleto,
      'rg': rg,
      'orgaoEmissor': orgaoEmissor,
      'cpf': cpf,
    };
  }
}
