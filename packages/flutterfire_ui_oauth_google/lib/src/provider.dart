import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleProvider extends OAuthProvider with SignOutMixin {
  @override
  final providerId = 'google.com';
  final String clientId;
  final String redirectUri;
  final List<String> scopes;

  late final _provider = GoogleSignIn(scopes: scopes);

  @override
  final GoogleAuthProvider firebaseAuthProvider = GoogleAuthProvider();

  @override
  late final desktopSignInArgs = GoogleSignInArgs(
    clientId: clientId,
    redirectUri: redirectUri,
    scope: scopes.join(' '),
  );

  GoogleProvider({
    required this.clientId,
    required this.redirectUri,
    this.scopes = const [],
  }) {
    firebaseAuthProvider.setCustomParameters(const {
      'prompt': 'select_account',
    });
  }

  @override
  Future<OAuthCredential> signIn() async {
    final user = await _provider.signIn();

    if (user == null) {
      throw Exception('Auth failed');
    }

    final auth = await user.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    return credential;
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
    await provider.signOut();
  }
}
