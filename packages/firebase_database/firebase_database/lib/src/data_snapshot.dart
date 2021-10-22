part of firebase_database;

/// A DataSnapshot contains data from a Firebase Database location.
/// Any time you read Firebase data, you receive the data as a DataSnapshot.
class DataSnapshot {
  final DataSnapshotPlatform? _delegate;

  DataSnapshot._(this._delegate);

  /// The key of the location that generated this DataSnapshot.
  String? get key => _delegate?.key;

  /// Returns the contents of this data snapshot as native types.
  dynamic get value => _delegate?.value;

  /// Ascertains whether the value exists at the Firebase Database location.
  bool get exists => _delegate?.exists ?? false;

  // Returns wheterh or not the DataSnapshot has any non-null child properties
  bool get hasChildren => _delegate?.hasChildren ?? false;

  // Returns true if the specified child path has (non-null) data.
  bool hasChild(String path) => _delegate?.hasChild(path) ?? false;

  // Returns the number of child properties of this DataSnapshot.
  int? get numChildren => _delegate?.numChildren;

  // Enumerates the top-level children in the [DataSnapshot]
  void forEach(void Function(DataSnapshot snapshot) action) {
    _delegate?.forEach((element) {
      action(DataSnapshot._(element));
    });
  }
}
