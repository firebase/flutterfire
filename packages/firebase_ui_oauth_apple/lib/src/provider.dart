import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/foundation.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';

import 'theme.dart';

class AppleProvider extends OAuthProvider {
  @override
  final providerId = 'apple.com';

  @override
  final style = const AppleProviderButtonStyle();

  @override
  fba.AppleAuthProvider firebaseAuthProvider = fba.AppleAuthProvider();

  @override
  void mobileSignIn(AuthAction action) {
    authListener.onBeforeSignIn();

    auth.signInWithProvider(firebaseAuthProvider).then((userCred) {
      if (action == AuthAction.signIn) {
        authListener.onSignedIn(userCred);
      } else {
        authListener.onCredentialLinked(userCred.credential!);
      }
    }).catchError((err) {
      authListener.onError(err);
    });
  }

  @override
  void desktopSignIn(AuthAction action) {
    mobileSignIn(action);
  }

  @override
  ProviderArgs get desktopSignInArgs => throw UnimplementedError();

  @override
  fba.OAuthCredential fromDesktopAuthResult(AuthResult result) {
    throw UnimplementedError();
  }

  @override
  Future<void> logOutProvider() {
    return SynchronousFuture(null);
  }

  @override
  bool supportsPlatform(TargetPlatform platform) {
    return kIsWeb ||
        platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;
  }
}
