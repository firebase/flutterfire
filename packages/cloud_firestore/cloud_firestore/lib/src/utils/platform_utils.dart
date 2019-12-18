part of cloud_firestore;

class _PlatformUtils {
  static DocumentChangeType fromPlatform(platform.DocumentChangeType platformChange) {
    switch (platformChange) {
      case platform.DocumentChangeType.added:
        return DocumentChangeType.added;
      case platform.DocumentChangeType.modified:
        return DocumentChangeType.modified;
      case platform.DocumentChangeType.removed:
        return DocumentChangeType.removed;
      default:
        throw ArgumentError("Invalud change type");
    }
  }

  static platform.Source toPlatformSource(Source platformSource) {
    switch (platformSource) {
      case Source.cache:
        return platform.Source.cache;
      case Source.server:
        return platform.Source.server;
      case Source.serverAndCache:
        return platform.Source.serverAndCache;
      default:

        throw ArgumentError("Invalid source value");
    }
  }

  static platform.DocumentSnapshot toPlatformDocumentSnapshot(
          DocumentSnapshot documentSnapshot) =>
      platform.DocumentSnapshot(
          documentSnapshot.reference.path,
          documentSnapshot.data,
          platform.SnapshotMetadata(
            documentSnapshot.metadata.hasPendingWrites,
            documentSnapshot.metadata.isFromCache,
          ),
          platform.FirestorePlatform.instance);
}
