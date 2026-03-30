import 'package:flutter/material.dart';

class Selector<T> extends StatelessWidget {
  final String labelText;
  final T? value;
  final List<T> items;
  final void Function(T?)? onChanged; // Pode ser nulo se enabled = false
  final String? Function(T?)? validator;
  final bool enabled;
  final String Function(T)? itemLabelBuilder;

  const Selector({
    super.key,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
    this.enabled = true,
    this.itemLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: (value != null && items.contains(value)) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: labelText,
        filled: !enabled,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: const OutlineInputBorder(),
      ),
      items: items.map((T item) {
        final String text = itemLabelBuilder != null
            ? itemLabelBuilder!(item)
            : item.toString();

        return DropdownMenuItem<T>(
          value: item,
          child: Text(text, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );
  }
}
