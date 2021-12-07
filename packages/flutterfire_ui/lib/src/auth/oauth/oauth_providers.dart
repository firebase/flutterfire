import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class OAuthProvider {
  Future<OAuthCredential> signIn();

  ProviderArgs get desktopSignInArgs;
  dynamic get firebaseAuthProvider;
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

extension OAuthHelpers on User {
  bool isProviderLinked(String providerId) {
    try {
      providerData.firstWhere((e) => e.providerId == providerId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
