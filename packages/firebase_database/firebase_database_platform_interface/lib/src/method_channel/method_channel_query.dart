// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:_flutterfire_internals/_flutterfire_internals.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/pigeon/messages.pigeon.dart'
    hide DatabaseReferencePlatform;
import 'package:flutter/services.dart';

import 'method_channel_data_snapshot.dart';
import 'method_channel_database.dart';
import 'method_channel_database_event.dart';
import 'method_channel_database_reference.dart';
import 'utils/exception.dart';

final _api = FirebaseDatabaseHostApi();

/// Represents a query over the data at a particular location.
class MethodChannelQuery extends QueryPlatform {
  /// Create a [MethodChannelQuery] from [pathComponents]
  MethodChannelQuery({
    required DatabasePlatform database,
    required this.pathComponents,
  }) : super(database: database);

  static Map<String, Stream<DatabaseEventPlatform>> observers = {};

  final List<String> pathComponents;

  /// Gets the Pigeon app object from the database
  DatabasePigeonFirebaseApp get _pigeonApp {
    final methodChannelDatabase = database as MethodChannelDatabase;
    return methodChannelDatabase.pigeonApp;
  }

  @override
  String get path {
    if (pathComponents.isEmpty) return '/';
    return pathComponents.join('/');
  }

  MethodChannel get channel => MethodChannelDatabase.channel;

  @override
  Stream<DatabaseEventPlatform> observe(
    QueryModifiers modifiers,
    DatabaseEventType eventType,
  ) async* {
    List<Map<String, Object?>> modifierList = modifiers.toList();

    // Create the EventChannel on native using Pigeon.
    final channelName = await _api.queryObserve(
      _pigeonApp,
      QueryRequest(
        path: path,
        modifiers: modifierList,
      ),
    );

    yield* EventChannel(channelName).receiveGuardedBroadcastStream(
      arguments: <String, Object?>{'eventType': eventTypeToString(eventType)},
      onError: convertPlatformException,
    ).map(
      (event) =>
          MethodChannelDatabaseEvent(ref, Map<String, dynamic>.from(event)),
    );
  }

  /// Gets the most up-to-date result for this query.
  @override
  Future<DataSnapshotPlatform> get(QueryModifiers modifiers) async {
    try {
      final result = await _api.queryGet(
        _pigeonApp,
        QueryRequest(
          path: path,
          modifiers: modifiers.toList(),
        ),
      );
      final snapshotData = result['snapshot'];
      if (snapshotData == null) {
        return MethodChannelDataSnapshot(
          ref,
          <String, dynamic>{
            'key': ref.key,
            'value': null,
            'priority': null,
            'childKeys': [],
          },
        );
      }
      return MethodChannelDataSnapshot(
        ref,
        Map<String, dynamic>.from(snapshotData as Map),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  /// Obtains a DatabaseReference corresponding to this query's location.
  @override
  DatabaseReferencePlatform get ref {
    return MethodChannelDatabaseReference(
      database: database,
      pathComponents: pathComponents,
    );
  }

  /// By calling keepSynced(true) on a location, the data for that location will
  /// automatically be downloaded and kept in sync, even when no listeners are
  /// attached for that location. Additionally, while a location is kept synced,
  /// it will not be evicted from the persistent disk cache.
  @override
  Future<void> keepSynced(QueryModifiers modifiers, bool value) async {
    try {
      await _api.queryKeepSynced(
        _pigeonApp,
        QueryRequest(
          path: path,
          modifiers: modifiers.toList(),
          value: value,
        ),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
