import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookProvider extends OAuthProvider with SignOutMixin {
  @override
  final providerId = 'facebook.com';
  final provider = FacebookAuth.instance;
  final String clientId;
  final String redirectUri;

  @override
  late final ProviderArgs desktopSignInArgs = FacebookSignInArgs(
    clientId: clientId,
    redirectUri: redirectUri,
  );

  FacebookProvider({
    required this.clientId,
    required this.redirectUri,
  });

  @override
  Future<OAuthCredential> signIn() async {
    final result = await provider.login();

    switch (result.status) {
      case LoginStatus.success:
        final credential =
            FacebookAuthProvider.credential(result.accessToken!.token);

        return credential;
      case LoginStatus.cancelled:
        throw AuthCancelledException();
      case LoginStatus.failed:
        throw Exception(result.message);
      case LoginStatus.operationInProgress:
        throw Exception('Previous login request is not complete');
    }
  }

  @override
  OAuthCredential fromDesktopAuthResult(AuthResult result) {
    return FacebookAuthProvider.credential(result.accessToken!);
  }

  @override
  FacebookAuthProvider get firebaseAuthProvider => FacebookAuthProvider();

  @override
  Future<void> logOutProvider() async {
    await provider.logOut();
  }
}
