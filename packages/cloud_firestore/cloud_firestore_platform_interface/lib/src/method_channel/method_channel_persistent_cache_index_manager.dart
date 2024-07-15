// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

class MethodChannelPersistentCacheIndexManager
    extends PersistentCacheIndexManagerPlatform {
  MethodChannelPersistentCacheIndexManager(
    this.api,
    this.app,
  ) : super();

  final FirebaseFirestoreHostApi api;
  final FirestorePigeonFirebaseApp app;
  @override
  Future<void> enableIndexAutoCreation() async {
    return api.persistenceCacheIndexManagerRequest(
      app,
      PersistenceCacheIndexManagerRequest.enableIndexAutoCreation,
    );
  }

  @override
  Future<void> disableIndexAutoCreation() async {
    return api.persistenceCacheIndexManagerRequest(
      app,
      PersistenceCacheIndexManagerRequest.disableIndexAutoCreation,
    );
  }

  @override
  Future<void> deleteAllIndexes() async {
    return api.persistenceCacheIndexManagerRequest(
      app,
      PersistenceCacheIndexManagerRequest.deleteAllIndexes,
    );
  }
}
