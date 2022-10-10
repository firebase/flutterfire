// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

class DifferentMethodSignInView extends StatelessWidget {
  final FirebaseAuth? auth;
  final List<String> availableProviders;
  final List<ProviderConfiguration> providerConfigs;
  final VoidCallback? onSignedIn;

  const DifferentMethodSignInView({
    Key? key,
    required this.availableProviders,
    required this.providerConfigs,
    this.auth,
    this.onSignedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final configsMap = providerConfigs
        .fold<Map<String, ProviderConfiguration>>({}, (map, config) {
      return {
        ...map,
        config.providerId: config,
      };
    });

    List<ProviderConfiguration> configs = [];

    for (final p in availableProviders) {
      final providerConfig = configsMap[p];
      if (providerConfig != null) {
        configs.add(providerConfig);
      }
    }

    return AuthStateListener(
      child: LoginView(
        action: AuthAction.signIn,
        providerConfigs: configs,
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
