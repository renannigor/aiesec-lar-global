import 'package:flutter/services.dart';

/// Classe auxiliar para formatar data (DD/MM/AAAA) automaticamente
class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    // Se estiver apagando, permite livremente
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      // Adiciona barra após o dia e mês (ex: 12/ e 12/05/)
      if (nonZeroIndex <= 4 && nonZeroIndex % 2 == 0 && nonZeroIndex != 4) {
        if (i < text.length - 1 && text[i + 1] != '/') {
          buffer.write('/');
        }
      }
      // Correção para formato DD/MM/AAAA
      if (nonZeroIndex == 2 || nonZeroIndex == 4) {
        if (i < text.length - 1 && text[i + 1] != '/') {
          buffer.write('/');
        }
      }
    }

    // Limpa tudo que não é número
    var numbers = text.replaceAll(RegExp(r'[^0-9]'), '');
    var formatted = "";

    if (numbers.length >= 2) {
      formatted += "${numbers.substring(0, 2)}/";
      if (numbers.length >= 4) {
        formatted += "${numbers.substring(2, 4)}/";
        if (numbers.length >= 8) {
          formatted += numbers.substring(4, 8);
        } else {
          formatted += numbers.substring(4);
        }
      } else {
        formatted += numbers.substring(2);
      }
    } else {
      formatted = numbers;
    }

    // Limita tamanho
    if (formatted.length > 10) {
      formatted = formatted.substring(0, 10);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
