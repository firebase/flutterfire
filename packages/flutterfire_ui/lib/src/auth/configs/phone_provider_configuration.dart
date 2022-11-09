// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../auth_flow.dart';
import '../auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import '../configs/provider_configuration.dart';
import 'package:flutter/foundation.dart';

import '../flows/phone_auth_flow.dart';

class PhoneProviderConfiguration extends ProviderConfiguration {
  const PhoneProviderConfiguration();

  @override
  AuthFlow createFlow(FirebaseAuth? auth, AuthAction? action) {
    return PhoneAuthFlow(auth: auth, action: action);
  }

  @override
  String get providerId => 'phone';

  @override
  bool isSupportedPlatform(TargetPlatform platform) {
    return platform == TargetPlatform.iOS ||
        platform == TargetPlatform.android ||
        kIsWeb;
  }
}
