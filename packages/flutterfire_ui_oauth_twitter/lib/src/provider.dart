import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutter/foundation.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';
import 'package:twitter_login/twitter_login.dart';

class TwitterProvider extends OAuthProvider with SignOutMixin {
  @override
  final providerId = 'twitter.com';
  final String apiKey;
  final String apiSecretKey;
  final String redirectUri;

  @override
  late final desktopSignInArgs = TwitterSignInArgs(
    apiKey: apiKey,
    apiSecretKey: apiSecretKey,
    redirectUri: redirectUri,
  );

  late final _provider = TwitterLogin(
    apiKey: apiKey,
    apiSecretKey: apiSecretKey,
    redirectURI: redirectUri,
  );

  TwitterProvider({
    required this.apiKey,
    required this.apiSecretKey,
    required this.redirectUri,
  });

  @override
  Future<OAuthCredential> signInProvider() async {
    final result = await _provider.login();

    switch (result.status) {
      case null:
        throw Exception('Unknown sign in result');
      case TwitterLoginStatus.loggedIn:
        return TwitterAuthProvider.credential(
          accessToken: result.authToken!,
          secret: result.authTokenSecret!,
        );
      case TwitterLoginStatus.cancelledByUser:
        throw AuthCancelledException();
      case TwitterLoginStatus.error:
        throw Exception(result.errorMessage);
    }
  }

  @override
  OAuthCredential fromDesktopAuthResult(AuthResult result) {
    return TwitterAuthProvider.credential(
      accessToken: result.accessToken!,
      secret: result.tokenSecret!,
    );
  }

  @override
  TwitterAuthProvider get firebaseAuthProvider => TwitterAuthProvider();

  @override
  Future<void> logOutProvider() {
    return SynchronousFuture(null);
  }
}
