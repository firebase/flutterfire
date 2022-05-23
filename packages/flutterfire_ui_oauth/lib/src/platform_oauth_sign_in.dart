import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

import 'oauth_provider.dart';

mixin PlatformSignInMixin {
  OAuthListener get authListener;
  ProviderArgs get desktopSignInArgs;
  dynamic get firebaseAuthProvider;

  OAuthCredential fromDesktopAuthResult(AuthResult result);
  void onCredentialReceived(OAuthCredential credential, AuthAction action);

  void platformSignIn(TargetPlatform platform, AuthAction action) {
    if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
      mobileSignIn(action);
    } else {
      desktopSignIn(action);
    }
  }

  void desktopSignIn(AuthAction action) {
    DesktopWebviewAuth.signIn(desktopSignInArgs).then((value) {
      if (value == null) throw AuthCancelledException();

      final oauthCredential = fromDesktopAuthResult(value);
      onCredentialReceived(oauthCredential, action);
    }).catchError((err) {
      if (err is AuthCancelledException) return;
      authListener.onError(err);
    });
  }

  void mobileSignIn(AuthAction action);
}
