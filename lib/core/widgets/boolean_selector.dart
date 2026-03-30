import 'package:flutter/material.dart';

class BooleanSelector extends StatelessWidget {
  final String labelText;
  final bool? value; // True = Sim, False = Não, Null = Não selecionado
  final void Function(bool) onChanged;

  const BooleanSelector({
    super.key,
    required this.labelText,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(color: Colors.grey[700], fontSize: 16),
        ),
        // O RadioGroup agora gerencia o valor selecionado e a função de troca
        RadioGroup<bool>(
          groupValue: value,
          onChanged: (newValue) {
            // Garante que não passamos nulo se sua lógica exigir bool não-nulo
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          child: Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text("Sim"),
                  value: true, // Apenas o valor DESTE item
                  // groupValue e onChanged foram removidos daqui
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text("Não"),
                  value: false, // Apenas o valor DESTE item
                  // groupValue e onChanged foram removidos daqui
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
