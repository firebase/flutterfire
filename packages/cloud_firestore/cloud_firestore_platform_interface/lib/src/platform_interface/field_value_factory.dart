part of cloud_firestore_platform_interface;

/// Sentinel values that can be used when writing document fields with set() or
/// update().
enum FieldValueType {
  /// adds elements to an array but only elements not already present
  arrayUnion,

  /// removes all instances of each given element
  arrayRemove,

  /// deletes field
  delete,

  /// sets field value to server timestamp
  serverTimestamp,

  ///  increment or decrement a numeric field value using a double value
  incrementDouble,

  ///  increment or decrement a numeric field value using an integer value
  incrementInteger,
}

/// An interface for a factory that is used to build [FieldValuePlatform] according to
/// Platform (web or mobile)
abstract class FieldValueFactoryPlatform extends PlatformInterface {
  /// Current instance of [FieldValueFactoryPlatform]
  static FieldValueFactoryPlatform get instance => _instance;

  static FieldValueFactoryPlatform _instance = MethodChannelFieldValueFactory();

  /// Sets the default instance of [FieldValueFactoryPlatform] which is used to build
  /// [FieldValuePlatform] items
  static set instance(FieldValueFactoryPlatform instance) {
    // PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [FieldValueFactoryPlatform].
  /// This is used by the app-facing [FieldValueFactory] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static verifyExtends(FieldValueFactoryPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  /// Returns a special value that tells the server to union the given elements
  /// with any array value that already exists on the server.
  ///
  /// Each specified element that doesn't already exist in the array will be
  /// added to the end. If the field being modified is not already an array it
  /// will be overwritten with an array containing exactly the specified
  /// elements.
  FieldValueInterface arrayUnion(List<dynamic> elements) {
    throw UnimplementedError("arrayUnion() is not implemented");
  }

  /// Returns a special value that tells the server to remove the given
  /// elements from any array value that already exists on the server.
  ///
  /// All instances of each element specified will be removed from the array.
  /// If the field being modified is not already an array it will be overwritten
  /// with an empty array.
  FieldValueInterface arrayRemove(List<dynamic> elements) {
    throw UnimplementedError("arrayRemove() is not implemented");
  }

  /// Returns a sentinel for use with update() to mark a field for deletion.
  FieldValueInterface delete() {
    throw UnimplementedError("delete() is not implemented");
  }

  /// Returns a sentinel for use with set() or update() to include a
  /// server-generated timestamp in the written data.
  FieldValueInterface serverTimestamp() {
    throw UnimplementedError("serverTimestamp() is not implemented");
  }

  /// Returns a special value for use with set() or update() that tells the
  /// server to increment the field’s current value by the given value.
  FieldValueInterface increment(num value) {
    throw UnimplementedError("increment() is not implemented");
  }
}
