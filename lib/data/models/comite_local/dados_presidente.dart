class DadosPresidente {
  DadosPresidente({
    required this.nomeCompleto,
    required this.estadoCivil,
    required this.email,
    required this.telefone,
    required this.rg,
    required this.orgaoEmissor,
    required this.cpf,
  });

  DadosPresidente.fromJson(Map<String, dynamic> json)
    : this(
        nomeCompleto: json['nomeCompleto']! as String,
        estadoCivil: json['estadoCivil']! as String,
        email: json['email']! as String,
        telefone: json['telefone']! as String,
        rg: json['rg']! as String,
        orgaoEmissor: json['orgaoEmissor']! as String,
        cpf: json['cpf']! as String,
      );

  final String nomeCompleto;
  final String estadoCivil;
  final String email;
  final String telefone;
  final String rg;
  final String orgaoEmissor;
  final String cpf;

  Map<String, dynamic> toJson() {
    return {
      'nomeCompleto': nomeCompleto,
      'estadoCivil': estadoCivil,
      'email': email,
      'telefone': telefone,
      'rg': rg,
      'orgaoEmissor': orgaoEmissor,
      'cpf': cpf,
    };
  }
}
