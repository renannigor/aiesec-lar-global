import 'dart:convert';

/// Decodifica uma lista de Estados a partir de uma string JSON.
List<Estado> estadoFromJson(String str) =>
    List<Estado>.from(json.decode(str).map((x) => Estado.fromJson(x)));

/// Decodifica uma lista de Cidades a partir de uma string JSON.
List<Cidade> cidadeFromJson(String str) =>
    List<Cidade>.from(json.decode(str).map((x) => Cidade.fromJson(x)));

class Estado {
  final int id;
  final String sigla;
  final String nome;

  Estado({required this.id, required this.sigla, required this.nome});

  factory Estado.fromJson(Map<String, dynamic> json) {
    return Estado(
      id: json['id'],
      sigla: json['sigla'],
      nome: json['nome'],
    );
  }
}

class Cidade {
  final int id;
  final String nome;

  Cidade({required this.id, required this.nome});

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      id: json['id'],
      nome: json['nome'],
    );
  }
}

class Distrito {
  final int id;
  final String nome;

  Distrito({required this.id, required this.nome});

  factory Distrito.fromJson(Map<String, dynamic> json) {
    // Garante que o ID seja int, mesmo que a API mande string
    return Distrito(
      id: int.parse(json['id'].toString()), 
      nome: json['nome'],
    );
  }
}

class Pais {
  final int id;
  final String nome;
  final String sigla;

  Pais({required this.id, required this.nome, required this.sigla});

  factory Pais.fromJson(Map<String, dynamic> json) {
    // --- LÓGICA DE PROTEÇÃO CONTRA O ERRO DE TIPO ---
    
    int idVal = 0;
    String siglaVal = '';
    String nomeVal = '';

    // 1. Verifica o ID (Pode vir como int direto ou objeto com M49)
    if (json['id'] is int) {
      idVal = json['id'];
    } else if (json['id'] is Map) {
      idVal = json['id']['M49'] ?? 0;
      siglaVal = json['id']['ISO-3166-1-ALPHA-2'] ?? '';
    }

    // 2. Verifica o NOME (Pode vir como String direto ou objeto com abreviado)
    // O erro "String not subtype of int" acontecia aqui
    if (json['nome'] is String) {
      nomeVal = json['nome'];
    } else if (json['nome'] is Map) {
      nomeVal = json['nome']['abreviado'] ?? '';
    }

    return Pais(
      id: idVal,
      nome: nomeVal,
      sigla: siglaVal,
    );
  }
}