// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import '../widgets/internal/universal_text_form_field.dart';

import '../validators.dart';

final _whitespaceRegExp = RegExp(r'\s\b|\b\s');

/// {@template ui.auth.widget.email_input}
/// An input that allows to enter an email address.
///
/// Takes care of email validation.
/// {@macro ui.auth.widgets.internal.universal_text_form_field}
/// {@endtemplate}
class EmailInput extends StatelessWidget {
  /// A focus node that might be used to control the focus of the input.
  final FocusNode? focusNode;

  /// Whether the input should have a focus when rendered.
  final bool? autofocus;

  /// A [TextEditingController] that might be used to track input's value
  /// changes.
  final TextEditingController controller;

  /// An initial value that input should be pre-filled with.
  final String? initialValue;

  /// A callback that is being called when the input is submitted.
  final void Function(String value) onSubmitted;

  /// {@macro ui.auth.widget.email_input}
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
    final l = FirebaseUILocalizations.labelsOf(context);

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
