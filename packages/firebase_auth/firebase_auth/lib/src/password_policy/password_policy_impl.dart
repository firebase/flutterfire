// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';

class PasswordPolicyImpl {
  final Map<String,dynamic> _passwordPolicyApi;

  PasswordPolicyImpl(this._passwordPolicyApi);

  // Minimum length of the password which is enforced by the backend regardless or what is set or if there is none.
  final int MIN_LENGTH = 6;

  
}