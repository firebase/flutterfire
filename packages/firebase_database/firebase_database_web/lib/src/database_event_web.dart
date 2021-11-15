// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_web;

/// Web implementation for firebase [DataSnapshotPlatform]
class DatabaseEventWeb extends DatabaseEventPlatform {
  DatabaseEventWeb(
    this._ref,
    DatabaseEventType eventType,
    this._event,
  ) : super(<String, dynamic>{
          'previousChildKey': _event.prevChildKey,
          'eventType': eventTypeToString(eventType),
        });

  final DatabaseReferencePlatform _ref;

  final database_interop.QueryEvent _event;

  @override
  DataSnapshotPlatform get snapshot {
    return webSnapshotToPlatformSnapshot(_ref, _event.snapshot);
  }
}
