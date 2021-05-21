// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

enum _EventType {
  childAdded,
  childRemoved,
  childChanged,
  childMoved,
  value,
}

/// `Event` encapsulates a DataSnapshot and possibly also the key of its
/// previous sibling, which can be used to order the snapshots.
class Event {
  Event._(Map<Object?, Object?> _data)
      : previousSiblingKey = _data['previousSiblingKey'] as String?,
        snapshot = DataSnapshot._fromJson(
            _data['snapshot']! as Map<Object?, Object?>,
            _data['childKeys'] as List<Object?>?);

  final DataSnapshot snapshot;

  final String? previousSiblingKey;
}

/// A DataSnapshot contains data from a Firebase Database location.
/// Any time you read Firebase data, you receive the data as a DataSnapshot.
class DataSnapshot {
  DataSnapshot._(this.key, this.value);

  factory DataSnapshot._fromJson(
    Map<Object?, Object?> _data,
    List<Object?>? childKeys,
  ) {
    Object? dataValue = _data['value'];
    Object? value;

    if (dataValue is Map<Object?, Object?> && childKeys != null) {
      value = {for (final key in childKeys) key: dataValue[key]};
    } else if (dataValue is List<Object?>) {
      value = childKeys!
          .map((key) => dataValue[int.parse(key! as String)])
          .toList();
    } else {
      value = dataValue;
    }
    return DataSnapshot._(_data['key'] as String?, value);
  }

  /// The key of the location that generated this DataSnapshot.
  final String? key;

  /// Returns the contents of this data snapshot as native types.
  final dynamic value;
}

class MutableData {
  @visibleForTesting
  MutableData.private(this._data);

  final Map<dynamic, dynamic> _data;

  /// The key of the location that generated this MutableData.
  String get key => _data['key'];

  /// Returns the mutable contents of this MutableData as native types.
  dynamic get value => _data['value'];
  set value(dynamic newValue) => _data['value'] = newValue;
}

/// A DatabaseError contains code, message and details of a Firebase Database
/// Error that results from a transaction operation at a Firebase Database
/// location.
class DatabaseError {
  DatabaseError._(this._data);

  Map<dynamic, dynamic> _data;

  /// One of the defined status codes, depending on the error.
  int get code => _data['code'];

  /// A human-readable description of the error.
  String get message => _data['message'];

  /// Human-readable details on the error and additional information.
  String get details => _data['details'];

  @override
  // ignore: no_runtimetype_tostring
  String toString() => '$runtimeType($code, $message, $details)';
}
