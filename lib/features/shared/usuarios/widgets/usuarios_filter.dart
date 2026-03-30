import 'package:flutter/material.dart';

class UsuariosFilter extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilter;
  final bool isMobile;

  const UsuariosFilter({
    super.key,
    required this.controller,
    required this.onFilter,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: isMobile ? 1 : 0,
          child: Container(
            width: isMobile ? double.infinity : 320,
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Buscar por e-mail...",
                prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 11),
              ),
              onSubmitted: (_) => onFilter(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 45,
          child: OutlinedButton(
            onPressed: onFilter,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Filtrar",
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}
