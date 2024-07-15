// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

class PersistentCacheIndexManager extends PersistentCacheIndexManagerPlatform {
  PersistentCacheIndexManager(
    this.api,
    this.app,
    // todo - might be able to remove
    FirebaseFirestorePlatform firestore,
  ) : super(firestore);

  final FirebaseFirestoreHostApi api;
  final FirestorePigeonFirebaseApp app;
  @override
  Future<void> enableIndexAutoCreation() async {
    return api.enableIndexAutoCreation(app);
  }

  @override
  Future<void> disableIndexAutoCreation() async {
    return api.disableIndexAutoCreation(app);
  }

  @override
  Future<void> deleteAllIndexes() async {
    return api.deleteAllIndexes(app);
  }
}
