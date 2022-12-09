// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

import '../validators.dart';
import 'internal/universal_text_form_field.dart';

/// {@template ui.auth.widgets.password_input}
/// An input that allows to enter a password.
///
/// {@macro ui.auth.widgets.internal.universal_text_form_field}
/// {@endtemplate}
class PasswordInput extends StatelessWidget {
  /// Allows to control the focus state of the input.
  final FocusNode focusNode;

  /// Allows to respond to changes in the input's value.
  final TextEditingController controller;

  /// A callback that is being called when the input is submitted.
  final void Function(String value) onSubmit;

  /// A placeholder of the input's value.
  final String placeholder;

  /// Used to validate the input's value.
  ///
  /// Returned string will be shown as an error message.
  final String? Function(String? value)? validator;

  /// {@macro flutter.widgets.editableText.autofillHints}
  /// {@macro flutter.services.AutofillConfiguration.autofillHints}
  final Iterable<String> autofillHints;

  /// {@macro ui.auth.widgets.password_input}
  const PasswordInput({
    Key? key,
    required this.focusNode,
    required this.controller,
    required this.onSubmit,
    required this.placeholder,
    this.autofillHints = const [AutofillHints.password],
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return UniversalTextFormField(
      autofillHints: autofillHints,
      focusNode: focusNode,
      controller: controller,
      obscureText: true,
      enableSuggestions: false,
      validator: validator ?? NotEmpty(l.passwordIsRequiredErrorText).validate,
      onSubmitted: (v) => onSubmit(v!),
      placeholder: placeholder,
    );
  }
}
