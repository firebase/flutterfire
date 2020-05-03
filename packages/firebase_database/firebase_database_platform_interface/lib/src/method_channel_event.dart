// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_platform_interface;

/// `Event` encapsulates a DataSnapshot and possibly also the key of its
/// previous sibling, which can be used to order the snapshots.
class MethodChannelEvent extends Event {
  MethodChannelEvent._(Map<String, dynamic> _data) {
    snapshot = MethodChannelDataSnapshot._(_data["snapshot"]);
    previousSiblingKey = _data['previousSiblingKey'];
  }

  /// One of the defined status codes, depending on the error.
}

/// A DataSnapshot contains data from a Firebase Database location.
/// Any time you read Firebase data, you receive the data as a DataSnapshot.
class MethodChannelDataSnapshot extends DataSnapshot {
  MethodChannelDataSnapshot._(Map<String, dynamic> _data) {
    key = _data['key'];
    value = _data['value'];
  }
}

/// A DatabaseError contains code, message and details of a Firebase Database
/// Error that results from a transaction operation at a Firebase Database
/// location.
class MethodChannelDatabaseError extends DatabaseError {
  MethodChannelDatabaseError._(Map<String, dynamic> _data) {
    code = _data['code'];
    message = _data['message'];
    details = _data['details'];
  }
}
