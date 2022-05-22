import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterfire_ui/auth.dart';

abstract class UniversalEmailSignInListener extends AuthListener {}

class UniversalEmailSignInProvider
    extends AuthProvider<UniversalEmailSignInListener, AuthCredential> {
  @override
  late UniversalEmailSignInListener authListener;

  @override
  String get providerId => 'universal_email_sign_in';

  @override
  bool supportsPlatform(TargetPlatform platform) {
    return true;
  }
}
