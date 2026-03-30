import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Editor extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;

  // NOVO: Necessário para detectar o "Enter" no teclado
  final void Function(String)? onFieldSubmitted;

  final bool enabled;

  const Editor({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    required this.isPassword,
    required this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.onChanged,
    this.onFieldSubmitted, // Adicione aqui no construtor
    required this.enabled,
  });

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,

      // Conecta o callback aqui
      onFieldSubmitted: widget.onFieldSubmitted,

      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        filled: !widget.enabled,
        fillColor: Colors.grey.shade200,
        border: const OutlineInputBorder(),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon,
      ),
    );
  }
}
