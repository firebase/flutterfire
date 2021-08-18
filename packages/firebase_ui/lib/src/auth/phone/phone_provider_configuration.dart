import 'package:firebase_ui/firebase_ui.dart';
import 'package:firebase_ui/src/auth/auth_flow.dart';
import 'package:firebase_ui/src/auth/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/src/auth/provider_configuration.dart';

class PhoneProviderConfiguration extends ProviderConfiguration {
  @override
  Type get controllerType => PhoneVerificationController;

  @override
  AuthFlow createFlow(FirebaseAuth auth, AuthMethod method) {
    return PhoneVerificationAuthFlow(auth: auth, method: method);
  }

  @override
  String get providerId => 'phone';
}
