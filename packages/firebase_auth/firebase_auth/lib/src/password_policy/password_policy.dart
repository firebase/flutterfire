// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
class PasswordPolicy {
  final Map<String, dynamic> policy;

  // Backend enforced minimum
  late final int minPasswordLength;
  late final int? maxPasswordLength;
  late final bool? containsLowercaseCharacter;
  late final bool? containsUppercaseCharacter;
  late final bool? containsNumericCharacter;
  late final bool? containsNonAlphanumericCharacter;
  late final int schemaVersion;
  late final List<String> allowedNonAlphanumericCharacters;
  late final String enforcementState;

  PasswordPolicy(this.policy) {
    initialize();
  }

  void initialize() {
    final Map<String, dynamic> customStrengthOptions =
        policy['customStrengthOptions'] ?? {};

    minPasswordLength = customStrengthOptions['minPasswordLength'] ?? 6;
    maxPasswordLength = customStrengthOptions['maxPasswordLength'];
    containsLowercaseCharacter =
        customStrengthOptions['containsLowercaseCharacter'];
    containsUppercaseCharacter =
        customStrengthOptions['containsUppercaseCharacter'];
    containsNumericCharacter =
        customStrengthOptions['containsNumericCharacter'];
    containsNonAlphanumericCharacter =
        customStrengthOptions['containsNonAlphanumericCharacter'];

    schemaVersion = policy['schemaVersion'] ?? 1;
    allowedNonAlphanumericCharacters = List<String>.from(
      policy['allowedNonAlphanumericCharacters'] ??
          customStrengthOptions['allowedNonAlphanumericCharacters'] ??
          [],
    );

    final enforcement = policy['enforcement'] ?? policy['enforcementState'];
    enforcementState = enforcement == 'ENFORCEMENT_STATE_UNSPECIFIED'
        ? 'OFF'
        : (enforcement ?? 'OFF');
  }
}
