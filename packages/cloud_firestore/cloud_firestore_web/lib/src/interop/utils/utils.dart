// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;

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
dynamic jsify(Object? dartObject) {
  if (dartObject == null) {
    return null;
  }

  return core_interop.jsify(dartObject, (Object? object) {
    if (object is DateTime) {
      return TimestampJsImpl.fromMillis(object.millisecondsSinceEpoch.toJS);
    }

    if (object is Timestamp) {
      return TimestampJsImpl.fromMillis(object.millisecondsSinceEpoch.toJS);
    }

    if (object is DocumentReference) {
      return object.jsObject;
    }

    if (object is FieldValue) {
      return jsifyFieldValue(object);
    }

    if (object is BytesJsImpl) {
      return object;
    }

    // NOTE: if the firestore JS lib is not imported, we'll get a DDC warning here
    if (object is GeoPointJsImpl) {
      return dartObject;
    }

    if (object is Function) {
      return object.toJS;
    }

    return null;
  });
}
