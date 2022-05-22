import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

class ReauthenticateView extends StatelessWidget {
  final FirebaseAuth? auth;
  final List<AuthProvider> providers;
  final VoidCallback? onSignedIn;

  const ReauthenticateView({
    Key? key,
    required this.providers,
    this.auth,
    this.onSignedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _linkedProviders =
        (auth ?? FirebaseAuth.instance).currentUser!.providerData;

    final providersMap = providers.fold<Map<String, AuthProvider>>(
      {},
      (map, provider) {
        return {
          ...map,
          provider.providerId: provider,
        };
      },
    );

    List<AuthProvider> _providers = [];

    for (final p in _linkedProviders) {
      final provider = providersMap[p.providerId];

      if (provider != null) {
        _providers.add(provider);
      }
    }

    return AuthStateListener(
      child: LoginView(
        action: AuthAction.signIn,
        providers: _providers,
        showTitle: false,
      ),
      listener: (oldState, newState, ctrl) {
        if (newState is SignedIn) {
          onSignedIn?.call();
        }

        return false;
      },
    );
  }
}
