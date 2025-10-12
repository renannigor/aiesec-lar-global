import 'dart:convert';
import 'package:http/http.dart' as http;

/// Classe de serviço para buscar endereços usando a API do ViaCEP.
class ViaCepService {
  /// Busca um endereço a partir de um CEP.
  /// Retorna um Map com os dados do endereço ou null se o CEP não for encontrado.
  static Future<Map<String, dynamic>?> buscarCep(String cep) async {
    // Remove caracteres não numéricos do CEP
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cepLimpo.length != 8) {
      return null;
    }

    final url = Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        // A API retorna um erro no corpo do JSON para CEPs que não existem
        if (data.containsKey('erro')) {
          return null;
        }
        return data;
      }
      return null;
    } catch (e) {
      // Em caso de erro de rede, etc.
      return null;
    }
  }
}
