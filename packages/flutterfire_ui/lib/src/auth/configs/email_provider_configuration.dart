// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../auth_controller.dart';
import '../auth_flow.dart';
import 'provider_configuration.dart';
import '../flows/email_flow.dart';

const EMAIL_PROVIDER_ID = 'password';

class EmailProviderConfiguration extends ProviderConfiguration {
  @override
  String get providerId => EMAIL_PROVIDER_ID;

  const EmailProviderConfiguration();

  @override
  AuthFlow createFlow(FirebaseAuth? auth, AuthAction? action) {
    return EmailFlow(auth: auth, action: action, config: this);
  }

  @override
  bool isSupportedPlatform(TargetPlatform platform) {
    return true;
  }
}
