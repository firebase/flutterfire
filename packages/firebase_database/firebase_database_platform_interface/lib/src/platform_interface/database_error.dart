part of firebase_database_platform_interface;

/// A DatabaseError contains code, message and details of a Firebase Database
/// Error that results from a transaction operation at a Firebase Database
/// location.
class DatabaseErrorPlatform {
  DatabaseErrorPlatform(this._data);

  Map<dynamic, dynamic> _data;

  /// One of the defined status codes, depending on the error.
  int get code => _data['code'];

  /// A human-readable description of the error.
  String get message => _data['message'];

  /// Human-readable details on the error and additional information.
  String get details => _data['details'];

  @override
  // ignore: no_runtimetype_tostring
  String toString() => '$runtimeType($code, $message, $details)';
}
