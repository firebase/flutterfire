import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;
import 'package:js/js_util.dart';

import 'package:cloud_firestore_web/src/field_value_web.dart';

/// An implementation of [FieldValueFactoryPlatform] which builds [FieldValuePlatform]
/// instance that is [jsify] friendly
class FieldValueFactoryWeb extends FieldValueFactoryPlatform {
  @override
  FieldValuePlatform arrayRemove(List elements) {
    final delegate = web.FieldValue.arrayRemove(elements);
    return FieldValueWeb(delegate, FieldValueType.arrayRemove, elements);
  }

  @override
  FieldValuePlatform arrayUnion(List elements) {
    final delegate = web.FieldValue.arrayUnion(elements);
    return FieldValueWeb(delegate, FieldValueType.arrayUnion, elements);
  }

  @override
  FieldValuePlatform delete() {
    final delegate = web.FieldValue.delete();
    return FieldValueWeb(delegate, FieldValueType.delete, null);
  }

  @override
  FieldValuePlatform increment(num value) {
    assert(value is double || value is int, "value can only be double or int");
    final delegate = web.FieldValue.increment(value);
    return FieldValueWeb(
        delegate,
        value is int
            ? FieldValueType.incrementInteger
            : FieldValueType.incrementDouble,
        value);
  }

  @override
  FieldValuePlatform serverTimestamp() {
    final delegate = web.FieldValue.serverTimestamp();
    return FieldValueWeb(delegate, FieldValueType.serverTimestamp, null);
  }
}
