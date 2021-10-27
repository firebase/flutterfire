part of firebase_database;

/// A DatabaseError contains code, message and details of a Firebase Database
/// Error that results from a transaction operation at a Firebase Database
/// location.
class DatabaseError {
  DatabaseError._(DatabaseErrorPlatform _delegate)
      : code = _delegate.code,
        message = _delegate.message,
        details = _delegate.details;

  /// One of the defined status codes, depending on the error.
  int code;

  /// A human-readable description of the error.
  String message;

  /// Human-readable details on the error and additional information.
  String? details;

  @override
  // ignore: no_runtimetype_tostring
  String toString() => '$runtimeType($code, $message, $details)';
}
