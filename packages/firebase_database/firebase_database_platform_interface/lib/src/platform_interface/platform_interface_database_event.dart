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

const _eventTypesMap = {
  'DatabaseEventType.childAdded': DatabaseEventType.childAdded,
  'DatabaseEventType.childRemoved': DatabaseEventType.childRemoved,
  'DatabaseEventType.childChanged': DatabaseEventType.childChanged,
  'DatabaseEventType.childMoved': DatabaseEventType.childMoved,
  'DatabaseEventType.value': DatabaseEventType.value,
};

DatabaseEventType eventTypeFromString(String value) {
  if (!_eventTypesMap.containsKey(value)) {
    throw Exception('Unknown event type: $value');
  }

  return _eventTypesMap[value]!;
}

/// `Event` encapsulates a DataSnapshot and possibly also the key of its
/// previous sibling, which can be used to order the snapshots.
abstract class DatabaseEventPlatform extends PlatformInterface {
  DatabaseEventPlatform(this._data) : super(token: _token);

  static final Object _token = Object();

  Map<String, dynamic> _data;

  /// Throws an [AssertionError] if [instance] does not extend
  /// [DatabaseEventPlatform].
  static void verifyExtends(DatabaseEventPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
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
