// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

class _PlatformUtils {
  static platform.DocumentSnapshotPlatform toPlatformDocumentSnapshot(
          DocumentSnapshot documentSnapshot) =>
      platform.DocumentSnapshotPlatform(
          documentSnapshot.reference.path,
          documentSnapshot.data,
          platform.SnapshotMetadataPlatform(
            documentSnapshot.metadata.hasPendingWrites,
            documentSnapshot.metadata.isFromCache,
          ),
          platform.FirestorePlatform.instance);
}
