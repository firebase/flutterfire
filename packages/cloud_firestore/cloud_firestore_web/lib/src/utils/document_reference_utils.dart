import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;

import 'package:cloud_firestore_web/src/utils/codec_utility.dart';

/// Builds [DocumentSnapshot] instance form web snapshot instance
DocumentSnapshot fromWebDocumentSnapshotToPlatformDocumentSnapshot(
    web.DocumentSnapshot webSnapshot, FirestorePlatform firestore) {
  return DocumentSnapshot(
      webSnapshot.ref.path,
      CodecUtility.decodeMapData(webSnapshot.data()),
      SnapshotMetadata(
        webSnapshot.metadata.hasPendingWrites,
        webSnapshot.metadata.fromCache,
      ),
      firestore);
}
