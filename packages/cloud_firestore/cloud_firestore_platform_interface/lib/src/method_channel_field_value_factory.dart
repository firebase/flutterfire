part of cloud_firestore_platform_interface;

/// An implementation of [FieldValueFactory] that is suitable to be used
/// on mobile where communication relies on [MethodChannel]
class MethodChannelFieldValueFactory implements FieldValueFactory {
  @override
  FieldValue arrayRemove(List elements) =>
      FieldValue._(FieldValueType.arrayRemove, elements);

  @override
  FieldValue arrayUnion(List elements) =>
      FieldValue._(FieldValueType.arrayUnion, elements);

  @override
  FieldValue delete() => FieldValue._(FieldValueType.delete, null);

  @override
  FieldValue increment(num value) {
    // It is a compile-time error for any type other than int or double to
    // attempt to extend or implement num.
    assert(value is int || value is double);
    if (value is double) {
      return FieldValue._(FieldValueType.incrementDouble, value);
    } else if (value is int) {
      return FieldValue._(FieldValueType.incrementInteger, value);
    }
    return null;
  }

  @override
  FieldValue serverTimestamp() =>
      FieldValue._(FieldValueType.serverTimestamp, null);
}
