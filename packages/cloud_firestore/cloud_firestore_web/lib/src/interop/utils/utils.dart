// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:js/js.dart';
import 'package:js/js_util.dart' as util;

import '../firestore.dart';
import '../firestore_interop.dart' hide FieldValue;

/// Returns Dart representation from JS Object.
dynamic dartify(Object? jsObject) {
  return core_interop.dartify(
      jsObject,
      (Object object) {
        if (util.instanceof(object, DocumentReferenceJsConstructor)) {
          return DocumentReference.getInstance(
              object as DocumentReferenceJsImpl);
        }
        if (util.instanceof(object, GeoPointConstructor)) {
          return object;
        }
        if (util.instanceof(object, TimestampJsConstructor)) {
          return DateTime.fromMillisecondsSinceEpoch(
              (object as TimestampJsImpl).toMillis());
        }
        if (util.instanceof(object, BlobConstructor)) {
          return object as Blob;
        }
        return null;
      } as Object Function(Object?)?);
}

/// Returns the JS implementation from Dart Object.
dynamic jsify(Object? dartObject) {
  if (dartObject == null) {
    return null;
  }

  return core_interop.jsify(
      dartObject,
      (Object? object) {
        if (object is DateTime) {
          return TimestampJsImpl.fromMillis(object.millisecondsSinceEpoch);
        }

        if (object is DocumentReference) {
          return object.jsObject;
        }

        if (object is FieldValue) {
          return jsifyFieldValue(object);
        }

        if (object is Blob) {
          return object;
        }

        // NOTE: if the firestore JS lib is not imported, we'll get a DDC warning here
        if (object is GeoPoint) {
          return dartObject;
        }

        if (object is Function) {
          return allowInterop(object);
        }

        return null;
      } as Object Function(Object)?);
}
