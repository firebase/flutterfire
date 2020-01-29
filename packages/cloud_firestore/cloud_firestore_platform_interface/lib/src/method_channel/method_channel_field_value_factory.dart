part of cloud_firestore_platform_interface;

/// An implementation of [FieldValueFactoryPlatform] that is suitable to be used
/// on mobile where communication relies on [MethodChannel]
class MethodChannelFieldValueFactory implements FieldValueFactoryPlatform {
  @override
  FieldValuePlatform arrayRemove(List elements) =>
      FieldValuePlatform._(FieldValueType.arrayRemove, elements);

  @override
  FieldValuePlatform arrayUnion(List elements) =>
      FieldValuePlatform._(FieldValueType.arrayUnion, elements);

  @override
  FieldValuePlatform delete() => FieldValuePlatform._(FieldValueType.delete, null);

  @override
  FieldValuePlatform increment(num value) {
    // It is a compile-time error for any type other than `int` or `double` to
    // attempt to extend or implement `num`.
    assert(value is int || value is double);
    if (value is double) {
      return FieldValuePlatform._(FieldValueType.incrementDouble, value);
    } else if (value is int) {
      return FieldValuePlatform._(FieldValueType.incrementInteger, value);
    }
    return null;
  }

  @override
  FieldValuePlatform serverTimestamp() =>
      FieldValuePlatform._(FieldValueType.serverTimestamp, null);
}
