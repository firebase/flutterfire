import 'package:flutterfire_ui/src/auth/auth_flow.dart';
import 'package:flutterfire_ui/src/auth/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutterfire_ui/src/auth/configs/provider_configuration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/foundation/platform.dart';

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
