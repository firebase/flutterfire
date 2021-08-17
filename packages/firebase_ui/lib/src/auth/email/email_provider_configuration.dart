import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/firebase_ui.dart';

import '../provider_configuration.dart';

class EmailProviderConfiguration extends ProviderConfiguration {
  final ActionCodeSettings actionCodeSettings;

  @override
  final providerId = 'password';

  @override
  final controllerType = EmailFlowController;

  EmailProviderConfiguration({required this.actionCodeSettings});

  @override
  AuthFlow createFlow(FirebaseAuth auth, AuthMethod method) {
    return EmailFlow(auth: auth, method: method);
  }
}
