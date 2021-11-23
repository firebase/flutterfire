import 'package:flutter/material.dart';
import 'package:flutterfire_ui/i10n.dart';

import '../validators.dart';

class EmailInput extends StatelessWidget {
  final FocusNode? focusNode;
  final bool? autofocus;
  final TextEditingController controller;
  final void Function(String value) onSubmitted;

  const EmailInput({
    Key? key,
    required this.controller,
    required this.onSubmitted,
    this.focusNode,
    this.autofocus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return TextFormField(
      autofocus: autofocus ?? false,
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(labelText: l.emailInputLabel),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      validator: Validator.validateAll([
        NotEmpty(l.accessDisabledErrorText),
        EmailValidator(l.isNotAValidEmailErrorText),
      ]),
      onFieldSubmitted: onSubmitted,
    );
  }
}
