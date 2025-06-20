// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:core';
import 'dart:convert';

class PasswordPolicyImpl {
  final Map<String, dynamic> policy;

  // Backend enforced minimum
  final int MIN_PASSWORD_LENGTH = 6;

  final Map<String, dynamic> customStrengthOptions = {};
  late final String enforcementState;
  late final bool forceUpgradeOnSignin;
  late final int schemaVersion;
  late final List<String> allowedNonAlphanumericCharacters;

  PasswordPolicyImpl(this.policy) {
    _setParametersFromResponse();
  }

  void _setParametersFromResponse() {
    final responseOptions = policy['customStrengthOptions'] ?? {};

    customStrengthOptions['minPasswordLength'] = responseOptions['minPasswordLength'] ?? MIN_PASSWORD_LENGTH;
    if (responseOptions['maxPasswordLength'] != null) {
      customStrengthOptions['maxPasswordLength'] = responseOptions['maxPasswordLength'];
    }
    if (responseOptions['containsLowercaseCharacter'] != null) {
      customStrengthOptions['requireLowercase'] = responseOptions['containsLowercaseCharacter'];
    }
    if (responseOptions['containsUppercaseCharacter'] != null) {
      customStrengthOptions['requireUppercase'] = responseOptions['containsUppercaseCharacter'];
    }
    if (responseOptions['containsNumericCharacter'] != null) {
      customStrengthOptions['requireDigits'] = responseOptions['containsNumericCharacter'];
    }
    if (responseOptions['containsNonAlphanumericCharacter'] != null) {
      customStrengthOptions['requireSymbols'] = responseOptions['containsNonAlphanumericCharacter'];
    }

    enforcementState = policy['enforcementState'] == 'ENFORCEMENT_STATE_UNSPECIFIED'
        ? 'OFF'
        : policy['enforcementState'];

    allowedNonAlphanumericCharacters = responseOptions['allowedNonAlphanumericCharacters'] ?? [];

    forceUpgradeOnSignin = policy['forceUpgradeOnSignin'] ?? false;
    schemaVersion = policy['schemaVersion'];
  }

  Map<String,dynamic> isPasswordValid(String password) {
    Map<String,dynamic> status = {
      'status': true,
      'passwordPolicy': policy,
    };

    validatePasswordLengthOptions(password, status);
    validatePasswordCharacterOptions(password, status);

    return status;
  }

  void validatePasswordLengthOptions(String password, Map<String,dynamic> status) {
    int? minPasswordLength = customStrengthOptions['minPasswordLength'];
    int? maxPasswordLength = customStrengthOptions['maxPasswordLength'];

    if (minPasswordLength != null) {
      status['meetsMinPasswordLength'] = password.length >= minPasswordLength;
      if (!(status['meetsMinPasswordLength'] as bool)) {
        status['status'] = false;
      }
    }
    if (maxPasswordLength != null) {
      status['meetsMaxPasswordLength'] = password.length <= maxPasswordLength;
      if (!(status['meetsMaxPasswordLength'] as bool)) {
        status['status'] = false;
      }
    }
  }

  void validatePasswordCharacterOptions(String password, Map<String,dynamic> status) {
    bool? requireLowercase = customStrengthOptions['requireLowercase'];
    bool? requireUppercase = customStrengthOptions['requireUppercase'];
    bool? requireDigits = customStrengthOptions['requireDigits'];
    bool? requireSymbols = customStrengthOptions['requireSymbols'];

    if (requireLowercase == true) {
      status['meetsLowercaseRequirement'] = password.contains(RegExp(r'[a-z]'));
      if (!(status['meetsLowercaseRequirement'] as bool)) {
        status['status'] = false;
      }
    }
    if (requireUppercase == true) {
      status['meetsUppercaseRequirement'] = password.contains(RegExp(r'[A-Z]'));
      if (!(status['meetsUppercaseRequirement'] as bool)) {
        status['status'] = false;
      }
    }
    if (requireDigits == true) {
      status['meetsDigitsRequirement'] = password.contains(RegExp(r'[0-9]'));
      if (!(status['meetsDigitsRequirement'] as bool)) {
        status['status'] = false;
      }
    }
    if (requireSymbols == true) {
      // Check if password contains any non-alphanumeric characters
      bool hasSymbol = false;
      if (allowedNonAlphanumericCharacters.isNotEmpty) {
        // Check against allowed symbols
        for (String symbol in allowedNonAlphanumericCharacters) {
          if (password.contains(symbol)) {
            hasSymbol = true;
            break;
          }
        }
      } else {
        // Check for any non-alphanumeric character
        hasSymbol = password.contains(RegExp(r'[^a-zA-Z0-9]'));
      }
      status['meetsSymbolsRequirement'] = hasSymbol;
      if (!hasSymbol) {
        status['status'] = false;
      }
    }
  }
}
