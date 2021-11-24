import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'provider_resolvers.dart';

abstract class OAuthProvider {
  Future<OAuthCredential> signIn();

  ProviderArgs get desktopSignInArgs;
  OAuthCredential fromDesktopAuthResult(AuthResult result);

  Future<OAuthCredential> desktopSignIn() async {
    final result = await DesktopWebviewAuth.signIn(desktopSignInArgs);

    if (result == null) {
      throw Exception('Sign in failed');
    }

    final credential = fromDesktopAuthResult(result);
    return credential;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
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
