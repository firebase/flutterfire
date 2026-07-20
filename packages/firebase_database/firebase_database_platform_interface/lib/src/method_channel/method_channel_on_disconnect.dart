// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/method_channel/utils/utils.dart';
import 'package:firebase_database_platform_interface/src/pigeon/messages.pigeon.dart'
    hide DatabaseReferencePlatform;

import 'method_channel_database.dart';
import 'utils/exception.dart';

final _api = FirebaseDatabaseHostApi();

/// Represents a query over the data at a particular location.
class MethodChannelOnDisconnect extends OnDisconnectPlatform {
  /// Create a [MethodChannelQuery] from [DatabaseReferencePlatform]
  MethodChannelOnDisconnect({
    required DatabasePlatform database,
    required DatabaseReferencePlatform ref,
  }) : super(database: database, ref: ref);

  /// Gets the Pigeon app object from the database
  DatabasePigeonFirebaseApp get _pigeonApp {
    final methodChannelDatabase = database as MethodChannelDatabase;
    return methodChannelDatabase.pigeonApp;
  }

  @override
  Future<void> set(Object? value) async {
    try {
      await _api.onDisconnectSet(
        _pigeonApp,
        DatabaseReferenceRequest(
          path: ref.path,
          value: value != null ? transformValue(value) : null,
        ),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setWithPriority(Object? value, Object? priority) async {
    try {
      await _api.onDisconnectSetWithPriority(
        _pigeonApp,
        DatabaseReferenceRequest(
          path: ref.path,
          value: value != null ? transformValue(value) : null,
          priority: priority,
        ),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> remove() => set(null);

  @override
  Future<void> cancel() async {
    try {
      await _api.onDisconnectCancel(
        _pigeonApp,
        ref.path,
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> update(Map<String, Object?> value) async {
    try {
      await _api.onDisconnectUpdate(
        _pigeonApp,
        UpdateRequest(
          path: ref.path,
          value: transformValue(value)! as Map<String, Object?>,
        ),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
