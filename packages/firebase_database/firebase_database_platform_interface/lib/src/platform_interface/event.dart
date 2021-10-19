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
      // ingore: cast_nullable_to_non_nullable
      : type = eventTypeFromString(_data['eventType'] as String?),
        previousSiblingKey = _data['previousSiblingKey'] as String?,
        snapshot = DataSnapshotPlatform.fromJson(
            _data['snapshot']! as Map<Object?, Object?>,
            _data['childKeys'] as List<Object?>?);

  /// create [EventPlatform] from [DataSnapshotPlatform]
  EventPlatform.fromDataSnapshotPlatform(
    this.type,
    this.snapshot,
    this.previousSiblingKey,
  );

  final DataSnapshotPlatform snapshot;

  final String? previousSiblingKey;
  final EventType type;
}

/// A DataSnapshot contains data from a Firebase Database location.
/// Any time you read Firebase data, you receive the data as a DataSnapshot.
class DataSnapshotPlatform {
  DataSnapshotPlatform(this.key, this.value) : exists = value != null;

  factory DataSnapshotPlatform.fromJson(
    Map<Object?, Object?> _data,
    List<Object?>? childKeys,
  ) {
    Object? dataValue = _data['value'];
    Object? value;

    if (dataValue is Map<Object?, Object?> && childKeys != null) {
      value = {for (final key in childKeys) key: dataValue[key]};
    } else if (dataValue is List<Object?> && childKeys != null) {
      value =
          childKeys.map((key) => dataValue[int.parse(key! as String)]).toList();
    } else {
      value = dataValue;
    }

    return DataSnapshotPlatform(_data['key'] as String?, value);
  }

  /// The key of the location that generated this DataSnapshot.
  final String? key;

  /// Returns the contents of this data snapshot as native types.
  final dynamic value;

  /// Ascertains whether the value exists at the Firebase Database location.
  final bool exists;
}
