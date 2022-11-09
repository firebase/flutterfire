import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutter/foundation.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleProvider extends OAuthProvider {
  @override
  final providerId = 'google.com';
  final String clientId;
  final String? redirectUri;
  final List<String>? scopes;

  late GoogleSignIn provider = GoogleSignIn(scopes: scopes ?? []);

  @override
  final GoogleAuthProvider firebaseAuthProvider = GoogleAuthProvider();

  @override
  late final desktopSignInArgs = GoogleSignInArgs(
    clientId: clientId,
    redirectUri: redirectUri ?? defaultRedirectUri,
    scope: scopes != null
        ? scopes!.join(' ')
        : 'https://www.googleapis.com/auth/plus.login',
  );

  GoogleProvider({
    required this.clientId,
    this.redirectUri,
    this.scopes,
  }) {
    firebaseAuthProvider.setCustomParameters(const {
      'prompt': 'select_account',
    });
  }

  @override
  void mobileSignIn(AuthAction action) async {
    provider.signIn().then((user) {
      if (user == null) throw AuthCancelledException();
      return user.authentication;
    }).then((auth) {
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      onCredentialReceived(credential, action);
    }).catchError((err) {
      authListener.onError(err);
    });
  }

  @override
  OAuthCredential fromDesktopAuthResult(AuthResult result) {
    return GoogleAuthProvider.credential(
      idToken: result.idToken,
      accessToken: result.accessToken,
    );
  }

  @override
  Future<void> logOutProvider() async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await provider.signOut();
    }
  }

  @override
  final style = const GoogleProviderButtonStyle();

  @override
  bool supportsPlatform(TargetPlatform platform) {
    return true;
  }
}
