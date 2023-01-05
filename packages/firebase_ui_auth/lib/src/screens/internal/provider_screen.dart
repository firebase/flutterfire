// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

abstract class ProviderScreen<T extends AuthProvider> extends StatelessWidget {
  final T? _provider;

  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  static final _cache = <Type, AuthProvider>{};

  /// Current [AuthProvider] that is being used to authenticate the user.
  T get provider {
    if (_provider != null) return _provider!;
    if (_cache.containsKey(T)) {
      return _cache[T]! as T;
    }

    final auth = this.auth ?? FirebaseAuth.instance;
    final configs = FirebaseUIAuth.providersFor(auth.app);
    final config = configs.firstWhere((element) => element is T) as T;
    _cache[T] = config;
    return config;
  }

  const ProviderScreen({Key? key, T? provider, this.auth})
      : _provider = provider,
        super(key: key);
}
