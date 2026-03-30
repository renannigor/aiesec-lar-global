class Endereco {
  Endereco({
    required this.logradouro,
    required this.numero,
    this.complemento, 
    required this.bairro,
    required this.cep,
    required this.cidade,
    required this.estado,
  });

  Endereco.fromJson(Map<String, dynamic> json)
      : this(
          logradouro: json['logradouro']! as String,
          numero: json['numero']! as String,
          complemento: json['complemento'] as String?, 
          bairro: json['bairro']! as String,
          cep: json['cep']! as String,
          cidade: json['cidade']! as String,
          estado: json['estado']! as String,
        );

  final String logradouro;
  final String numero;
  final String? complemento; 
  final String bairro;
  final String cep;
  final String cidade;
  final String estado;

  Map<String, dynamic> toJson() {
    return {
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento, 
      'bairro': bairro,
      'cep': cep,
      'cidade': cidade,
      'estado': estado,
    };
  }
}