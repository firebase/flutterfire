import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../auth_controller.dart' show AuthAction;
import '../auth_flow.dart';

abstract class ProviderConfiguration {
  const ProviderConfiguration();
  String get providerId;
  AuthFlow createFlow(FirebaseAuth? auth, AuthAction? action);
  bool isSupportedPlatform(TargetPlatform platform);
}
