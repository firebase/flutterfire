part of firebase_database_web;

/// Web implementation for firebase [DataSnapshotPlatform]
class DataSnapshotWeb implements DataSnapshotPlatform {
  // TODO rename to _delegate
  final database_interop.DataSnapshot snapshot;

  DataSnapshotWeb(this.snapshot);

  @override
  bool get exists => snapshot.exists();

  @override
  bool hasChild(String path) {
    return snapshot.hasChild(path);
  }

  @override
  String? get key {
    return snapshot.key;
  }

  @override
  get value {
    return snapshot.val();
  }

  @override
  DataSnapshotPlatform child(String childPath) {
    return fromWebSnapshotToPlatformSnapShot(snapshot.child(childPath));
  }

  @override
  // TODO: implement children
  Iterable<DataSnapshotPlatform> get children => throw UnimplementedError();

  @override
  Object? get priority => snapshot.getPriority();

  @override
  // TODO: implement ref
  DatabaseReferencePlatform get ref => throw UnimplementedError();
}
