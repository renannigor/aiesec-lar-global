import 'package:flutter/material.dart';

class NpsFilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final Function(String?) onChanged;
  final bool isMobile;

  const NpsFilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      label,
      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
    );

    final dropdownWidget = Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: isMobile, // Expande tudo no mobile
          value: value,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          icon: const Icon(Icons.arrow_drop_down, size: 18),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );

    // Se for mobile, empilha. Se for desktop, coloca lado a lado.
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [titleWidget, const SizedBox(height: 4), dropdownWidget],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [titleWidget, const SizedBox(width: 8), dropdownWidget],
      );
    }
  }
}
