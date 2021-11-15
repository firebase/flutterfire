import 'package:firebase_auth/firebase_auth.dart';

import '../auth_controller.dart';
import '../auth_flow.dart';
import '../provider_configuration.dart';
import '../flows/email_flow.dart';

const EMAIL_PROVIDER_ID = 'password';

class EmailProviderConfiguration extends ProviderConfiguration {
  final ActionCodeSettings? actionCodeSettings;

  @override
  final providerId = EMAIL_PROVIDER_ID;

  EmailProviderConfiguration({this.actionCodeSettings});

  @override
  AuthFlow createFlow(FirebaseAuth? auth, AuthAction? action) {
    return EmailFlow(auth: auth, action: action, config: this);
  }
}
