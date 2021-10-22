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
        previousSiblingKey = _data['previousSiblingKey'] as String?,
        snapshot = DataSnapshotPlatform.fromJson(
          _data['snapshot']! as Map<Object?, Object?>,
          _data['childKeys'] as List<Object?>?,
        );

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

  // Returns wheterh or not the DataSnapshot has any non-null child properties
  bool get hasChildren {
    return (value is Map && (value as Map).isNotEmpty) ||
        (value is List && (value as List).isNotEmpty);
  }

  // Returns the number of child properties of this DataSnapshot.
  int get numChildren {
    if (value is Map) {
      return (value as Map).length;
    }

    if (value is List) {
      return (value as List).length;
    }

    return 0;
  }

  // Enumerates the top-level children in the DataSnapshot
  void forEach(void Function(DataSnapshotPlatform element) iterator) {
    if (value is Map) {
      (value as Map).forEach((key, value) {
        iterator(DataSnapshotPlatform(key, value));
      });
    }

    if (value is List) {
      for (int i = 0; i < (value as List).length; i++) {
        iterator(DataSnapshotPlatform(i.toString(), value[i]));
      }
    }
  }

  // Returns true if the specified child path has (non-null) data.
  bool hasChild(String path) {
    final chunks = path.split('/').toList();
    dynamic value = this.value;

    while (value != null && chunks.isNotEmpty) {
      final c = chunks.removeAt(0);

      if (value is List) {
        final index = int.tryParse(c);

        if (index == null) return false;
        if (index < 0) return false;
        if (index > value.length - 1) return false;

        value = value[index];
        continue;
      }

      if (value is Map) {
        value = value[c];
      }
    }

    return value != null;
  }
}
