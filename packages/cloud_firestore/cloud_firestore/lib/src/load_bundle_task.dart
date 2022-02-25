part of cloud_firestore;

class LoadBundleTask {
  LoadBundleTask._(this._delegate) {
    LoadBundleTaskPlatform.verifyExtends(_delegate);
  }

  final LoadBundleTaskPlatform _delegate;

  late final Stream<LoadBundleTaskSnapshot> stream =
      // ignore: unnecessary_lambdas, false positive, event is dynamic
      _delegate.stream.map((event) => LoadBundleTaskSnapshot._(event));
}
