import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

/// {@template ffui.auth.views.reauthenticate_view}
/// A view that could be used to build a custom [ReauthenticateDialog].
/// {@endtemplate}
class ReauthenticateView extends StatelessWidget {
  /// {@macro ffui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// A list of all supported auth providers.
  final List<AuthProvider> providers;

  /// A callback that is being called when the user has successfuly signed in.
  final VoidCallback? onSignedIn;

  /// {@macro ffui.auth.views.reauthenticate_view}
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
