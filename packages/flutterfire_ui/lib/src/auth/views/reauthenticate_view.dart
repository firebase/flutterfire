// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

class ReauthenticateView extends StatelessWidget {
  final FirebaseAuth? auth;
  final List<ProviderConfiguration> providerConfigs;
  final VoidCallback? onSignedIn;

  const ReauthenticateView({
    Key? key,
    required this.providerConfigs,
    this.auth,
    this.onSignedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final providers = (auth ?? FirebaseAuth.instance).currentUser!.providerData;
    final configsMap = providerConfigs
        .fold<Map<String, ProviderConfiguration>>({}, (map, config) {
      return {
        ...map,
        config.providerId: config,
      };
    });

    List<ProviderConfiguration> configs = [];

    for (final p in providers) {
      final providerConfig = configsMap[p.providerId];
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
