// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_platform_interface;

/// `Event` encapsulates a DataSnapshot and possibly also the key of its
/// previous sibling, which can be used to order the snapshots.
class MethodChannelEvent extends Event {
  MethodChannelEvent(Map<String, dynamic> _data)
      : super(MethodChannelDataSnapshot(_data["snapshot"]),
            _data['previousSiblingKey']);
}

/// A DataSnapshot contains data from a Firebase Database location.
/// Any time you read Firebase data, you receive the data as a DataSnapshot.
class MethodChannelDataSnapshot extends DataSnapshot {
  MethodChannelDataSnapshot(Map<String, dynamic> _data)
      : super(_data['key'], _data['value']);
}

/// A DatabaseError contains code, message and details of a Firebase Database
/// Error that results from a transaction operation at a Firebase Database
/// location.
class MethodChannelDatabaseError extends DatabaseError {
  MethodChannelDatabaseError(Map<String, dynamic> _data)
      : super(_data['code'], _data['message'], _data['details']);
}
