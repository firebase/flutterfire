// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'config.dart';

typedef ConfigsMap = Map<FirebaseStorage, FirebaseUIStorageConfiguration>;

@visibleForTesting
void resetConfigs() {
  FirebaseUIStorage._configs.clear();
}

/// A class that should be used to configure FirebaseUIStorage.
/// The configuration could be override for a specific
/// part of the widget tree using [FirebaseUIStorageConfigOverride] widget.
class FirebaseUIStorage {
  static final ConfigsMap _configs = {};

  /// Checks if FirebaseUIStorage is configured for a specific
  /// [FirebaseStorage] intance.
  static bool isConfigured(FirebaseStorage storage) {
    return _configs.containsKey(storage);
  }

  /// Returns a [FirebaseUIStorageConfiguration] for a specific
  /// [FirebaseStorage] intance.
  static FirebaseUIStorageConfiguration configurationFor(
    FirebaseStorage storage,
  ) {
    if (!isConfigured(storage)) {
      throw StateError('FirebaseUIStorage is not configured for $storage');
    }
    return _configs[storage]!;
  }

  /// Configures FirebaseUIStorage to be used with a [FirebaseStorage].
  static Future<void> configure(
    FirebaseUIStorageConfiguration config,
  ) async {
    final storage = config.storage;

    if (isConfigured(storage)) {
      throw StateError('FirebaseUIStorage is already configured for $storage');
    }

    _configs[storage] = config;
  }

  static late Function pickFile;
}
