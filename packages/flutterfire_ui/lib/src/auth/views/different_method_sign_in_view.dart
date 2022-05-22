import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

class DifferentMethodSignInView extends StatelessWidget {
  final FirebaseAuth? auth;
  final List<String> availableProviders;
  final List<AuthProvider> providers;
  final VoidCallback? onSignedIn;

  const DifferentMethodSignInView({
    Key? key,
    required this.availableProviders,
    required this.providers,
    this.auth,
    this.onSignedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final providersMap = providers.fold<Map<String, AuthProvider>>(
      {},
      (map, config) {
        return {
          ...map,
          config.providerId: config,
        };
      },
    );

    List<AuthProvider> _providers = [];

    for (final p in availableProviders) {
      final providerConfig = providersMap[p];
      if (providerConfig != null) {
        _providers.add(providerConfig);
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
