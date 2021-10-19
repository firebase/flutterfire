part of firebase_database;

/// A DatabaseError contains code, message and details of a Firebase Database
/// Error that results from a transaction operation at a Firebase Database
/// location.
class DatabaseError {
  DatabaseErrorPlatform _delegate;

  DatabaseError._(this._delegate);

  /// One of the defined status codes, depending on the error.
  int get code => _delegate.code;

  /// A human-readable description of the error.
  String get message => _delegate.message;

  /// Human-readable details on the error and additional information.
  String get details => _delegate.details;

  @override
  // ignore: no_runtimetype_tostring
  String toString() => '$runtimeType($code, $message, $details)';
}
