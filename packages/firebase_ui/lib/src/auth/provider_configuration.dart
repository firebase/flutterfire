import 'package:firebase_auth/firebase_auth.dart';

import 'auth_controller.dart' show AuthMethod;
import 'auth_flow.dart';

abstract class ProviderConfiguration {
  String get providerId;
  Type get controllerType;

  AuthFlow createFlow(FirebaseAuth auth, AuthMethod method);
}
