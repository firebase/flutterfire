// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart' as e;

/// An abstract class for building composite input validators.
abstract class Validator {
  /// Error text that should be displayed if the valie is invalid.
  final String errorText;
  final List<Validator> _validators;

  Validator(this.errorText, List<Validator> children) : _validators = children;

  /// Triggers validation.
  String? validate(String? value);

  /// Triggers all children validators.
  @protected
  String? validateChildren(String? value) {
    for (final validator in _validators) {
      final error = validator.validate(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Returns a callback that could be used as a [TextFormField.validator].
  static String? Function(String?) validateAll(List<Validator> validators) {
    return CompositeValidator(validators).validate;
  }
}

/// A validator that doesn't have it's own logic and instead delegates
/// the validation to its children.
class CompositeValidator extends Validator {
  CompositeValidator(List<Validator> children) : super('', children);

  @override
  String? validate(String? value) {
    return validateChildren(value);
  }
}

/// Validates that the input is not a null and not an empty string.
class NotEmpty extends Validator {
  NotEmpty(String errorText) : super(errorText, []);

  @override
  String? validate(String? value) {
    return (value == null || value.isEmpty) ? errorText : null;
  }
}

/// Validates an email.
class EmailValidator extends Validator {
  EmailValidator(String errorText) : super(errorText, []);

  @override
  String? validate(String? value) {
    if (value == null) return errorText;
    return e.EmailValidator.validate(value) ? null : errorText;
  }
}

/// Validates that the passwords match.
class ConfirmPasswordValidator extends Validator {
  final TextEditingController controller;

  ConfirmPasswordValidator(
    this.controller,
    String errorText,
  ) : super(errorText, []);

  @override
  String? validate(String? value) {
    return value == controller.text ? null : errorText;
  }
}

/// Validates phone number.
/// Should be used together with the [NotEmpty] and
/// [FilteringTextInputFormatter.digitsOnly].
class PhoneValidator extends Validator {
  PhoneValidator(String errorText) : super(errorText, []);

  @override
  String? validate(String? value) {
    return value!.length < 7 ? errorText : null;
  }
}
