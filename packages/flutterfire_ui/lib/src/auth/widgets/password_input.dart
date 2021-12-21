import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/i10n.dart';

import '../validators.dart';
import 'internal/universal_text_form_field.dart';

class PasswordInput extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final void Function(String value) onSubmit;
  final String label;
  final String? Function(String? value)? validator;
  final bool newPassword;

  const PasswordInput({
    Key? key,
    required this.focusNode,
    required this.controller,
    required this.onSubmit,
    required this.label,
    this.newPassword = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);

    return UniversalTextFormField(
      autofillHints:
          newPassword ? [AutofillHints.newPassword] : [AutofillHints.password],
      focusNode: focusNode,
      controller: controller,
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      validator: validator ?? NotEmpty(l.passwordIsRequiredErrorText).validate,
      onSubmitted: (v) => onSubmit(v!),
      placeholder: label,
    );
  }
}
