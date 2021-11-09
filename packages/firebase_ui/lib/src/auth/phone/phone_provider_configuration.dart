import 'package:firebase_ui/src/auth/auth_flow.dart';
import 'package:firebase_ui/src/auth/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_ui/src/auth/provider_configuration.dart';

import 'phone_auth_flow.dart';

class PhoneProviderConfiguration extends ProviderConfiguration {
  @override
  Type get controllerType => PhoneAuthController;

  @override
  AuthFlow createFlow(FirebaseAuth? auth, AuthAction? action) {
    return PhoneAuthFlow(auth: auth, action: action);
  }

  @override
  String get providerId => 'phone';
}
