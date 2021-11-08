// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

/// `DatabaseEvent` encapsulates a DataSnapshot and possibly also the key of its
/// previous sibling, which can be used to order the snapshots.
class DatabaseEvent {
  final DatabaseEventPlatform _delegate;

  DatabaseEvent._(this._delegate) {
    DatabaseEventPlatform.verifyExtends(_delegate);
  }

  /// The type of event.
  DatabaseEventType get type => _delegate.type;

  /// The [DataSnapshot] for this event.
  DataSnapshot get snapshot => DataSnapshot._(_delegate.snapshot);

  String? get previousChildKey => _delegate.previousChildKey;
}
