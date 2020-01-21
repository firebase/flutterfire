part of firebase_database_platform_interface;

/// A DataSnapshot contains data from a Firebase Database location.
/// Any time you read Firebase data, you receive the data as a DataSnapshot.
class DataSnapshot {
  /// Creates [DataSnapshot] object with provided [key] and  [value].
  DataSnapshot(this.key, this.value);

  /// The key of the location that generated this DataSnapshot.
  final String key;

  /// Returns the contents of this data snapshot as native types.
  final dynamic value;
}
