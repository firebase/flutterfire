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

/// `Event` encapsulates a DataSnapshot and possibly also the key of its
/// previous sibling, which can be used to order the snapshots.
class EventPlatform {
  /// Constructor for [EventPlatform]
  EventPlatform(this.snapshot, this.previousSiblingKey);

  /// Returns the snapshot of this event.
  final DataSnapshotPlatform snapshot;

  /// Returns string containing the key of the previous child.
  final String previousSiblingKey;
}

/// A DataSnapshot contains data from a Firebase Database location.
/// Any time you read Firebase data, you receive the data as a DataSnapshot.
class DataSnapshotPlatform {
  /// Constructor for [DataSnapshotPlatform]
  DataSnapshotPlatform(this.key, this.value);

  /// The key of the location that generated this DataSnapshot.
  final String key;

  /// Returns the contents of this data snapshot as native types.
  final dynamic value;
}

/// A SataSnapshot class which can be mutated. Specially used with transactions.
class MutableDataPlatform {
  /// Constructor for [MutableDataPlatform]
  @visibleForTesting
  MutableDataPlatform(this._data);

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
class DatabaseErrorPlatform {
  /// Constructor for [DatabaseErrorPlatform]
  DatabaseErrorPlatform(this.code, this.message, this.details);

  /// One of the defined status codes, depending on the error.
  final int code;

  /// A human-readable description of the error.
  final String message;

  /// Human-readable details on the error and additional information.
  final String details;

  @override
  String toString() => "$runtimeType($code, $message, $details)";
}
