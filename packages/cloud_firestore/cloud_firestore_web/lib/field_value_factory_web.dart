part of cloud_firestore_web;

/// An implementation of [FieldValueFactory] which builds [FieldValue]
/// instance that is [jsify] friendly
class FieldValueFactoryWeb implements FieldValueFactory {
  @override
  FieldValueInterface arrayRemove(List elements) {
    final delegate = web.FieldValue.arrayRemove(elements);
    return FieldValueWeb._(delegate, FieldValueType.arrayRemove, elements);
  }

  @override
  FieldValueInterface arrayUnion(List elements) {
    final delegate = web.FieldValue.arrayUnion(elements);
    return FieldValueWeb._(delegate, FieldValueType.arrayUnion, elements);
  }

  @override
  FieldValueInterface delete() {
    final delegate = web.FieldValue.delete();
    return FieldValueWeb._(delegate, FieldValueType.delete, null);
  }

  @override
  FieldValueInterface increment(num value) {
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
  FieldValueInterface serverTimestamp() {
    final delegate = web.FieldValue.serverTimestamp();
    return FieldValueWeb._(delegate, FieldValueType.serverTimestamp, null);
  }
}
