import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

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

/// MethodChannel implementation of a [FieldValuePlatform].
class MethodChannelFieldValue extends FieldValuePlatform {
  /// Constructor.
  MethodChannelFieldValue(this.type, this.value) : super();

  /// The type of FieldValue.
  final FieldValueType type;

  /// The value associated with the FieldValueType above.
  final dynamic value;
}
