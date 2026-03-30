import 'package:flutter/material.dart';

class MultiSelectChips extends StatelessWidget {
  final String labelText;
  final List<String> allOptions;
  final List<String> selectedOptions;
  final void Function(List<String>) onChanged;

  const MultiSelectChips({
    super.key,
    required this.labelText,
    required this.allOptions,
    required this.selectedOptions,
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: allOptions.map((option) {
            final isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                final newList = List<String>.from(selectedOptions);
                if (selected) {
                  newList.add(option);
                } else {
                  newList.remove(option);
                }
                onChanged(newList);
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
            );
          }).toList(),
        ),
      ],
    );
  }
}
