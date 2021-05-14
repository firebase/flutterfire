part of cloud_firestore;

class LoadBundleTask {
  LoadBundleTask._(this._delegate) {
    LoadBundleTaskPlatform.verifyExtends(_delegate);
  }

  final LoadBundleTaskPlatform _delegate;

  Stream<LoadBundleTaskSnapshot> stream() {
    return _delegate.stream.map((event) => LoadBundleTaskSnapshot._(event));
  }
}
