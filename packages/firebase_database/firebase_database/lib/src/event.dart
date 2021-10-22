// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

/// `Event` encapsulates a DataSnapshot and possibly also the key of its
/// previous sibling, which can be used to order the snapshots.
class Event {
  final EventPlatform _delegate;

  Event._(this._delegate);

  EventType get type => _delegate.type;
  DataSnapshot get snapshot => DataSnapshot._(_delegate.snapshot);
  String? get previousSiblingKey => _delegate.previousSiblingKey;
}
