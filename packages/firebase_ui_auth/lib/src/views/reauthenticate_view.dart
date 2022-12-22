// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/widgets.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

/// {@template ui.auth.views.reauthenticate_view}
/// A view that could be used to build a custom [ReauthenticateDialog].
/// {@endtemplate}
class ReauthenticateView extends StatelessWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// A list of all supported auth providers.
  final List<AuthProvider> providers;

  /// A callback that is being called when the user has successfuly signed in.
  final VoidCallback? onSignedIn;

  /// A label that would be used for the "Sign in" button.
  final String? actionButtonLabelOverride;

  /// {@macro ui.auth.views.reauthenticate_view}
  const ReauthenticateView({
    Key? key,
    required this.providers,
    this.auth,
    this.onSignedIn,
    this.actionButtonLabelOverride,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final linkedProviders =
        (auth ?? FirebaseAuth.instance).currentUser!.providerData;

    final providersMap = this.providers.fold<Map<String, AuthProvider>>(
      {},
      (map, provider) {
        return {
          ...map,
          provider.providerId: provider,
        };
      },
    );

    List<AuthProvider> providers = [];

    for (final p in linkedProviders) {
      final provider = providersMap[p.providerId];

      if (provider != null) {
        providers.add(provider);
      }
    }

    return AuthStateListener(
      child: LoginView(
        action: AuthAction.signIn,
        providers: providers,
        showTitle: false,
        showAuthActionSwitch: false,
        actionButtonLabelOverride: actionButtonLabelOverride,
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
