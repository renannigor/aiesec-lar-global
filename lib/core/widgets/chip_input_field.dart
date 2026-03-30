import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/core/widgets/editor.dart';

class ChipInputField extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> items;
  final ValueChanged<List<String>> onChanged;

  const ChipInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  State<ChipInputField> createState() => _ChipInputFieldState();
}

class _ChipInputFieldState extends State<ChipInputField> {
  final TextEditingController _controller = TextEditingController();

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      if (!widget.items.contains(text)) {
        final newList = List<String>.from(widget.items)..add(text);
        widget.onChanged(newList);
      }
      _controller.clear();
    }
  }

  void _removeItem(String item) {
    final newList = List<String>.from(widget.items)..remove(item);
    widget.onChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de Texto
        Editor(
          controller: _controller,
          labelText: widget.label,
          hintText: widget.hint,
          isPassword: false,
          keyboardType: TextInputType.text,
          enabled: true,
          onFieldSubmitted: (_) => _addItem(),
        ),

        // Botão "Adicionar" alinhado à direita
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: FilledButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Adicionar"),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                visualDensity: VisualDensity.compact, // Botão mais compacto
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),

        // Lista de Chips
        if (widget.items.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: widget.items.map((item) {
                return Chip(
                  label: Text(item),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeItem(item),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
