// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database_web;

/// Builds [EventPlatform] instance form web event instance
DatabaseEventPlatform webEventToPlatformEvent(
  DatabaseReferencePlatform ref,
  DatabaseEventType eventType,
  database_interop.QueryEvent event,
) {
  return DatabaseEventWeb(ref, eventType, event);
}

/// Builds [DataSnapshotPlatform] instance form web snapshot instance
DataSnapshotPlatform webSnapshotToPlatformSnapshot(
  DatabaseReferencePlatform ref,
  database_interop.DataSnapshot snapshot,
) {
  return DataSnapshotWeb(ref, snapshot);
}
