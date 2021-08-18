import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/firebase_ui.dart';

import '../provider_configuration.dart';

const EMAIL_PROVIDER_ID = 'password';

class EmailProviderConfiguration extends ProviderConfiguration {
  final ActionCodeSettings actionCodeSettings;

  @override
  final providerId = EMAIL_PROVIDER_ID;

  @override
  final controllerType = EmailFlowController;

  EmailProviderConfiguration({required this.actionCodeSettings});

  @override
  AuthFlow createFlow(FirebaseAuth auth, AuthMethod method) {
    return EmailFlow(auth: auth, method: method);
  }
}
