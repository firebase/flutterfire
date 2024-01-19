// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import '../firestore.dart';

/// Returns Dart representation from JS Object.
dynamic dartify(JSObject? jsObject) {
  if (jsObject == null) {
    return null;
  }
  if (jsObject.instanceof(DocumentReferenceJsConstructor as JSFunction)) {
    return DocumentReference.getInstance(jsObject as DocumentReferenceJsImpl);
  }
  if (jsObject.instanceof(GeoPointConstructor as JSFunction)) {
    return jsObject;
  }
  if (jsObject.instanceof(TimestampJsConstructor as JSFunction)) {
    final castedJSObject = jsObject as TimestampJsImpl;
    return Timestamp(
        castedJSObject.seconds.toDartInt, castedJSObject.nanoseconds.toDartInt);
  }
  if (jsObject.instanceof(BytesConstructor as JSFunction)) {
    return jsObject as BytesJsImpl;
  }
  return jsObject.dartify();
}

/// Returns the JS implementation from Dart Object.
JSAny? jsify(Object? dartObject) {
  if (dartObject == null) {
    return dartObject?.jsify();
  }

  if (dartObject is DateTime) {
    return TimestampJsImpl.fromMillis(dartObject.millisecondsSinceEpoch.toJS)
        as JSAny;
  }

  if (dartObject is Timestamp) {
    return TimestampJsImpl.fromMillis(dartObject.millisecondsSinceEpoch.toJS)
        as JSAny;
  }

  if (dartObject is DocumentReference) {
    return dartObject.jsObject as JSAny;
  }

  if (dartObject is FieldValue) {
    return jsifyFieldValue(dartObject);
  }

  if (dartObject is BytesJsImpl) {
    return dartObject as JSAny;
  }

  // NOTE: if the firestore JS lib is not imported, we'll get a DDC warning here
  if (dartObject is GeoPointJsImpl) {
    return dartObject as JSAny;
  }

  if (dartObject is JSAny Function()) {
    return dartObject.toJS;
  }

  return dartObject.jsify();
}
