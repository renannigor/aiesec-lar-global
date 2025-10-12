import 'package:http/http.dart' as http;
import '../models/ibge_model.dart';

/// Uma classe de serviço para interagir com a API de localidades do IBGE.
class IbgeService {
  // Construtor privado para que a classe não possa ser instanciada.
  IbgeService._();

  static const String _baseUrl =
      'https://servicodados.ibge.gov.br/api/v1/localidades';

  /// Busca a lista de todos os estados (UFs) do Brasil.
  ///
  /// Retorna uma lista de [Estado] ordenada alfabeticamente.
  /// Lança uma exceção se a chamada à API falhar.
  static Future<List<Estado>> getEstados() async {
    final url = Uri.parse('$_baseUrl/estados');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<Estado> estados = estadoFromJson(response.body);
        // Ordena os estados em ordem alfabética pelo nome
        estados.sort((a, b) => a.nome.compareTo(b.nome));
        return estados;
      } else {
        throw Exception('Falha ao carregar os estados.');
      }
    } catch (e) {
      // Re-lança a exceção para que a UI possa tratá-la
      throw Exception('Erro de conexão: ${e.toString()}');
    }
  }

  /// Busca a lista de cidades (municípios) de um estado específico.
  ///
  /// Recebe o [estadoId] (ID da UF) como parâmetro.
  /// Retorna uma lista de [Cidade] ordenada alfabeticamente.
  /// Lança uma exceção se a chamada à API falhar.
  static Future<List<Cidade>> getCidadesPorEstado(int estadoId) async {
    final url = Uri.parse('$_baseUrl/estados/$estadoId/municipios');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<Cidade> cidades = cidadeFromJson(response.body);
        // Ordena as cidades em ordem alfabética pelo nome
        cidades.sort((a, b) => a.nome.compareTo(b.nome));
        return cidades;
      } else {
        throw Exception('Falha ao carregar as cidades.');
      }
    } catch (e) {
      throw Exception('Erro de conexão: ${e.toString()}');
    }
  }
}