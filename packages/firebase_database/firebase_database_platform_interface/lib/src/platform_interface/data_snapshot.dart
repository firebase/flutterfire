// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_platform_interface;

/// A DataSnapshot contains data from a Firebase Database location.
/// Any time you read Firebase data, you receive the data as a DataSnapshot.
abstract class DataSnapshotPlatform extends PlatformInterface {
  DataSnapshotPlatform(
    this.key,
    this.value, {
    required this.ref,
    required this.priority,
    required List<String> childKeys,
  }) : _childKeys = childKeys;

  factory DataSnapshotPlatform.fromJsonRENAME_TO_ENSURE_SIG_CHANGE(
    Map<Object?, Object?> data,
    DatabaseReferencePlatform ref,
  ) {
    String? key = data['key'] as String?;
    Object? value = data['value'];
    Object? priority = data['priority'];
    List<String> childKeys = List<String>.from(data['childKeys']! as List);
    return DataSnapshotPlatform(
      key,
      value,
      ref: ref,
      priority: priority,
      childKeys: childKeys,
    );
  }

  /// The Reference for the location that generated this DataSnapshot.
  final DatabaseReferencePlatform ref;

  /// The priority value of the data in this [DataSnapshotPlatform].
  /// Can be a string, number or null value.
  final Object? priority;

  /// The key of the location that generated this DataSnapshot.
  final String? key;

  /// The contents of this data snapshot as native types.
  final dynamic value;

  final List<String> _childKeys;

  /// Whether the value exists at the Firebase Database location.
  bool get exists {
    return value != null;
  }

  /// An iterator for snapshots of the child nodes in this snapshot.
  Iterable<DataSnapshotPlatform> get children {
    return Iterable<DataSnapshotPlatform>.generate(_childKeys.length,
        (int index) {
      String childKey = _childKeys[index];

      dynamic childValue;
      if (value is Map<Object?, Object?>) {
        childValue = value[childKey];
      } else if (value is List<Object?>) {
        childValue = value[int.parse(childKey)];
      }

      return DataSnapshotPlatform(
        childKey,
        childValue,
        childKeys: _childKeysFromValue(childValue),
        // TODO change underlying SDKs to use exportVal and pluck priority from
        // `.priority' key on returned map.
        priority: null,
        ref: ref.child(childKey),
      );
    });
  }

  /// Gets another [DataSnapshotPlatform] for the location at the specified relative path.
  /// The relative path can either be a simple child name (for example, "ada")
  /// or a deeper, slash-separated path (for example, "ada/name/first").
  /// If the child location has no data, an empty DataSnapshot (that is, a
  /// [DataSnapshotPlatform] whose [value] is null) is returned.
  DataSnapshotPlatform child(String childPath) {
    dynamic childValue = value;
    final chunks = childPath.split('/').toList();
    while (childValue != null && chunks.isNotEmpty) {
      final c = chunks.removeAt(0);
      if (childValue is List) {
        final index = int.tryParse(c);
        if (index == null || index < 0 || index > childValue.length - 1) {
          return DataSnapshotPlatform(
            ref.child(childPath).key,
            null,
            ref: ref.child(childPath),
            childKeys: [],
            priority: null,
          );
        }
        childValue = childValue[index];
        continue;
      }
      if (childValue is Map) {
        childValue = childValue[c];
      }
    }

    if (childValue == null) {
      return DataSnapshotPlatform(
        ref.child(childPath).key,
        null,
        ref: ref.child(childPath),
        childKeys: [],
        priority: null,
      );
    }

    return DataSnapshotPlatform(
      ref.child(childPath).key,
      childValue,
      ref: ref.child(childPath),
      childKeys: _childKeysFromValue(childValue),
      // TODO change underlying SDKs to use exportVal and pluck priority from
      // `.priority' key on returned map.
      priority: null,
    );
  }

  /// Returns true if the specified child path has (non-null) data.
  bool hasChild(String path) {
    return child(path).exists;
  }

  List<String> _childKeysFromValue(dynamic value) {
    List<String> childChildKeys = [];
    if (value is Map) {
      childChildKeys = List<String>.from(value.keys.toList());
    } else if (value is List) {
      childChildKeys = List<String>.generate(
        value.length,
        (int index) => '${index - 1}',
      );
    }
    return childChildKeys;
  }
}
