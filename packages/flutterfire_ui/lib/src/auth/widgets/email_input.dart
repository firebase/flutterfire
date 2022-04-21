import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterfire_ui/i10n.dart';
import '../widgets/internal/universal_text_form_field.dart';

import '../validators.dart';

final _whitespaceRegExp = RegExp(r'\s\b|\b\s');

class EmailInput extends StatelessWidget {
  final FocusNode? focusNode;
  final bool? autofocus;
  final TextEditingController controller;
  final String? initialValue;
  final void Function(String value) onSubmitted;

  const EmailInput({
    Key? key,
    required this.controller,
    required this.onSubmitted,
    this.focusNode,
    this.autofocus,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);

    return UniversalTextFormField(
      autofillHints: const [AutofillHints.email],
      autofocus: autofocus ?? false,
      focusNode: focusNode,
      controller: controller,
      placeholder: l.emailInputLabel,
      keyboardType: TextInputType.emailAddress,
      inputFormatters: [FilteringTextInputFormatter.deny(_whitespaceRegExp)],
      validator: Validator.validateAll([
        NotEmpty(l.emailIsRequiredErrorText),
        EmailValidator(l.isNotAValidEmailErrorText),
      ]),
      onSubmitted: (v) => onSubmitted(v!),
    );
  }
}
