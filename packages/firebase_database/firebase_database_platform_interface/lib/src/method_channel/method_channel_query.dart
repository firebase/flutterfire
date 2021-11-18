// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    Map<String, dynamic> parameters = const <String, dynamic>{},
  }) : super(
          database: database,
          parameters: parameters,
        );

  final List<String> pathComponents;

  @override
  String get path {
    return pathComponents.join('/');
  }

  MethodChannel get channel => MethodChannelDatabase.channel;

  @override
  Stream<DatabaseEventPlatform> observe(DatabaseEventType eventType) async* {
    const channel = MethodChannelDatabase.channel;

    final listenArgs = <String, String>{
      'eventType': eventTypeToString(eventType)
    };

    final channelName = await channel.invokeMethod<String>(
      'Query#observe',
      database.getChannelArguments({
        'path': path,
        'parameters': parameters,
        'eventType': eventTypeToString(eventType),
      }),
    );

    yield* EventChannel(channelName!)
        .receiveBroadcastStream(listenArgs)
        .map(
          (event) =>
              MethodChannelDatabaseEvent(ref, Map<String, dynamic>.from(event)),
        )
        .handleError(
          (e, s) => throw convertPlatformException(e, s),
          test: (err) => err is PlatformException,
        );
  }

  /// Gets the most up-to-date result for this query.
  @override
  Future<DataSnapshotPlatform> get() async {
    try {
      final result = await channel.invokeMethod<Map<String, Object?>>(
        'Query#get',
        database.getChannelArguments({
          'path': path,
          'parameters': parameters,
        }),
      );

      return MethodChannelDataSnapshot(ref, Map<String, dynamic>.from(result!));
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  /// Create a query constrained to only return child nodes with a value greater
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key greater
  /// than or equal to the given key.
  @override
  QueryPlatform startAt(Object? value, {String? key}) {
    return _addPaginationParameter(value, key, 'startAt');
  }

  /// Creates a query with the specified starting point (exclusive).
  /// Using [startAt], [startAfter], [endBefore], [endAt] and [equalTo]
  /// allows you to choose arbitrary starting and ending points for your
  /// queries.
  ///
  /// The starting point is exclusive.
  ///
  /// If only a value is provided, children with a value greater than
  /// the specified value will be included in the query.
  /// If a key is specified, then children must have a value greater than
  /// or equal to the specified value and a a key name greater than
  /// the specified key.
  @override
  QueryPlatform startAfter(Object? value, {String? key}) {
    return _addPaginationParameter(value, key, 'startAfter');
  }

  /// Create a query constrained to only return child nodes with a value less
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key less
  /// than or equal to the given key.
  @override
  QueryPlatform endAt(Object? value, {String? key}) {
    return _addPaginationParameter(value, key, 'endAt');
  }

  @override
  QueryPlatform endBefore(Object? value, {String? key}) {
    return _addPaginationParameter(value, key, 'endBefore');
  }

  /// Create a query constrained to only return child nodes with the given
  /// `value` (and `key`, if provided).
  ///
  /// If a key is provided, there is at most one such child as names are unique.
  @override
  QueryPlatform equalTo(Object? value, {String? key}) {
    return _addPaginationParameter(value, key, 'equalTo');
  }

  QueryPlatform _addPaginationParameter(
    dynamic value,
    String? paginationKey,
    String parameterKey,
  ) {
    assert(!this.parameters.containsKey(parameterKey));
    assert(value is String || value is bool || value is num || value == null);

    final parameters = <String, dynamic>{parameterKey: value};
    if (paginationKey != null) parameters['${parameterKey}Key'] = paginationKey;

    return _copyWithParameters(parameters);
  }

  /// Create a query with limit and anchor it to the start of the window.
  @override
  QueryPlatform limitToFirst(int limit) {
    assert(!parameters.containsKey('limitToFirst'));
    return _copyWithParameters(<String, dynamic>{'limitToFirst': limit});
  }

  /// Create a query with limit and anchor it to the end of the window.
  @override
  QueryPlatform limitToLast(int limit) {
    assert(!parameters.containsKey('limitToLast'));
    return _copyWithParameters(<String, dynamic>{'limitToLast': limit});
  }

  /// Generate a view of the data sorted by values of a particular child key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  @override
  QueryPlatform orderByChild(String key) {
    assert(!parameters.containsKey('orderBy'));
    return _copyWithParameters(
      <String, dynamic>{'orderBy': 'child', 'orderByChildKey': key},
    );
  }

  /// Generate a view of the data sorted by key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  @override
  QueryPlatform orderByKey() {
    assert(!parameters.containsKey('orderBy'));
    return _copyWithParameters(<String, dynamic>{'orderBy': 'key'});
  }

  /// Generate a view of the data sorted by value.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  @override
  QueryPlatform orderByValue() {
    assert(!parameters.containsKey('orderBy'));
    return _copyWithParameters(<String, dynamic>{'orderBy': 'value'});
  }

  /// Generate a view of the data sorted by priority.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  @override
  QueryPlatform orderByPriority() {
    assert(!parameters.containsKey('orderBy'));
    return _copyWithParameters(<String, dynamic>{'orderBy': 'priority'});
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
  Future<void> keepSynced(bool value) {
    try {
      return channel.invokeMethod<void>(
        'Query#keepSynced',
        database.getChannelArguments(
          {'path': path, 'parameters': parameters, 'value': value},
        ),
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  MethodChannelQuery _copyWithParameters(Map<String, dynamic> parameters) {
    return MethodChannelQuery(
      database: database,
      pathComponents: pathComponents,
      parameters: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(this.parameters)..addAll(parameters),
      ),
    );
  }
}
