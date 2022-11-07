// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:email_validator/email_validator.dart' as e;

abstract class Validator {
  final String errorText;
  List<Validator> _validators;

  Validator(this.errorText, List<Validator> children) : _validators = children;

  String? validate(String? value);

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

  static String? Function(String?) validateAll(List<Validator> validators) {
    return CompositeValidator(validators).validate;
  }
}

class CompositeValidator extends Validator {
  CompositeValidator(List<Validator> children) : super('', children);

  @override
  String? validate(String? value) {
    return validateChildren(value);
  }
}

class NotEmpty extends Validator {
  NotEmpty(String errorText) : super(errorText, []);

  @override
  String? validate(String? value) {
    return (value == null || value.isEmpty) ? errorText : null;
  }
}

class EmailValidator extends Validator {
  EmailValidator(String errorText) : super(errorText, []);

  @override
  String? validate(String? value) {
    if (value == null) return errorText;
    return e.EmailValidator.validate(value) ? null : errorText;
  }
}

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

class PhoneValidator extends Validator {
  PhoneValidator(String errorText) : super(errorText, []);

  @override
  String? validate(String? value) {
    return value!.length < 7 ? errorText : null;
  }
}
