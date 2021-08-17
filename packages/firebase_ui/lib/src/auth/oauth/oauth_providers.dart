import 'package:firebase_auth/firebase_auth.dart';

import 'provider_resolvers.dart';

abstract class OAuthProvider {
  Future<OAuthCredential> signIn();

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

enum OAuthProviders {
  google,
  apple,
  twitter,
  facebook,
}

abstract class Google extends OAuthProvider {}

abstract class Apple extends OAuthProvider {}

abstract class Twitter extends OAuthProvider {}

abstract class Facebook extends OAuthProvider {}

extension OAuthHelpers on User {
  bool isProviderLinked<T extends OAuthProvider>() {
    try {
      providerData.firstWhere((e) => e.providerId == providerIdOf<T>());
      return true;
    } catch (_) {
      return false;
    }
  }
}
