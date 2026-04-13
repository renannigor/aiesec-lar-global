import 'package:flutter/material.dart';

class Selector<T> extends StatelessWidget {
  final String? labelText;
  final T? value;
  final List<T> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final String Function(T)? itemLabelBuilder;
  final bool isFilter;

  const Selector({
    super.key,
    this.labelText,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
    this.enabled = true,
    this.itemLabelBuilder,
    this.isFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: (value != null && items.contains(value)) ? value : null,
      isExpanded: true,
      icon: isFilter
          ? Icon(Icons.arrow_drop_down, color: Colors.grey.shade700)
          : null,
      decoration: InputDecoration(
        labelText: labelText, // Pode ser null na tabela
        labelStyle: isFilter
            ? TextStyle(color: Colors.grey.shade700, fontSize: 14)
            : null,
        filled: !enabled,
        fillColor: isFilter ? Colors.grey.shade100 : Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),

        border: isFilter
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
              )
            : const OutlineInputBorder(),

        enabledBorder: isFilter
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
              )
            : null,

        focusedBorder: isFilter
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.blue, width: 1.0),
              )
            : null,
      ),
      items: items.map((T item) {
        final String text = itemLabelBuilder != null
            ? itemLabelBuilder!(item)
            : item.toString();

        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: isFilter
                ? const TextStyle(fontSize: 14, color: Colors.black87)
                : null,
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );
  }
}
