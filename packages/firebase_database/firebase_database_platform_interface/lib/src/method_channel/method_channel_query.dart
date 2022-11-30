// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:_flutterfire_internals/_flutterfire_internals.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:flutter/services.dart';

import 'method_channel_data_snapshot.dart';
import 'method_channel_database.dart';
import 'method_channel_database_event.dart';
import 'method_channel_database_reference.dart';
import 'utils/exception.dart';

/// Represents a query over the data at a particular location.
class MethodChannelQuery extends QueryPlatform {
  /// Create a [MethodChannelQuery] from [pathComponents]
  MethodChannelQuery({
    required DatabasePlatform database,
    required this.pathComponents,
  }) : super(database: database);

  static Map<String, Stream<DatabaseEventPlatform>> observers = {};

  final List<String> pathComponents;

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
    const channel = MethodChannelDatabase.channel;
    List<Map<String, Object?>> modifierList = modifiers.toList();
    // Create a unique event channel naming prefix using path, app name,
    // databaseUrl, event type and ordered modifier list
    String eventChannelNamePrefix =
        '$path-${database.app!.name}-${database.databaseURL}-$eventType-$modifierList';

    // Create the EventChannel on native.
    final channelName = await channel.invokeMethod<String>(
      'Query#observe',
      database.getChannelArguments({
        'path': path,
        'modifiers': modifierList,
        'eventChannelNamePrefix': eventChannelNamePrefix,
      }),
    );

    yield* EventChannel(channelName!).receiveGuardedBroadcastStream(
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
      final result = await channel.invokeMapMethod(
        'Query#get',
        database.getChannelArguments({
          'path': path,
          'modifiers': modifiers.toList(),
        }),
      );
      return MethodChannelDataSnapshot(
        ref,
        Map<String, dynamic>.from(result!['snapshot']),
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
      await channel.invokeMethod<void>(
        'Query#keepSynced',
        database.getChannelArguments(
          {'path': path, 'modifiers': modifiers.toList(), 'value': value},
        ),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
