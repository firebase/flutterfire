part of firebase_database_platform_interface;

/// A DatabaseError contains code, message and details of a Firebase Database
/// Error that results from a transaction operation at a Firebase Database
/// location.
class DatabaseErrorPlatform {
  DatabaseErrorPlatform(Map<dynamic, dynamic> _data)
      : code = _data['code'],
        message = _data['message'],
        details = _data['details'];

  /// One of the defined status codes, depending on the error.
  final int code;

  /// A human-readable description of the error.
  final String message;

  /// Human-readable details on the error and additional information.
  final String? details;

  @override
  // ignore: no_runtimetype_tostring
  String toString() => '$runtimeType($code, $message, $details)';
}
