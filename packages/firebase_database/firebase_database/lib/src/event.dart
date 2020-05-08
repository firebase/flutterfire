// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

/// `Event` encapsulates a DataSnapshot and possibly also the key of its
/// previous sibling, which can be used to order the snapshots.
class Event {
  final platform.EventPlatform _delegate;
  Event._(this._delegate);

  DataSnapshot get snapshot => DataSnapshot._(_delegate.snapshot);

  String get previousSiblingKey => _delegate.previousSiblingKey;
}

/// A DataSnapshot contains data from a Firebase Database location.
/// Any time you read Firebase data, you receive the data as a DataSnapshot.
class DataSnapshot {
  final platform.DataSnapshotPlatform _delegate;
  DataSnapshot._(this._delegate);

  /// The key of the location that generated this DataSnapshot.
  String get key => _delegate.key;

  /// Returns the contents of this data snapshot as native types.
  dynamic get value => _delegate.value;
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
  platform.DatabaseErrorPlatform _delegate;
  DatabaseError._(this._delegate);

  /// One of the defined status codes, depending on the error.
  int get code => _delegate.code;

  /// A human-readable description of the error.
  String get message => _delegate.message;

  /// Human-readable details on the error and additional information.
  String get details => _delegate.details;

  @override
  String toString() => "$runtimeType($code, $message, $details)";
}
