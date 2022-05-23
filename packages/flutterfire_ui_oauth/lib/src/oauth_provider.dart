import 'package:flutter/foundation.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';

import 'platform_oauth_sign_in.dart'
    if (dart.library.html) 'platform_oauth_sign_in_web.dart';

class AuthCancelledException implements Exception {
  String get message => 'User has cancelled an auth';
}

abstract class OAuthListener extends AuthListener {}

abstract class OAuthProvider
    extends AuthProvider<OAuthListener, OAuthCredential>
    with PlatformSignInMixin {
  @override
  late OAuthListener authListener;

  ThemedOAuthProviderButtonStyle get style;

  String get defaultRedirectUri =>
      'https://${auth.app.options.projectId}.firebaseapp.com/__/auth/handler';

  void signIn(TargetPlatform platform, AuthAction action) {
    authListener.onBeforeSignIn();
    platformSignIn(platform, action);
  }

  @override
  void platformSignIn(TargetPlatform platform, AuthAction action);

  Future<void> logOutProvider();
}
