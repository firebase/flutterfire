// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutter/widgets.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';

@immutable
class ProviderKey {
  final FirebaseAuth auth;
  final Type providerType;

  const ProviderKey(this.auth, this.providerType);

  @override
  int get hashCode => Object.hash(auth, providerType);

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}

abstract class OAuthProviders {
  static final _providers = <ProviderKey, OAuthProvider>{};

  static void register(FirebaseAuth? auth, OAuthProvider provider) {
    final resolvedAuth = auth ?? FirebaseAuth.instance;
    final key = ProviderKey(resolvedAuth, provider.runtimeType);

    _providers[key] = provider;
  }

  static OAuthProvider? resolve(FirebaseAuth? auth, Type providerType) {
    final resolvedAuth = auth ?? FirebaseAuth.instance;
    final key = ProviderKey(resolvedAuth, providerType);
    return _providers[key];
  }

  static Iterable<OAuthProvider> providersFor(FirebaseAuth auth) sync* {
    for (final k in _providers.keys) {
      if (k.auth == auth) {
        yield _providers[k]!;
      }
    }
  }

  static Future<void> signOut([FirebaseAuth? auth]) async {
    final resolvedAuth = auth ?? FirebaseAuth.instance;
    final providers = providersFor(resolvedAuth);

    for (final p in providers) {
      await p.logOutProvider();
    }
  }
}

extension OAuthHelpers on User {
  bool isProviderLinked(String providerId) {
    try {
      providerData.firstWhere((e) => e.providerId == providerId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
