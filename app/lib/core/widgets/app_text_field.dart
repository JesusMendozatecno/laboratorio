import 'package:flutter/material.dart';

/// Campo de texto estilizado reutilizable.
///
/// Toma el estilo (fondo, borde, foco, error) del tema global, por lo que se
/// adapta automáticamente a la marca y al modo claro/oscuro.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.textInputAction,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.minLines,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final int? minLines;
  final TextCapitalization textCapitalization;
  final bool autocorrect;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      minLines: minLines,
      textCapitalization: textCapitalization,
      autocorrect: autocorrect,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: '',
      ),
    );
  }
}