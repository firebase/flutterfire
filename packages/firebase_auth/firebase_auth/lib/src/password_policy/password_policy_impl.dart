// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:core';
import 'password_policy.dart';
import 'password_validation_status.dart';

class PasswordPolicyImpl {
  final PasswordPolicy _policy;

  PasswordPolicyImpl(this._policy);

  // Getter to access the policy
  PasswordPolicy get policy => _policy;

  PasswordValidationStatus isPasswordValid(String password) {
    PasswordValidationStatus status = PasswordValidationStatus(true, _policy);

    _validatePasswordLengthOptions(password, status);
    _validatePasswordCharacterOptions(password, status);

    return status;
  }

  void _validatePasswordLengthOptions(
    String password,
    PasswordValidationStatus status,
  ) {
    int minPasswordLength = _policy.minPasswordLength;
    int? maxPasswordLength = _policy.maxPasswordLength;

    status.meetsMinPasswordLength = password.length >= minPasswordLength;
    if (!status.meetsMinPasswordLength) {
      status.isValid = false;
    }
    if (maxPasswordLength != null) {
      status.meetsMaxPasswordLength = password.length <= maxPasswordLength;
      if (!status.meetsMaxPasswordLength) {
        status.isValid = false;
      }
    }
  }

  void _validatePasswordCharacterOptions(
    String password,
    PasswordValidationStatus status,
  ) {
    bool? requireLowercase = _policy.containsLowercaseCharacter;
    bool? requireUppercase = _policy.containsUppercaseCharacter;
    bool? requireDigits = _policy.containsNumericCharacter;
    bool? requireSymbols = _policy.containsNonAlphanumericCharacter;

    if (requireLowercase ?? false) {
      status.meetsLowercaseRequirement = password.contains(RegExp('[a-z]'));
      if (!status.meetsLowercaseRequirement) {
        status.isValid = false;
      }
    }
    if (requireUppercase ?? false) {
      status.meetsUppercaseRequirement = password.contains(RegExp('[A-Z]'));
      if (!status.meetsUppercaseRequirement) {
        status.isValid = false;
      }
    }
    if (requireDigits ?? false) {
      status.meetsDigitsRequirement = password.contains(RegExp('[0-9]'));
      if (!status.meetsDigitsRequirement) {
        status.isValid = false;
      }
    }
    if (requireSymbols ?? false) {
      // Check if password contains any non-alphanumeric characters
      bool hasSymbol = false;
      if (_policy.allowedNonAlphanumericCharacters.isNotEmpty) {
        // Check against allowed symbols
        for (final String symbol in _policy.allowedNonAlphanumericCharacters) {
          if (password.contains(symbol)) {
            hasSymbol = true;
            break;
          }
        }
      } else {
        // Check for any non-alphanumeric character
        hasSymbol = password.contains(RegExp('[^a-zA-Z0-9]'));
      }
      status.meetsSymbolsRequirement = hasSymbol;
      if (!hasSymbol) {
        status.isValid = false;
      }
    }
  }
}
