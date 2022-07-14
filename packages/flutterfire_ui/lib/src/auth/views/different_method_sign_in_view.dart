import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

/// {@template ffui.auth.views.different_method_sign_in_view}
/// A view that renders a list of providers that were previously used by the
/// user to authenticate.
/// {@endtemplate}
class DifferentMethodSignInView extends StatelessWidget {
  /// {@macro ffui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// A list of all providers that were previously used to authenticate.
  final List<String> availableProviders;

  /// A list of all supported auth providers.
  final List<AuthProvider> providers;

  /// A callback that is being called when the user has signed in using on of
  /// the [availableProviders].
  final VoidCallback? onSignedIn;

  /// {@macro ffui.auth.views.different_method_sign_in_view}
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
