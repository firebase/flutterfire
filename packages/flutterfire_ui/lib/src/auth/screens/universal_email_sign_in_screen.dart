import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/src/auth/screens/internal/multi_provider_screen.dart';

import '../widgets/internal/universal_page_route.dart';
import '../widgets/internal/universal_scaffold.dart';

class UniversalEmailSignInScreen extends MultiProviderScreen {
  final ProvidersFoundCallback? onProvidersFound;
  final Set<FlutterFireUIStyle>? styles;

  const UniversalEmailSignInScreen({
    Key? key,
    FirebaseAuth? auth,
    List<AuthProvider>? providers,
    this.onProvidersFound,
    this.styles,
  })  : assert(onProvidersFound != null || providers != null),
        super(key: key, auth: auth, providers: providers);

  Widget _wrap(BuildContext context, Widget child) {
    return AuthStateListener(
      child: FlutterFireUIActions.inherit(
        from: context,
        child: child,
      ),
      listener: (_, newState, controller) {
        if (newState is SignedIn) {
          Navigator.of(context).pop();
        }
        return null;
      },
    );
  }

  void _defaultAction(
    BuildContext context,
    String email,
    List<String> providerIds,
  ) {
    late Route route;

    if (providerIds.isEmpty) {
      route = createPageRoute(
        context: context,
        builder: (context) => _wrap(
          context,
          RegisterScreen(
            showAuthActionSwitch: false,
            providers: providers,
            auth: auth,
            email: email,
          ),
        ),
      );
    } else {
      final List<AuthProvider> finalProviders = [];
      final providersSet = Set.from(providers);

      for (final p in providers) {
        if (providersSet.contains(p.providerId)) {
          finalProviders.add(p);
        }
      }

      route = createPageRoute(
        context: context,
        builder: (context) => _wrap(
          context,
          SignInScreen(
            showAuthActionSwitch: false,
            providers: finalProviders,
            auth: auth,
            email: email,
          ),
        ),
      );
    }

    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    final content = FindProvidersForEmailView(
      onProvidersFound: onProvidersFound ??
          (email, providers) => _defaultAction(context, email, providers),
    );

    return FlutterFireUITheme(
      styles: styles ?? const {},
      child: UniversalScaffold(
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.biggest.width < 500) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: content,
                );
              } else {
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: content,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
