part of cloud_firestore_web;

/// Builds [DocumentSnapshot] instance form web snapshot instance
DocumentSnapshot _fromWebDocumentSnapshotToPlatformDocumentSnapshot(
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
