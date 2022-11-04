// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
  final Iterable<String> autofillHints;

  const PasswordInput({
    Key? key,
    required this.focusNode,
    required this.controller,
    required this.onSubmit,
    required this.label,
    this.autofillHints = const [AutofillHints.password],
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);

    return UniversalTextFormField(
      autofillHints: autofillHints,
      focusNode: focusNode,
      controller: controller,
      obscureText: true,
      enableSuggestions: false,
      validator: validator ?? NotEmpty(l.passwordIsRequiredErrorText).validate,
      onSubmitted: (v) => onSubmit(v!),
      placeholder: label,
    );
  }
}
