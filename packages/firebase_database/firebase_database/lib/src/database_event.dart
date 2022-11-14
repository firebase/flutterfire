// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

/// `DatabaseEvent` encapsulates a DataSnapshot and possibly also the key of its
/// previous sibling, which can be used to order the snapshots.
class DatabaseEvent {
  final DatabaseEventPlatform _delegate;

  DatabaseEvent._(this._delegate) {
    DatabaseEventPlatform.verify(_delegate);
  }

  /// The type of event.
  DatabaseEventType get type => _delegate.type;

  /// The cached [DataSnapshot] for the event.
  DataSnapshot? _dataSnapshot;

  /// The [DataSnapshot] for this event.
  DataSnapshot get snapshot =>
      _dataSnapshot ??= DataSnapshot._(_delegate.snapshot);

  /// A string containing the key of the previous sibling child by sort order,
  /// or null if it is the first child.
  String? get previousChildKey => _delegate.previousChildKey;
}
