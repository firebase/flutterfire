// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import '../widgets/internal/universal_page_route.dart';
import '../widgets/internal/universal_scaffold.dart';
import 'internal/multi_provider_screen.dart';

/// A screen that allows to resolve previously used providers for a given email.
class UniversalEmailSignInScreen extends MultiProviderScreen {
  /// A callback that is being called when providers fetch request completed.
  final ProvidersFoundCallback? onProvidersFound;

  const UniversalEmailSignInScreen({
    Key? key,

    /// {@macro ui.auth.auth_controller.auth}
    FirebaseAuth? auth,

    /// A list of all supported auth providers
    List<AuthProvider>? providers,
    this.onProvidersFound,
  })  : assert(onProvidersFound != null || providers != null),
        super(key: key, auth: auth, providers: providers);

  Widget _wrap(BuildContext context, Widget child) {
    return AuthStateListener(
      child: FirebaseUIActions.inherit(
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
      final providersMap = providers.fold<Map<String, AuthProvider>>(
        {},
        (acc, element) {
          return {
            ...acc,
            element.providerId: element,
          };
        },
      );

      final authorizedProviders = providerIds
          .where(providersMap.containsKey)
          .map((id) => providersMap[id]!)
          .toList();

      route = createPageRoute(
        context: context,
        builder: (context) => _wrap(
          context,
          SignInScreen(
            showAuthActionSwitch: false,
            providers: authorizedProviders,
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
      auth: auth,
      onProvidersFound: onProvidersFound ??
          (email, providers) => _defaultAction(context, email, providers),
    );

    return UniversalScaffold(
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
    );
  }
}
