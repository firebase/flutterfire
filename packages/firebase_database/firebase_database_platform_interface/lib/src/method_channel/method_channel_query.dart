// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_platform_interface;

/// Represents a query over the data at a particular location.
class MethodChannelQuery extends QueryPlatform {
  /// Create a [MethodChannelQuery] from [pathComponents]
  MethodChannelQuery({
    required DatabasePlatform database,
    required List<String> pathComponents,
    Map<String, dynamic> parameters = const <String, dynamic>{},
  }) : super(
          database: database,
          parameters: parameters,
          pathComponents: pathComponents,
        );

  @override
  Stream<EventPlatform> observe(EventType eventType) {
    late Future<int> _handle;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    late StreamController<EventPlatform> controller; // ignore: close_sinks
    controller = StreamController<EventPlatform>.broadcast(
      onListen: () {
        _handle = MethodChannelDatabase.channel.invokeMethod<int>(
          'Query#observe',
          <String, dynamic>{
            'app': database.app?.name,
            'databaseURL': database.databaseURL,
            'path': path,
            'parameters': parameters,
            'eventType': eventType.toString(),
          },
        ).then((value) {
          MethodChannelDatabase._observers[value!] = controller;
          return value;
        });
      },
      onCancel: () {
        _handle.then((int handle) async {
          await MethodChannelDatabase.channel.invokeMethod<int>(
            'Query#removeObserver',
            <String, dynamic>{
              'app': database.app?.name,
              'databaseURL': database.databaseURL,
              'path': path,
              'parameters': parameters,
              'handle': handle,
            },
          );
          MethodChannelDatabase._observers.remove(handle);
        });
      },
    );
    return controller.stream;
  }

  /// Slash-delimited path representing the database location of this query.
  @override
  String get path => pathComponents.join('/');

  /// Gets the most up-to-date result for this query.
  @override
  Future<DataSnapshotPlatform> get() async {
    final result =
        await MethodChannelDatabase.channel.invokeMethod<Map<dynamic, dynamic>>(
      'Query#get',
      <String, dynamic>{
        'app': database.app?.name,
        'databaseURL': database.databaseURL,
        'path': path,
      },
    );
    if (result!.containsKey('error') && result['error'] != null) {
      final errorMap = result['error'];
      throw FirebaseException(
        plugin: 'firebase_database',
        code: 'get-failed',
        message: errorMap['details'],
      );
    } else {
      return DataSnapshotPlatform.fromJson(result['snapshot'], null);
    }
  }

  /// Create a query constrained to only return child nodes with a value greater
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key greater
  /// than or equal to the given key.
  @override
  QueryPlatform startAt(dynamic value, {String? key}) {
    assert(!this.parameters.containsKey('startAt'));
    assert(value is String ||
        value is bool ||
        value is double ||
        value is int ||
        value == null);
    final Map<String, dynamic> parameters = <String, dynamic>{'startAt': value};
    if (key != null) parameters['startAtKey'] = key;
    return _copyWithParameters(parameters);
  }

  /// Create a query constrained to only return child nodes with a value less
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key less
  /// than or equal to the given key.
  @override
  QueryPlatform endAt(dynamic value, {String? key}) {
    assert(!this.parameters.containsKey('endAt'));
    assert(value is String ||
        value is bool ||
        value is double ||
        value is int ||
        value == null);
    final Map<String, dynamic> parameters = <String, dynamic>{'endAt': value};
    if (key != null) parameters['endAtKey'] = key;
    return _copyWithParameters(parameters);
  }

  /// Create a query constrained to only return child nodes with the given
  /// `value` (and `key`, if provided).
  ///
  /// If a key is provided, there is at most one such child as names are unique.
  @override
  QueryPlatform equalTo(dynamic value, {String? key}) {
    assert(!this.parameters.containsKey('equalTo'));
    assert(value is String ||
        value is bool ||
        value is double ||
        value is int ||
        value == null);
    final Map<String, dynamic> parameters = <String, dynamic>{'equalTo': value};
    if (key != null) parameters['equalToKey'] = key;
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
    return MethodChannelDatabase.channel.invokeMethod<void>(
      'Query#keepSynced',
      <String, dynamic>{
        'app': database.app?.name,
        'databaseURL': database.databaseURL,
        'path': path,
        'parameters': parameters,
        'value': value
      },
    );
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
