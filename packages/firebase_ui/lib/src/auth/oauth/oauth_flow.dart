import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:firebase_ui/firebase_ui.dart';
import 'package:firebase_ui/src/auth/oauth/oauth_provider_configuration.dart';
import 'package:firebase_ui/src/auth/oauth/oauth_providers.dart';

import '../auth_state.dart';

class Uninitialized extends AuthState {
  const Uninitialized();
}

abstract class OAuthController extends AuthController {
  Future<void> signInWithProvider<T extends OAuthProvider>();
}

class OAuthFlow extends AuthFlow implements OAuthController {
  OAuthFlow({
    required AuthAction action,
    required FirebaseAuth auth,
  }) : super(action: action, auth: auth, initialState: const Uninitialized());

  @override
  Future<void> signInWithProvider<T extends OAuthProvider>() async {
    final initializer = resolveInitializer<FirebaseUIAuthInitializer>();
    final config =
        initializer.configOf<OAuthProviderConfiguration>(providerIdOf<T>());
    final provider = config.createProvider();

    value = const SigningIn();
    final oauthCredential = await provider.signIn();

    setCredential(oauthCredential);
  }
}
