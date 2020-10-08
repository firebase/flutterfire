import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:js/js.dart';
import 'package:js/js_util.dart' as util;

import '../firestore.dart';
import '../firestore_interop.dart' hide FieldValue;

/// Returns Dart representation from JS Object.
dynamic dartify(Object jsObject) {
  if (util.hasProperty(jsObject, 'firestore') &&
      util.hasProperty(jsObject, 'id') &&
      util.hasProperty(jsObject, 'parent')) {
    // This is likely a document reference – at least we hope
    // TODO(ehesp): figure out if there is a more robust way to detect
    return DocumentReference.getInstance(jsObject);
  }

  if (util.hasProperty(jsObject, 'latitude') &&
      util.hasProperty(jsObject, 'longitude') &&
      core_interop.objectKeys(jsObject).length == 2) {
    // This is likely a GeoPoint – return it as-is
    return jsObject as GeoPoint;
  }

  var proto = util.getProperty(jsObject, '__proto__');

  if (util.hasProperty(proto, 'toDate') &&
      util.hasProperty(proto, 'toMillis')) {
    return DateTime.fromMillisecondsSinceEpoch(
        (jsObject as TimestampJsImpl).toMillis());
  }

  if (util.hasProperty(proto, 'isEqual') &&
      util.hasProperty(proto, 'toBase64')) {
    // This is likely a GeoPoint – return it as-is
    // TODO(ehesp): figure out if there is a more robust way to detect
    return jsObject as Blob;
  }

  // Pass to generic util handler
  return core_interop.dartify(jsObject);
}

/// Returns the JS implementation from Dart Object.
dynamic jsify(Object dartObject) {
  if (dartObject is DateTime) {
    return TimestampJsImpl.fromMillis(dartObject.millisecondsSinceEpoch);
  }

  if (dartObject is DocumentReference) {
    return dartObject.jsObject;
  }

  if (dartObject is FieldValue) {
    return jsifyFieldValue(dartObject);
  }

  if (dartObject is Blob) {
    return dartObject;
  }

  // NOTE: if the firestore JS lib is not imported, we'll get a DDC warning here
  if (dartObject is GeoPoint) {
    return dartObject;
  }

  if (dartObject is Function) {
    return allowInterop(dartObject);
  }

  return core_interop.jsify(dartObject);
}

