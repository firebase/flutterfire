/// An options object that configures the behavior of set() calls in DocumentReference, WriteBatch and Transaction.
/// These calls can be configured to perform granular merges instead of overwriting the target documents in their
/// entirety by providing a SetOptions with merge: true.
class PlatformSetOptions {
  /// Constructor
  PlatformSetOptions({this.merge});

  /// Changes the behavior of a set() call to only replace the values specified in its data argument.
  /// Fields omitted from the set() call remain untouched.
  bool merge;
}
