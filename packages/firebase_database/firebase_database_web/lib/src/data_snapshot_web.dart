part of firebase_database_web;

/// Web implementation for firebase [DataSnapshotPlatform]
class DataSnapshotWeb implements DataSnapshotPlatform {
  final database_interop.DataSnapshot snapshot;

  DataSnapshotWeb(this.snapshot);

  @override
  bool get exists => snapshot.exists();

  @override
  void forEach(void Function(DataSnapshotPlatform element) iterator) {
    snapshot.forEach((snapshot) => iterator(DataSnapshotWeb(snapshot)));
  }

  @override
  bool hasChild(String path) {
    return snapshot.hasChild(path);
  }

  @override
  bool get hasChildren {
    return snapshot.hasChildren();
  }

  @override
  String? get key {
    return snapshot.key;
  }

  @override
  int get numChildren {
    return snapshot.numChildren();
  }

  @override
  get value {
    return snapshot.val();
  }
}
