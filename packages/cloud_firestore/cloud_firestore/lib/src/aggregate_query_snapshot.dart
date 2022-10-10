part of cloud_firestore;

class AggregateQuerySnapshot {
  AggregateQuerySnapshot._(this._delegate) {
    AggregateQuerySnapshotPlatform.verifyExtends(_delegate);
  }
  final AggregateQuerySnapshotPlatform _delegate;

  int get count => _delegate.count;
}
