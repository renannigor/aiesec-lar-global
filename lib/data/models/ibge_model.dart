import 'dart:convert';

/// Decodifica uma lista de Estados a partir de uma string JSON.
List<Estado> estadoFromJson(String str) =>
    List<Estado>.from(json.decode(str).map((x) => Estado.fromJson(x)));

/// Decodifica uma lista de Cidades a partir de uma string JSON.
List<Cidade> cidadeFromJson(String str) =>
    List<Cidade>.from(json.decode(str).map((x) => Cidade.fromJson(x)));

/// Representa um Estado (UF) retornado pela API do IBGE.
class Estado {
  Estado({required this.id, required this.sigla, required this.nome});

  final int id;
  final String sigla;
  final String nome;

  factory Estado.fromJson(Map<String, dynamic> json) =>
      Estado(id: json["id"], sigla: json["sigla"], nome: json["nome"]);
}

/// Representa uma Cidade (Município) retornada pela API do IBGE.
class Cidade {
  Cidade({required this.id, required this.nome});

  final int id;
  final String nome;

  factory Cidade.fromJson(Map<String, dynamic> json) =>
      Cidade(id: json["id"], nome: json["nome"]);
}
