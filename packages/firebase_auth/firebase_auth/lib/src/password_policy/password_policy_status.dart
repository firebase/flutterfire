// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'password_policy.dart';

class PasswordPolicyStatus {
  bool status;
  final PasswordPolicy passwordPolicy;

  // Initialize all fields to true by default (meaning they pass validation)
  bool meetsMinPasswordLength = true;
  bool meetsMaxPasswordLength = true;
  bool meetsLowercaseRequirement = true;
  bool meetsUppercaseRequirement = true;
  bool meetsDigitsRequirement = true;
  bool meetsSymbolsRequirement = true;

  PasswordPolicyStatus(this.status, this.passwordPolicy);
}
