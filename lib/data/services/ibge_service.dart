import 'dart:convert';
import 'package:aiesec_lar_global/data/models/ibge_model.dart';
import 'package:http/http.dart' as http;

class IbgeService {
  IbgeService._();

  static const String _baseUrl =
      'https://servicodados.ibge.gov.br/api/v1/localidades';

  // --- ESTADOS ---
  static Future<List<Estado>> getEstados() async {
    final url = Uri.parse('$_baseUrl/estados?orderBy=nome');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> lista = json.decode(response.body);
        return lista.map((e) => Estado.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao carregar estados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão (Estados): $e');
    }
  }

  // --- CIDADES (MUNICÍPIOS) ---
  static Future<List<Cidade>> getCidadesPorEstado(int estadoId) async {
    final url = Uri.parse(
      '$_baseUrl/estados/$estadoId/municipios?orderBy=nome',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> lista = json.decode(response.body);
        return lista.map((e) => Cidade.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao carregar cidades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão (Cidades): $e');
    }
  }

  // --- NOVO: DISTRITOS (LOCALIDADES) ---
  // Usa o ID do Município para buscar os distritos
  static Future<List<Distrito>> getDistritosPorCidade(int cidadeId) async {
    // Endpoint fornecido: .../municipios/{municipio}/distritos
    final url = Uri.parse(
      '$_baseUrl/municipios/$cidadeId/distritos?orderBy=nome',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> lista = json.decode(response.body);
        return lista.map((e) => Distrito.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao carregar distritos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão (Distritos): $e');
    }
  }

  // --- NOVO: PAÍSES ---
  static Future<List<Pais>> getPaises() async {
    final url = Uri.parse('$_baseUrl/paises?orderBy=nome');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> lista = json.decode(response.body);
        return lista.map((e) => Pais.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao carregar países: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão (Países): $e');
    }
  }
}
