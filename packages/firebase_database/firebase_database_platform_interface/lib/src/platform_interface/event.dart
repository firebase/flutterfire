// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_platform_interface;

/// Enum to define various types of database events
enum EventType {
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
  'EventType.childAdded': EventType.childAdded,
  'EventType.childRemoved': EventType.childRemoved,
  'EventType.childChanged': EventType.childChanged,
  'EventType.childMoved': EventType.childMoved,
  'EventType.value': EventType.value,
};

EventType eventTypeFromString(String? value) {
  if (value == null) throw Exception('EventType string is null');

  if (!_eventTypesMap.containsKey(value)) {
    throw Exception('Unknown event type: $value');
  }

  return _eventTypesMap[value]!;
}

/// `Event` encapsulates a DataSnapshot and possibly also the key of its
/// previous sibling, which can be used to order the snapshots.
class EventPlatform {
  EventPlatform(Map<Object?, Object?> _data)
      : type = eventTypeFromString(_data['eventType'] as String?),
        previousChildKey = _data['previousChildKey'] as String?,
        snapshot = DataSnapshotPlatform.fromJson(
          _data['snapshot']! as Map<Object?, Object?>,
          _data['childKeys'] as List<Object?>?,
        );

  /// create [EventPlatform] from [DataSnapshotPlatform]
  EventPlatform.fromDataSnapshotPlatform(
    this.type,
    this.snapshot,
    this.previousChildKey,
  );

  final DataSnapshotPlatform snapshot;

  final String? previousChildKey;
  final EventType type;
}
