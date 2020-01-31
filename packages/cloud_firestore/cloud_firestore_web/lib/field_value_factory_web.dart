part of cloud_firestore_web;

/// An implementation of [FieldValueFactoryPlatform] which builds [FieldValuePlatform]
/// instance that is [jsify] friendly
class FieldValueFactoryWeb extends FieldValueFactoryPlatform {
  @override
  FieldValuePlatform arrayRemove(List elements) {
    final delegate = web.FieldValue.arrayRemove(elements);
    return FieldValueWeb._(delegate, FieldValueType.arrayRemove, elements);
  }

  @override
  FieldValuePlatform arrayUnion(List elements) {
    final delegate = web.FieldValue.arrayUnion(elements);
    return FieldValueWeb._(delegate, FieldValueType.arrayUnion, elements);
  }

  @override
  FieldValuePlatform delete() {
    final delegate = web.FieldValue.delete();
    return FieldValueWeb._(delegate, FieldValueType.delete, null);
  }

  @override
  FieldValuePlatform increment(num value) {
    assert(value is double || value is int, "value can only be double or int");
    final delegate = web.FieldValue.increment(value);
    return FieldValueWeb._(
        delegate,
        value is int
            ? FieldValueType.incrementInteger
            : FieldValueType.incrementDouble,
        value);
  }

  @override
  FieldValuePlatform serverTimestamp() {
    final delegate = web.FieldValue.serverTimestamp();
    return FieldValueWeb._(delegate, FieldValueType.serverTimestamp, null);
  }
}
