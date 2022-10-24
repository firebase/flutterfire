// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Enum to define various types of database events
enum DatabaseEventType {
  /// Event for [onChildAdded] listener
  childAdded,

  /// Event for [onChildRemoved] listener
  childRemoved,

  /// Event for [onChildChanged] listener
  childChanged,

  /// Event for [onChildMoved] listener
  childMoved,

  /// Event for [onValue] listener
  value,
}

const _eventTypeFromStringMap = {
  'childAdded': DatabaseEventType.childAdded,
  'childRemoved': DatabaseEventType.childRemoved,
  'childChanged': DatabaseEventType.childChanged,
  'childMoved': DatabaseEventType.childMoved,
  'value': DatabaseEventType.value,
};

const _eventTypeToStringMap = {
  DatabaseEventType.childAdded: 'childAdded',
  DatabaseEventType.childRemoved: 'childRemoved',
  DatabaseEventType.childChanged: 'childChanged',
  DatabaseEventType.childMoved: 'childMoved',
  DatabaseEventType.value: 'value',
};

DatabaseEventType eventTypeFromString(String value) {
  if (!_eventTypeFromStringMap.containsKey(value)) {
    throw Exception('Unknown event type: $value');
  }
  return _eventTypeFromStringMap[value]!;
}

String eventTypeToString(DatabaseEventType value) {
  if (!_eventTypeToStringMap.containsKey(value)) {
    throw Exception('Unknown event type: $value');
  }
  return _eventTypeToStringMap[value]!;
}

/// `Event` encapsulates a DataSnapshot and possibly also the key of its
/// previous sibling, which can be used to order the snapshots.
abstract class DatabaseEventPlatform extends PlatformInterface {
  DatabaseEventPlatform(this._data) : super(token: _token);

  static final Object _token = Object();

  Map<String, dynamic> _data;

  /// Throws an [AssertionError] if [instance] does not extend
  /// [DatabaseEventPlatform].
  static void verify(DatabaseEventPlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  DataSnapshotPlatform get snapshot {
    throw UnimplementedError('get snapshot is not implemented');
  }

  String? get previousChildKey {
    return _data['previousChildKey'];
  }

  DatabaseEventType get type {
    return eventTypeFromString(_data['eventType']);
  }
}
