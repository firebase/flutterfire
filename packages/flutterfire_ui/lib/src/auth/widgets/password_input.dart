import 'package:flutter/material.dart';

class PasswordInput extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final void Function(String value) onSubmit;
  final String label;
  final String? Function(String? value) validator;

  const PasswordInput({
    Key? key,
    required this.focusNode,
    required this.controller,
    required this.onSubmit,
    required this.label,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      validator: validator,
      onFieldSubmitted: onSubmit,
    );
  }
}
