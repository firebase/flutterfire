import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

mixin PlatformSignInMixin {
  OAuthListener get authListener;
  ProviderArgs get desktopSignInArgs;
  dynamic get firebaseAuthProvider;
  AuthAction get action;

  OAuthCredential fromDesktopAuthResult(AuthResult result);
  void onCredentialReceived(AuthCredential credential, AuthAction action);

  void platformSignIn(TargetPlatform platform) {
    if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
      mobileSignIn();
    } else {
      desktopSignIn();
    }
  }

  void desktopSignIn() {
    DesktopWebviewAuth.signIn(desktopSignInArgs).then((value) {
      if (value == null) throw AuthCancelledException();

      final oauthCredential = fromDesktopAuthResult(value);
      onCredentialReceived(oauthCredential, action);
    }).catchError((err) {
      if (err is AuthCancelledException) return;
      authListener.onError(err);
    });
  }

  void mobileSignIn();
}
