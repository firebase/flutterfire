import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/src/auth/providers/platform_oauth_sign_in.dart';

class AuthCancelledException implements Exception {
  String get message => 'User has cancelled an auth';
}

abstract class OAuthListener extends AuthListener {}

abstract class OAuthProvider
    extends AuthProvider<OAuthListener, OAuthCredential>
    with PlatformSignInMixin {
  @override
  late OAuthListener authListener;

  void signIn(TargetPlatform platform) {
    authListener.onBeforeSignIn();
    platformSignIn(platform);
  }

  @override
  void platformSignIn(TargetPlatform platform);

  void signOut();
}
