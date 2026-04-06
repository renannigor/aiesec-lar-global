import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';

class CsvExporter {
  CsvExporter._();

  /// Exporta uma lista de Intercambistas para um arquivo CSV
  static Future<void> exportIntercambistas(List<Intercambista> lista) async {
    if (lista.isEmpty) throw Exception("A lista está vazia.");

    // 1. Achata todos os objetos usando o toJson() nativo deles
    List<Map<String, dynamic>> flatList = lista
        .map((e) => _flattenMap(e.toJson()))
        .toList();

    // 2. Coleta todos os cabeçalhos possíveis
    Set<String> headers = {};
    for (var flatMap in flatList) {
      headers.addAll(flatMap.keys);
    }
    List<String> headerList = headers.toList();

    // 3. Monta as linhas do CSV
    List<List<dynamic>> csvData = [];
    csvData.add(headerList); // Adiciona a linha de cabeçalho

    for (var flatMap in flatList) {
      List<dynamic> row = [];
      for (var header in headerList) {
        // Se o valor existir, adiciona. Se for null, adiciona vazio ('')
        row.add(flatMap[header] ?? '');
      }
      csvData.add(row);
    }

    // 4. A MÁGICA DA VERSÃO 8 DO PACOTE CSV:
    // O 'excel.encode' adiciona o UTF-8 BOM e usa ';' para não quebrar o Excel BR.
    String csvString = excel.encode(csvData);

    // Converte para Bytes para o download
    Uint8List bytes = Uint8List.fromList(utf8.encode(csvString));

    // 5. NOVA API DO FILE_SAVER: A extensão vai direto no 'name' e o 'ext' foi removido!
    await FileSaver.instance.saveFile(
      name:
          "Intercambistas_Export_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now())}.csv",
      bytes: bytes,
      mimeType: MimeType.csv,
    );
  }

  /// Função recursiva para transformar mapas aninhados em propriedades planas
  static Map<String, dynamic> _flattenMap(
    Map<String, dynamic> map, [
    String prefix = '',
  ]) {
    Map<String, dynamic> flat = {};

    map.forEach((key, value) {
      String newKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        flat.addAll(_flattenMap(value, newKey)); // Recursão para mapas internos
      } else if (value is List) {
        flat[newKey] = value.join(
          ', ',
        ); // Converte listas em strings separadas por vírgula
      } else if (value is bool) {
        flat[newKey] = value
            ? "Sim"
            : "Não"; // Formata os booleanos para ficar legível no Excel
      } else {
        flat[newKey] = value;
      }
    });

    return flat;
  }
}
